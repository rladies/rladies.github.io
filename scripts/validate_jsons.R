validate_jsons <- function(files, schema){
  validate <- jsonvalidate::json_validator(schema)

  k <- sapply(files, 
              validate,
              verbose = TRUE, 
              error = FALSE, 
              greedy = TRUE)

  
  if(any(!k)){
    k <- k[!k]
    errs <- attr(k, "errors", TRUE)
    stop(
      "Some jsons are not formatted correctly\n",
      paste(" ", errs$field, errs$message, "\n"),
      call. = FALSE
    )
  }
}

#  Validate mentoring json
validate_jsons(
  list.files(here::here("data/mentoring/"), full.names = TRUE),
  here::here("scripts/json_shema/mentoring.json")
)

#  Validate global team json
validate_jsons(
  list.files(here::here("data/global_team"), 
             full.names = TRUE, recursive = TRUE),
  here::here("scripts/json_shema/global-team.json")
)
