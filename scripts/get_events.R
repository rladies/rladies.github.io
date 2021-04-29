
load_lib <- function(x){
  suppressPackageStartupMessages(
    library(x, character.only = TRUE)
  )
}

pkgs <- sapply(c("meetupr","tidyr", "dplyr", "purrr", "lubridate"),
               load_lib)

# If not running interactively, 
# get token decrypted from env var
if(!interactive()){
  source(here::here("scripts/meetup_auth.R"))
}

# Define helper functions ----
# Clean-up chapter name and create link
get_chapter <- function(x){
  y <- sapply(x, function(x) strsplit(x, "/")[[1]][4])
  unname(y)
}

str_count <- function(x)(
  strsplit(x, "")
)

# Force UTC timezone
force_utc <- function(datetime, tz){
  x <- as_datetime(datetime, tz = tz)
  with_tz(x, "UTC")
}

# default value if given is NA
`%||%` <- function(a, b) ifelse(!is.na(a), a, b)

get_events_pb <- function(x){
  k <- get_events(x, c( "upcoming"))
  k$urlname <- x
  k
}

## Get events ----

cat("Retrieving R-Ladies group information\n")
rladies_groups <- jsonlite::read_json(
  here::here("data/chapters.json"), 
  simplifyVector = TRUE
) %>% 
  unnest(chapters) %>% 
  filter(status == "active") %>% 
  transmute(group = name,
         urlname,
         chapter_id = id,
         lat, 
         lon, 
         timezone)
  

cat("\n\n Downloading chapter events\n")
new_events <- map_df(rladies_groups$urlname, get_events_pb) %>% 
  select(-resource)

# Read in existing json data
existing_events <- jsonlite::read_json(
  here::here("data/events.json"), 
  simplifyVector = TRUE
) %>% 
  filter(!id %in% new_events$id)


# Create df for json
events <- new_events %>% 
  left_join(rladies_groups) %>%
  transmute(
    id,
    chapter_id,
    title = name, 
    body = sprintf(
      "<i class='fa fa-users'></i>&emsp;%s<br><br>%s...  <br><br><center><a href='%s' target='_blank'><button class='btn btn-primary'>Event page</button></center></a>", 
      yes_rsvp_count,
      substr(description, 1, 300),
      link),
    start = as.character(force_tz(time, "UTC")),
    ds = lubridate::dmilliseconds(duration), 
    end = as.character(time + (ds %||% lubridate::dhours(2))),
    date = format(new_events$time, "%Y-%m-%d"),
    location = ifelse(
      is.na(venue_name), "Not announced",
      paste(venue_name, venue_address_1 %||% "", venue_city %||% "", toupper(venue_country) %||% "", sep=", ")),
    location = gsub(", , |, $", "", location),
    type = status,
    lat = venue_lat %||% lat,
    lon = venue_lon %||% lon,
    description
  ) %>%  
  select(-ds) %>%
  bind_rows(existing_events) %>%
  distinct()

cat("\t writing 'data/events.json'\n")
jsonlite::write_json(x = events, 
                     path = here::here("data/events.json"),
                     pretty = TRUE)

cat("Writing 'data/events_updated.json'\n")
jsonlite::write_json(x = data.frame(date = Sys.time(),
                                    n_events_past = filter(events, status == "past") %>% nrow(),
                                    n_chapters = nrow(rladies_groups)), 
                     path = here::here("data/events_updated.json"),
                     pretty = TRUE)


