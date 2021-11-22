library(dplyr)
library(jsonlite)

filename <- function(x){
  sapply(x, function(x){
    x <- gsub(tools::file_ext(x), "", x)
    gsub("\\.$", "", x)
  })
}

save_json <- function(dt, filename){
  
  path <- here::here("data", "global_team")
  if(!is.na(dt$end)){
    path <- file.path(path, "alumni")
  }else{
    path <- file.path(path, "current")
  }
  if(!dir.exists(path)) dir.create(path, recursive = TRUE)
  path <- sprintf("%s/%s.json", path, filename)
  k <- jsonlite::toJSON(
    dt,
    auto_unbox = FALSE,
    pretty = TRUE
  )
  
  # unbox the single json
  k <- strsplit(k, "\n")[[1]]
  k <- k[2:(length(k)-1)]
  writeLines(k, path)
}

urls <- c("https://raw.githubusercontent.com/rladies/starter-kit/master/global-team.csv",
          "https://raw.githubusercontent.com/rladies/starter-kit/master/global-team-alumni.csv")
gt <- lapply(urls, read.csv) %>% 
  bind_rows() %>% 
  mutate(
    role = strsplit(role, ";"),
    nm = filename(img)
  ) %>% 
  nest_by(nm) 

lapply(1:nrow(gt), function(x){
  save_json(gt$data[[x]], gt$nm[x])
})

