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


some_cols <- c("meetup", "twitter", "email", "facebook", "instagram", "linkedin", 
               "periscope", "youtube", "github", "website", "slack", "mastodon")

meetup <- read_json(here("data", "meetup", "chapters.json"),
                    simplifyVector = TRUE) |> 
  bind_rows()

chpt <- list.files(here("data", "chapters"), "json", full.names = TRUE) |> 
  lapply(read_json,
         simplifyVector = TRUE) |> 
  bind_rows() |> 
  as_tibble() |> 
  unnest(cols = c(social_media, organizers)) |> 
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
  select(-city)

chpt |> 
  left_join(meetup, by = "urlname") |> 
  write_chapter()
  
  
