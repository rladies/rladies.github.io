library(airtabler)
library(tidyverse)
library(glue)
library(readr)

# Setup ----
api_key <- Sys.setenv("AIRTABLE_API_KEY")
base_id <- Sys.getenv("AIRTABLE_BASE_ID")
table_name <- Sys.getenv("AIRTABLE_TABLE_ID")


# Connect to base ----
base <- airtable(base = base_id,
                 tables = c("Proposals", "Event Reports"))

# Get data ----
events_data <- base$`Event Reports`$select()
str(events_data)

events_to_draft <- events_data %>%
  filter(`Status` == "In progress", Decision == "Accept")

# @Mo, I tried and failed all morning to make a Status column in the event report like the one in proposals.
# I guess it could also have a manual toggle
# From here it assumes there is a "Status" column)

if (nrow(events_to_draft) == 0) {
  print("No new event reports to draft")
  quit()
}

print(paste("Found", nrow(events_to_draft), "new event report(s) to draft."))

for (i in 1:nrow(events_to_draft)) {
  
  report <- events_to_draft[i, ]

  slug <- report$title %>%
    str_to_lower() %>%
    str_replace_all("[^a-z0-9\\s-]", "") %>%
    str_replace_all("\\s+", "-")
  
  # I use the *submission date* (`createdTime`) for the post date, 
  # as the event `date` will always be in the past.
  post_date <- ymd_hms(report$createdTime)
  year <- year(post_date)
  month_day_slug <- paste0(format(post_date, "%m-%d"), "-", slug)
  
  file_path <- file.path("content", "blog", year, month_day_slug)
  
  dir.create(file_path, recursive = TRUE, showWarnings = FALSE)
  
  # Markdown front-matter ----
  front_matter <- glue(
    '---
    title: "Event Report: {report$title}"
    author: "{report$author}"
    date: "{format(post_date, "%Y-%m-%d")}"
    tags: [{report$keywords}]
    ---
    
    '
  )
  
  # standardised blogpost
  post_body <- glue(
    'On {report$date}, {report$chapter} hosted the event "{report$title}". 
    The session was led by {report$speakers} and was attended by {report$participants} participants.

    ## Event Summary

    Here are the key topics that were covered:

    {report$summary}

    ## Attendee Feedback

    > {report$`Quotes or Reactions (optional)`}
    
    ## Resources

    A big thank you to the speakers and everyone who attended!'
  )

  final_content <- paste0(front_matter, post_body)
  final_file_name <- file.path(file_path, "index.en.md")
  
  writeLines(final_content, final_file_name)
  
  print(paste("Successfully created event report file:", final_file_name))
  
  # next: logic to update Airtable
}

