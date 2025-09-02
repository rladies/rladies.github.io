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
proposals_data <- base$Proposals$select()
events_data <- base$`Event Reports`$select()

str(proposals_data)
str(events_data)

proposals_to_draft <- proposals_data %>%
  filter(`Status` == "In progress", Decision == "Accept")

if (nrow(proposals_to_draft) == 0) {
  print("No new proposals to draft.")
  quit()
}

print(paste("Found", nrow(proposals_to_draft), "new proposal(s) to draft."))

# Loop through the proposals and create md file ----
for (i in 1:nrow(proposals_to_draft)) {
  proposal <- proposals_to_draft
  proposal <- proposals_to_draft[i, ]
  
  # "slug" from the title ---
  slug <- proposal$Title %>%
    str_to_lower() %>%
    str_replace_all("[^a-z0-9\\s-]", "") %>%
    str_replace_all("\\s+", "-")

  post_date_obj <- ymd(proposal$`Post date`)
  month_day <- format(post_date_obj, "%m-%d")
  year <- year(post_date_obj)
  final_name_part <- paste0(month_day, "_", slug)
  
  file_path <- file.path("content", "blog", year, final_name_part)
  dir.create(file_path, recursive = TRUE, showWarnings = FALSE) # @Mo, recursive=TRUE to keep?
  
  # metadata for md file
  front_matter <- glue::glue(
    '---
    title: "{proposal$Title}"
    author: "{proposal$Author}"
    date: "{proposal$`Post date`}"
    ---
    
    '
  )
  body_content <- proposal$Description
  blog_file <- file.path(file_path, "index.en.md")
  
  writeLines(paste0(front_matter, body_content), blog_file)
  
  print(paste("Successfully created draft file:", blog_file))
  
  # Next, logic to update Airtable?

}
