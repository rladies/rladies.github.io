library(dplyr)
library(stringr)
events <- jsonlite::read_json(
  here::here("data/meetup/events.json")
) |> 
  lapply(as.data.frame, 
         stringsAsFactors = FALSE) |> 
  bind_rows() |> 
  transmute(
    title, 
    description = str_sub(description,
                          1, 200), 
    date,
    url = sprintf(
      "https://www.meetup.com/%s/events/%s",
      group_urlname,
      id)
  )

config <- readLines(here::here("config/_default/config.toml"))

strip_config <- function(x, key){
  url <- strsplit(config[grep(key, config)], "=")[[1]][2]
  gsub("\"|^\ |\ ^", "", url)
}

url <- strip_config(config, "baseURL")

xml <- c('<?xml version="1.0" encoding="UTF-8"?>',
         '\t<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">',
         '\t<channel>',
         '\t\t<title>R-Ladies Events</title>',
         '\t\t<description>Feed of R-Ladies events</description>',
         sprintf('\t\t<link>%s/</link>', url),
         sprintf('\t\t<atom:link href="%s/events/index.xml" rel="self" type="application/rss+xml"/>', url),
         sprintf('\t\t<pubDate>%s</pubDate>', Sys.Date())
)

for(i in 1:nrow(events)){
  tmp <- events[i,]
  xi <- c(
    '\t\t<item>',
    sprintf('\t\t\t<title>%s</title>', tmp$title),
    sprintf('\t\t\t<description>%s</description>', tmp$description),
    sprintf('\t\t\t<pubDate>%s</pubDate>', tmp$date),
    sprintf('\t\t\t<link>%s</link>', tmp$url),
    '\t\t</item>'
  )
  xml <- c(xml, xi)
}

xml <- c(
  xml,
  '\t</channel>',
  '</rss>'
)

writeLines(
  xml,
  here::here(
    "content/activities/events/index.xml"
  )
)
