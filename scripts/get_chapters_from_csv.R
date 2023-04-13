library(dplyr)
library(tidyr)
library(stringr)

# change empty to NA
change_empty <- function(x) ifelse(x == "", NA, x)

na_col_rm <- function(data){
  idx <- apply(data, 2, function(x) all(is.na(x)))
  data[, !idx]
}

some_cols <- c("meetup", "twitter", "email", "facebook", "instagram", "linkedin", 
               "periscope", "youtube", "github", "website", "slack", "mastodon")

chapters <- read.table(
  file = "https://raw.githubusercontent.com/rladies/starter-kit/master/Current-Chapters.csv", 
  sep = ",", 
  header = TRUE, 
  stringsAsFactors = FALSE) |>
  as_tibble() |> 
  rename_all(tolower) |> 
  mutate(
    urlname = basename(meetup),
    filenm = if_else(!is.na(state.region),
                     paste(country, state.region, city, sep = "-"),
                     paste(country, city, sep = "-")),
    filenm = paste0(tolower(filenm), ".json"),
    filenm = gsub(" ", "-", filenm),
    status = tolower(status)
  ) |> 
  mutate(
    across(-c(website, slack), basename),
    across(where(is.character), change_empty),
    github = if_else(!is.na(github), file.path("rladies", github), NA_character_),
    current = lapply(current_organizers, function(x){
      str_split(x, ",") |>
        unlist() |> 
        str_squish()
    }),
    former = lapply(former_organizers, function(x){
      str_split(x, ",") |>
        unlist() |> 
        str_squish() |> 
        unlist()
    })
  ) |> 
  select(filenm, urlname, status, country, everything()) |> 
  select(-ends_with("organizers")) |> 
  nest(
    social_media = one_of(some_cols),
    organizers = c(current, former)
  ) |> 
  mutate(
    social_media = lapply(social_media, function(x){
      k <- na_col_rm(x)
      as.list(k)
    }),
    organizers = lapply(organizers, function(x){
      lapply(x, unlist)
    })
  ) |> 
  nest_by(filenm)

mapply(
  filename = chapters$filenm,
  data = chapters$data,
  FUN = function(filename, data){
    
    # rebox contact
    rebox <- function(k, name){
      idx <- grep(name, k)
      if(length(idx) > 0 ){
        if(!grepl("\\[", k[idx] )){
          k[idx] <- gsub(": ", ": [", k[idx])
          if(grepl(",$", k[idx])){
            k[idx] <- gsub(",$", "],", k[idx])
          }else{
            k[idx] <- sprintf("%s]", k[idx])
          }
          k[idx] <- gsub("null", "", k[idx])
        }
      }
      k
    }
    jsonlite::toJSON(
      data,
      pretty = TRUE,
      auto_unbox = TRUE
    ) |> 
      strsplit("\n") |> 
      unlist() |> 
      rebox("current") |> 
      rebox("former") |> 
      writeLines(here::here("data", "chapters", filename))
  }
)

