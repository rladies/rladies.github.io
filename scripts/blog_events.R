library(airtabler)
library(tidyverse)
library(glue)
library(readr)

source("scripts/blog_functions.R")

# Get data and draft blogposts----
process_events <- function(base_id) {
  
  # Connect and get data
  base <- connect_to_airtable(base_id, tables = "Event Reports")
  events_data <- base$`Event Reports`$select()
  
  # Filter ready-to-draft events
  events_to_draft <- filter_ready_to_draft(events_data, title_col = "title")
  
  if (nrow(events_to_draft) == 0) {
    message("No new event reports to draft.")
    return(0)
  }
  
  message("Found ", nrow(events_to_draft), " new event report(s) to draft.")
  
  # Process each event
  for (i in 1:nrow(events_to_draft)) {
    report <- events_to_draft[i, ]
    
    tryCatch({
      # Validate required fields
      if (!validate_required_fields(report, c("title", "createdTime"))) {
        next
      }
      
      # Create slug and paths
      slug <- create_slug(report$title)
      post_date <- ymd_hms(report$createdTime)
      year <- year(post_date)
      month_day_slug <- paste0(format(post_date, "%m-%d"), "-", slug)
      
      # Create folder
      folder_path <- create_post_folder(year, month_day_slug)
      
      # Download images if they exist
      image_markdown <- ""
      if (!is.na(report$media) && report$media != "") {
        message("Downloading images for event: ", report$title)
        downloaded_images <- download_images(report$media, folder_path)
        
        # Create markdown for images
        if (!is.null(downloaded_images) && length(downloaded_images) > 0) {
          image_markdown <- create_image_markdown(downloaded_images)
        }
      }
      # Markdown front-matter ----
      
      front_matter <- glue(
      '---
      title: "Event Report: {report$Title}"
      author: "{report$Author}"
      date: "{format(post_date, "%Y-%m-%d")}"
      tags: [{report$Keywords}]
      ---
      '
      )
      # standardised blogpost
      
      post_body <- glue(
      'On {report$Date}, {report$Chapter} hosted the event "{report$Title}". 
      The session was led by {report$Speakers} and was attended by {report$Participants} participants.
      
      ## Event Summary
      
      Here are the key topics that were covered:
      
      {report$Summary}
      
      ## Attendee Feedback
      
      > {report$`Quotes or Reactions (optional)`}
      
      ## Resources
      
      A big thank you to the speakers and everyone who attended!'
      )
      
      # Write file
      content <- paste0(front_matter, post_body)
      filepath <- write_markdown_file(content, folder_path)
      message("✓ Successfully created: ", filepath)
      
    }, error = function(e) {
      warning("Error processing event ", i, ": ", e$message)
    })
  }
  
  return(nrow(events_to_draft))
}

# After successfully creating the markdown file:
# Update the Airtable record to:
# - Status = "Post drafted"
# - Add PR URL