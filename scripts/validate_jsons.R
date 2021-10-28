validate_jsons <- function(files, schema){
  validate <- jsonvalidate::json_validator(
    schema)

  k <- validate(files, 
                verbose = TRUE, 
                error = TRUE, 
                greedy = TRUE)
  
  if(any(!k)){
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
  here::here("data/global_team.json"),
  here::here("scripts/json_shema/global-team.json")
)
