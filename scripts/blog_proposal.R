library(airtabler)
library(tidyverse)
library(glue)
library(lubridate)

source("scripts/blog_functions.R")

# Get data and create draft blogpost ----
process_proposals <- function(base_id) {
  
  # Connect and get data
  base <- connect_to_airtable(base_id, tables = "Proposals")
  proposals_data <- base$Proposals$select()
  
  # Filter ready-to-draft proposals
  proposals_to_draft <- filter_ready_to_draft(proposals_data, title_col = "Title")
  
  if (nrow(proposals_to_draft) == 0) {
    message("No new proposals to draft.")
    return(0)
  }
  
  message("Found ", nrow(proposals_to_draft), " new proposal(s) to draft.")
  
  # Process each proposal
  for (i in 1:nrow(proposals_to_draft)) {
    proposal <- proposals_to_draft[i, ]
    
    tryCatch({
      # Validate required fields
      if (!validate_required_fields(proposal, c("Title", "Post date"))) {
        next
      }
      
      # Create slug and paths
      slug <- create_slug(proposal$Title)
      post_date_obj <- ymd(proposal$`Post date`)
      year <- year(post_date_obj)
      month_day_slug <- paste0(format(post_date_obj, "%m-%d"), "-", slug)
      
      # Create folder
      folder_path <- create_post_folder(year, month_day_slug)
      
      # Build content
      front_matter <- glue(
        '---
title: {escape_yaml(proposal$Title)}
author: {escape_yaml(proposal$Author)}
date: "{proposal$`Post date`}"
slug: {slug}
---

'
      )
      
      content <- paste0(front_matter, proposal$Description)
      
      # Write file
      filepath <- write_markdown_file(content, folder_path)
      message("✓ Successfully created: ", filepath)
      
    }, error = function(e) {
      warning("Error processing proposal ", i, ": ", e$message)
    })
  }
  
  return(nrow(proposals_to_draft))
}


# After successfully creating the markdown file:
# Update the Airtable record to:
# - Status = "Post drafted"
# - Add PR URL (once you know it)