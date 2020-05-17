library(meetupr)
library(dplyr)
library(purrr)
library(stringr)
library(here)

meetup_auth()

# Mo's pro functions suddenly not working any more. 
# new_events <- get_pro_events("rladies") %>% 
#   mutate(type = "planned" )
# 
# past_events <- get_pro_events("rladies", "past") %>% 
#   mutate(type="past")

slowly_get_events <- purrr::slowly(
  meetupr::get_events,
  rate = purrr::rate_delay(pause = .3,
                           max_times = Inf)
)

get_chapter <- function(x){
  cpt <- unname(sapply(x, function(x) str_split(x, "/")[[1]][4]))
  
  url <- unname(lapply(x, function(x) str_split(x, "/")[[1]][1:4]))
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
all_rladies_groups <- find_groups(text = "r-ladies")

# Cleaning the list
rladies_groups <- all_rladies_groups[grep(pattern = "rladies|r-ladies", 
                                          x = all_rladies_groups$name,
                                          ignore.case = TRUE), ]

new_events <- map_df(rladies_groups$urlname,
                  ~ slowly_get_events(.x, c("upcoming", "past")))
 
events <- new_events %>% 
 transmute(
    calendarId = get_chapter(link),
    title = name, 
    body = paste0(
      "<i class='fa fa-users'></i>&emsp;", yes_rsvp_count,
      "<br><br>",
      str_sub(description,1,300),
      "...  <br><br> <a href='", link, 
      "' target='_blank'><button class='button'>Event page</button></a>"),
    start = as.POSIXct(paste(local_date, local_time), format="%Y-%m-%d %H:%M"),
    # end = start,
    location = ifelse(
      is.na(venue_name), "Not announced",
      paste(venue_name, venue_address_1, venue_city, str_to_upper(venue_country), sep=", ")),
    category = "time",
    type = status,
    lat = venue_lat,
    lon = venue_lon
  ) %>%  
  as_tibble()

write.csv(events, here("content/events.csv"), row.names = FALSE)
