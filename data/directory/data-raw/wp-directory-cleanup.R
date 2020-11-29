library(dplyr)
library(tidyr)
library(stringr)

na_col_rm <- function(data){
  data[,!apply(data, 2, function(x) all(is.na(x)))]
}

strip_html <- function(x) {
  # x <- charToRaw(x)
  x <- xml2::read_html(x)
  rvest::html_text(x)
}

directory <- read.table(here::here("directory/wp_directory_20200923.csv"),
                        header = TRUE, stringsAsFactors = FALSE, sep = ",") %>%
  janitor::clean_names() %>%
  as_tibble() %>%
  # janitor splits up linkedin and youtube, get them back in shape
  rename_all(function(x) gsub("you_tube", "youtube", x)) %>%
  rename_all(function(x) gsub("linked_in", "linkedin", x))

write.table(directory,
            here::here("directory/wp_directory_20200923_cleannames.csv"),
            sep = ",", row.names = FALSE)


dir <- directory %>%
  na_col_rm() %>%
  # Combine certain columns into one
  mutate(name = paste(first_name, middle_name, last_name),
         honorific = paste0(honorific_prefix, honorific_suffix),
         honorific = gsub("^, ", "", honorific)) %>%

  # remove unnecessary columns
  select(-contains("address"),
         -contains("visibility"),
         -entry_type,-order, -entry_id,
         -contains("_name"), -contains("honorific_")) %>%

  # create a nested df of social media links
  pivot_longer(starts_with("social_network"),
               names_to = c(NA, NA, "platform", NA),
               values_to = "platform_url",
               names_sep = "_") %>%
  mutate(platform_url = ifelse(platform_url == "", NA, platform_url)) %>%
  nest_by(across(-starts_with("platform")),
          .key = "social_media") %>%

  # Lots of wrangling to also get other web-information
  # into the social media column
  mutate(social_media = list(bind_rows(social_media,
                                       tibble(platform = c(link_website_title,
                                                           link_blog_title),
                                              platform_url = c(link_website_url,
                                                               link_blog_url))) %>%
                               filter(platform != "") %>%
                               mutate(platform = tolower(platform),
                                      platform = gsub(" ", "-", platform),
                                      platform = ifelse(grepl("website", platform),
                                                        "website", platform),
                                      platform_user = basename(platform_url),
                                      platform_url = ifelse(platform == "website" |
                                                              grepl("r-project", platform),
                                                            platform_url,
                                                            dirname(platform_url)),
                                      platform_user = ifelse(platform == "website" |
                                                               grepl("r-project", platform),
                                                             NA,
                                                             platform_user),
                                      platform_user = coalesce(platform_user, platform_url)
                                      ) %>%
                               select(-platform_url) %>%
                               na.omit() %>%
                               pivot_wider(names_from = "platform",
                                           values_from = "platform_user")
                             )
  ) %>%
  # reorganise for easier overview
  relocate(name, honorific) %>%
  ungroup() %>%
  select(-contains("link"))

# Trying to find a way to clean the bibliography section
# not there yet
dir$k <- sapply(dir$biography,
       function(x) ifelse(x == "", NA, strip_html(x))) %>%
  gsub(" \t", "", .) %>%
  strsplit("\n") %>%
  unname() %>%
  lapply(strsplit, split = ":") %>%
  lapply(function(x) as.data.frame(do.call(rbind, x)))

dir <- dir %>%
  select(-biography) %>%
  unnest(k) %>%
  mutate(across(starts_with("V"),
                ~ ifelse(is.na(.x), "", .x))) %>%
  mutate(across(where(is.character),
                ~ gsub("^ | $", "", .x))) %>%
  mutate(
    category = case_when(
      grepl("Contact", V1, ignore.case = TRUE) ~ "contact_method",
      grepl("Package", V1, ignore.case = TRUE) ~ "r_packages",
      grepl("Group", V1, ignore.case = TRUE) ~ "r_groups",
      grepl("About", V1, ignore.case = TRUE) ~ "biography",
      grepl("Shiny", V1, ignore.case = TRUE) ~ "shiny_apps",
      TRUE ~ "interests"
    ),
    V2 = ifelse(V1 == V2, "", V2),
    value = paste(V2, V3, V4, V5, V6),
    value = str_trim(value)
  ) %>%
  select(-starts_with("V", ignore.case = FALSE)) %>%
  group_by(across(-value)) %>%
  summarise(value = paste(value, collapse = ", ")) %>%
  ungroup() %>%
  mutate(across(where(is.character),
                ~ gsub("^ | $", "", .x))) %>%
  pivot_wider(names_from = "category",
              values_from = "value") %>%
  separate_rows(categories, sep = ",") %>%
  mutate(categories = gsub("^ | $", "", categories)) %>%
  group_by(across(-categories)) %>%
  summarise(categories = list(categories)) %>%
  ungroup()

dir <- dir %>%
  mutate(across(where(is.character),
                ~ ifelse(.x == "", NA, .x))) %>%
  mutate(across(where(is.character),
                ~ gsub("^ | $", "", .x))) %>%
  mutate(across(where(is.character),
                ~ gsub("  ", " ", .x))) %>%
  mutate(across(one_of(c("interests", "shiny_apps", "r_groups",
                         "contact_method", "r_packages")),
                ~ strsplit(.x, ", ")))


jsonlite::write_json(dir, pretty = TRUE,
                     here::here("directory/rladies-directory.json"))
