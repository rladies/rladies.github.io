
load_lib <- function(x){
  suppressPackageStartupMessages(
    library(x, character.only = TRUE)
  )
}

pkgs <- sapply(c("meetupr", "dplyr", "purrr", "lubridate", "progress"),
       load_lib)

# If not running interactively, 
# get token decrypted from env var
if(!interactive()){
  cat("Session is non-interactive. Starting meetup authentication process.\n")
  
  key <- cyphr::key_sodium(sodium::hex2bin(Sys.getenv("MEETUPR_PWD")))
  temptoken <- tempfile(fileext = ".rds")
  cyphr::decrypt_file(
    here::here("R/secret.rds"),
    key = key,
    dest = temptoken
  )
  
  token <- readRDS(temptoken)[[1]]
  token <- meetup_auth(
    token = temptoken,
    set_renv = FALSE,
    cache = FALSE
  ) 
  
  Sys.setenv(MEETUPR_PAT = temptoken)
  
  cat("\t authenticating...\n\n")
  k <- meetup_auth(token = temptoken)
}

# Cleanup chapter name and create link
get_chapter <- function(x){
  cpt <- unname(sapply(x, function(x) strsplit(x, "/")[[1]][4]))
  
  url <- unname(lapply(x, function(x) strsplit(x, "/")[[1]][1:4]))
  url <- sapply(url, paste, collapse = '/')
  
  k <- dplyr::tibble(
    cpt = cpt, 
    url = url
  ) %>% 
    mutate(
      html = paste0("<a href='", url, "'>", cpt, "</a>")
    )
  
  # not working :(
  # k$html
  k$cpt
}

str_count <- function(x)(
  strsplit(x, "")
)

cat("Retrieving R-Ladies group information\n")
# Better than getting pro groups, because we want timezone...
rladies_groups <- find_groups("r-ladies") %>% 
  filter(organizer_name == "R-Ladies Global") %>% 
  distinct()


cat("\t writing 'data/events/calendars.json\n'")
transmute(rladies_groups, 
          name, 
          id = urlname,
          country,
          state, 
          city,
          members,
          status,
          lat,
          lon,
          timezone) %>% 
  distinct() %>% 
  jsonlite::write_json(path = here::here("data/events/calendars.json"),
                     pretty = TRUE)

## Get events ----

# Go through all chapters and get events upcoming and past
# suppressing  meetupr download message but adding
# a progressbar instead.
cat("\n\n Downloading chapter events\n")
if(interactive())
  pb <- progress_bar$new(
    format = "  Downloading chapter events [:bar] :elapsedfull",
    total = nrow(rladies_groups), clear = FALSE, width= 100)

get_events_pb <- function(x){
  k <- get_events(x, "upcoming")
  k$urlname <- x
  k
}

# Get all events
new_events <- map_df(rladies_groups$urlname, get_events_pb)

# Join with groups, to convert all events to UTC.
new_events <- new_events %>% 
  left_join(select(rladies_groups, -name, -id, -created, -status, -resource))


existing_events <- jsonlite::read_json(here::here("data/events/schedule.json"), 
                                       simplifyVector = TRUE) %>% 
  filter(!id %in% new_events$id)


force_utc <- function(datetime, tz){
  x <- as_datetime(datetime, tz = tz)
  with_tz(x, "UTC")
}

`%||%` <- function(a, b) ifelse(!is.na(a), a, b)

# Create df for json
events <- new_events %>% 
 transmute(
    id,
    calendarId = get_chapter(link),
    title = name, 
    body = sprintf(
      "<i class='fa fa-users'></i>&emsp;%s<br><br>%s...  <br><br><center><a href='%s' target='_blank'><buttonr>Event page</buttonr></center></a>", 
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

cat("\t writing 'data/events/schedule.json'\n")
jsonlite::write_json(x = events, 
                     path = here::here("data/events/schedule.json"),
                     pretty = TRUE)

cat("Writing 'data/events/last_updated.json'\n")
jsonlite::write_json(x = data.frame(date = Sys.time(),
                                    n_events_past = filter(events, type == "past") %>% nrow(),
                                    n_chapters = nrow(rladies_groups)), 
                     path = here::here("data/events/last_updated.json"),
                     pretty = TRUE)



