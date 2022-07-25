source(here::here("scripts/utils.R"))

pkgs <- sapply(c("meetupr","tidyr", "dplyr", "lubridate"),
               load_lib)

# grab upcoming events
get_events_pb <- function(x){
  cat(x , sep="\n")
  k <- get_events(x)
  k$urlname <- x
  if(!is.null(k)){
    k$id <- as.character(k$id)
  }
  k
}

## Get events ----
cat("Retrieving R-Ladies group information\n")
rladies_groups <- jsonlite::read_json(
  here::here("data/chapters.json"), 
  simplifyVector = TRUE
) |> 
  unnest(chapters) |> 
  filter(status == "active",
         !is.na(urlname)) |> 
  transmute(group = name,
         urlname,
         chapter_id = id,
         lat, 
         lon, 
         timezone)
  

cat("\n\n Downloading chapter events\n")
new_events <- lapply(rladies_groups$urlname, get_events_pb) 
new_events <-  new_events |> 
  bind_rows() |> 
  filter(status %in% c("published"))

# Read in existing json data
existing_events <- jsonlite::read_json(
  here::here("data/events.json"), 
  simplifyVector = TRUE
) |> 
  filter(!id %in% new_events$id)


# Create df for json
events <- new_events |> 
  left_join(rladies_groups) |>
  transmute(
    id,
    chapter_id,
    title = title, 
    body = sprintf(
      "<h3 class='entry-title'>%s<h3><i class='fa fa-users'></i>&emsp;%s<br><br>%s...  <br><br><center><a href='%s' target='_blank'><button class='btn btn-primary'>Event page</button></center></a>", 
      title,
      going,
      substr(description, 1, 300),
      link),
    start = as.character(force_tz(time, "UTC")),
    ds = lubridate::as.duration(new_events$duration), 
    end = as.character(time + (ds %||% lubridate::dhours(2))),
    date = format(new_events$time, "%Y-%m-%d"),
    location = ifelse(
      is.na(venue_name), "Not announced",
      paste(venue_name, venue_address %||% "", venue_city %||% "", toupper(venue_country) %||% "", sep=", ")),
    location = gsub(", , |, $", "", location),
    type = status,
    lat = venue_lat %||% lat,
    lon = venue_lon %||% lon,
    description
  ) |>  
  select(-ds) |>
  bind_rows(existing_events) |>
  distinct()

cat("\t writing 'data/events.json'\n")
jsonlite::write_json(x = events, 
                     path = here::here("data/events.json"),
                     pretty = TRUE)

cat("Writing 'data/events_updated.json'\n")
jsonlite::write_json(x = data.frame(date = Sys.time(),
                                    n_events_past = filter(events, type  == "past") |> nrow(),
                                    n_chapters = nrow(rladies_groups)), 
                     path = here::here("data/events_updated.json"),
                     pretty = TRUE)
