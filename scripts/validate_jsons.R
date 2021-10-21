validate_jsons <- function(files, schema){
  catch_error <- function(x){
    tryCatch(
      jsonvalidate::json_validate(
        x,
        error = TRUE,
        schema = schema
      ),
      error = function(e) list(e)
    )
  }
  
  k <- sapply(files, catch_error)
  k <- k[!sapply(k, is.null)]
  
  if(length(k) > 0){
    names(k) <- basename(names(k))
    k <- sapply(1:length(k), 
                function(x) 
                  sprintf("%s: %s", 
                          names(k)[x], 
                          k[[x]]$message
                  )
    )
    
    stop(
      "Some jsons are not formatted correctly\n",
      paste(k, collapse = "\n"),
      call. = FALSE
    )
  }
}

#  Validate mentoring json
validate_jsons(
  list.files(here::here("data/mentoring.json"), full.names = TRUE),
  here::here("scripts/json_shema/mentoring.json")
)

#  Validate global team json
validate_jsons(
  here::here("data/global_team.json"),
  here::here("scripts/json_shema/global-team.json")
)
