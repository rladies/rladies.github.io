
load_lib <- function(x){
  suppressPackageStartupMessages(
    library(x, character.only = TRUE)
  )
}

pkgs <- sapply(c("meetupr", "dplyr"),
               load_lib)


na_col_rm <- function(x){
  indx <- apply(x, 2, function(y) all(is.na(y)))
  as_tibble(x[, !indx])
}

change_empty <- function(x) ifelse(x == "", NA, x)


# If not running interactively, 
# get token decrypted from env var
if(!interactive()){
  source(here::here("R/meetup_auth.R"))
}

cat("Retrieving R-Ladies group information\n")
# Better than getting pro groups, because we want timezone...
rladies_groups <- find_groups("r-ladies") %>% 
  filter(organizer_name == "R-Ladies Global") %>% 
  mutate(country_acronym = country) %>% 
  select(-resource, -status, -country) %>% 
  distinct()

chapters <- read.table(
  "https://raw.githubusercontent.com/rladies/starter-kit/master/Current-Chapters.csv", 
  sep = ",", header = TRUE, stringsAsFactors = FALSE) %>% 
  mutate(urlname = basename(Meetup))  %>% 
  select(-State.Region, -City, -Organizers) %>% 
  select(urlname, Status, Country, everything()) %>% 
  mutate(across(-all_of(c("Website", "Slack")), basename)) %>% 
  mutate(across(where(is.character), change_empty)) %>% 
  rename_all(tolower) %>% 
  mutate(github = paste0("rladies/", github))

some_cols <- names(chapters)[-1:-3]

# Create chapters json
to_file <- chapters %>% 
  left_join(rladies_groups, by="urlname") %>% 
  nest_by(across(-all_of(some_cols)), .key = "social_media") %>% 
  ungroup() %>% 
  transmute(name, 
            id,
            urlname,
            country,
            state, 
            city,
            members,
            status,
            lat,
            lon,
            timezone,
            status_text = status,
            status = ifelse(grepl("Retired", status),
                            "retired", tolower(status)),
            social_media = lapply(social_media, na_col_rm) 
  ) %>% 
  filter(status == "active") %>% 
  nest_by(country, .key = "chapters")

cat("\t writing 'data/chapters.json'\n")
jsonlite::write_json(to_file, 
                     here::here("data/chapters.json"),
                     pretty = TRUE)
