library(dplyr)
library(jsonlite)

url <- "https://raw.githubusercontent.com/rladies/starter-kit/master/global-team.csv"
gt <- read.csv(url) %>%
  mutate(
    role = strsplit(role, "; ")
  ) %>% 
  as_tibble()

jsonlite::write_json(
  gt,
  here::here("data/global_team.json"),
  simplifyVector = TRUE,
  pretty = TRUE
)
