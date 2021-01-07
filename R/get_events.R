library(meetupr)
library(dplyr)
library(purrr)
library(jsonlite)
library(lubridate)
library(progress)
library(here)

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

# Getting all the R-Ladies groups
rladies_groups <- find_groups("r-ladies") %>% 
  rbind(find_groups("rladies")) %>% 
  rbind(find_groups("r ladies")) %>% 
  distinct()

# Cleaning the list
rladies_groups <- filter(rladies_groups,
                         grepl("ladies", name, ignore.case = TRUE))

transmute(rladies_groups, 
          name, 
          id = urlname) %>% 
  distinct() %>% 
  jsonlite::write_json(path = here::here("data/events/calendars.json"),
                     pretty = TRUE)


## Get events ----

pb <- progress_bar$new(
  format = "  downloading [:bar] :elapsedfull",
  total = 1000, clear = FALSE, width= 100)
get_events_pb <- function(x){
  pb$tick()
  suppressMessages( 
    meetupr:::slowly_get_events(x, c("upcoming", "past"), verbose = FALSE)
  )
}

# Get all events
new_events <- map_df(rladies_groups$urlname, get_events_pb)
 
`%||%` <- function(a, b) ifelse(!is.na(a), a, b)

# Create df for json
events <- new_events %>% 
 transmute(
    calendarId = get_chapter(link),
    title = name, 
    body = sprintf(
      "<i class='fa fa-users'></i>&emsp;%s<br><br>%s...  <br><br><center><a href='%s' target='_blank'><buttonr>Event page</buttonr></center></a>", 
      yes_rsvp_count,
      substr(description, 1, 300),
      link),
    start = as.POSIXct(paste(local_date, local_time), format="%Y-%m-%d %H:%M"),
    ds = lubridate::dmilliseconds(duration), 
    end = start + ifelse(!is.na(ds), ds, lubridate::dhours(2)),
    location = ifelse(
      is.na(venue_name), "Not announced",
      paste(venue_name, venue_address_1 %||% "", venue_city %||% "", toupper(venue_country) %||% "", sep=", ")),
    location = gsub(", , |, $", "", location),
    type = status,
    lat = venue_lat,
    lon = venue_lon
  ) %>%  
  select(-ds) %>% 
  as_tibble() %>% 
  distinct()

jsonlite::write_json(x = events, 
                     path = here::here("data/events/schedule.json"),
                     pretty = TRUE)


