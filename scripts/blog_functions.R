library(tidyverse)
library(glue)
library(httr)
library(airtabler)

# Connect to Airtable base
connect_to_airtable <- function(base_id, tables) {
  message("Connecting to Airtable...")
  base <- airtable(base = base_id, tables = tables)
  return(base)
}

# Filter data to get records ready for drafting
# Removes the dont-delete row and filters for In progress + Accept status
filter_ready_to_draft <- function(data, title_col = "Title") {
  data %>%
    filter(
      .data[[title_col]] != "dont-delete",
      Status == "In progress",
      Decision == "Accept"
    )
}

# Create a URL-friendly slug from text
create_slug <- function(text) {
  text %>%
    str_to_lower() %>%
    str_replace_all("[^a-z0-9\\s-]", "") %>%
    str_replace_all("\\s+", "-")
}

# Create blog post folder structure (content/blog/YYYY/mm-dd-slug/)
create_post_folder <- function(year, month_day_slug) {
  folder_path <- file.path("content", "blog", as.character(year), month_day_slug)
  dir.create(folder_path, recursive = TRUE, showWarnings = FALSE)
  return(folder_path)
}

# Escape special characters for YAML frontmatter
escape_yaml <- function(text) {
  if (is.null(text) || is.na(text) || text == "") return('""')
  # Escape quotes and wrap in quotes if text contains special YAML characters
  if (str_detect(text, '[":\\n]')) {
    text <- str_replace_all(text, '"', '\\\\"')
    text <- paste0('"', text, '"')
  }
  return(text)
}

# Download images from URLs and save to folder
# Returns vector of local filenames
download_images <- function(image_urls, folder_path) {
  
  # Handle NULL or empty input
  if (is.null(image_urls) || is.na(image_urls) || length(image_urls) == 0 || image_urls == "") {
    return(NULL)
  }
  