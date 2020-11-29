library(dplyr)
library(tidyr)

tabular <- dplyr::tribble(
  ~ name,                   ~ city,  ~ country, ~twitter,        ~github,       ~webpage,              ~interests,
  "Athanasia M. Mowinckel", "Oslo",  "Norway",  "@DrMowinckels", "Athanasiamo", "www.drmowinckels.io", "lots of them, another one, a third",
  "Maëlle Salmon",          "Nancy", "France",  "@ma_salmon",     NA,            NA,                   "All things dev"
) %>%
  mutate(id = gsub(" ", "-", paste(name, city, country, sep = "_")),
         interests = strsplit(interests, ",")
         ) %>%
  nest_by(id)


jsons <- jsonlite::toJSON(tabular$data, pretty = TRUE)

j <- mapply(jsonlite::write_json,
       x = tabular$data,
       path = sapply(tabular$id, function(x) here::here(paste0("directory/jsons/", x, ".json"))),
       pretty = TRUE
       )
