library(jsonlite)
library(here)
library(dplyr)
library(tidyr)

na_col_rm <- function(x){
  indx <- apply(x, 2, function(y) all(is.na(y)))
  as_tibble(x[, !indx])
}

write_chapter <- function(data){
  
  # rebox contact
  .rebox <- function(k, name){
    idx <- grep(name, k)
    for(j in seq_along(idx)){
      iidx <- idx[j]
      if(!grepl("\\[", k[iidx] )){
        k[iidx] <- gsub(": ", ": [", k[iidx])
        if(grepl(",$", k[iidx])){
          k[iidx] <- gsub(",$", "],", k[iidx])
        }else{
          k[iidx] <- sprintf("%s]", k[iidx])
        }
        k[iidx] <- gsub("null", "", k[iidx])
        k[iidx] <- gsub("\\[\\{\\}\\]", "[]", k[iidx])
      }
    }
    k
  }
  
  .rmempty <- function(k){
    k[!grepl("\\{\\}", k)]
  }
  
  jsonlite::toJSON(
    data,
    pretty = TRUE,
    auto_unbox = TRUE
  ) |> 
    strsplit("\n") |> 
    unlist() |> 
    .rebox("current") |> 
    .rebox("former") |> 
    .rmempty () |> 
    writeLines(here::here("data", "chapters_meetup.json"))
}


some_cols <- c("meetup", "twitter", 
               "email", "facebook", 
               "instagram", "linkedin", 
               "periscope", "youtube", 
               "github", "website", 
               "slack", "mastodon")

meetup <- read_json(here("data", "meetup", "chapters.json"),
                    simplifyVector = TRUE) |> 
  bind_rows() |> 
  arrange(urlname)

chpt <- list.files(here("data", "chapters"), 
                   pattern = "json",
                   full.names = TRUE) |> 
  lapply(read_json,
         simplifyVector = TRUE) |> 
  bind_rows() |> 
  as_tibble() |> 
  unnest(cols = c(social_media, organizers)) |> 
  nest(
    social_media = any_of(some_cols),
    organizers = c(current, former)
  ) |> 
  mutate(
    urlname = tolower(urlname),
    urlname = gsub(" ", "", (urlname)),
    social_media = lapply(social_media, function(x){
      k <- na_col_rm(x)
      as.list(k)
    }),
    organizers = lapply(organizers, function(x){
      lapply(x, unlist)
    })
  ) |> 
  select(-city, -name) |> 
  left_join(meetup) |> 
  rowwise() |>
  mutate(
    name = if_else(
      any(state == "", is.na(state)),
      sprintf("R-Ladies %s", city),
      sprintf("R-Ladies %s, %s", city, state),
    ),
    country_acronym = toupper(country_acronym)
  ) |>
  ungroup() |>
  drop_na(urlname)


write_chapter(chpt)

chpt |> 
  filter(status == "active") |> 
  group_by(country) |> 
  tally() |> 
  summarise(
    chapters = sum(n),
    countries = n()
  ) |> 
  as.list() |> 
  write_json(
    here::here("data", "chapter_stats.json"),
    pretty = TRUE, auto_unbox = TRUE
  )
