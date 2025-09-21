validate_jsons <- function(files, schema) {
  validate <- jsonvalidate::json_validator(schema)

  .val <- function(x) {
    z <- tryCatch(
      validate(x, verbose = TRUE, error = FALSE, greedy = TRUE),
      error = function(e) e
    )

    msg <- NA

    if (!is.logical(z)) {
      msg <- sprintf("json error: '%s'", z$message)
      z <- FALSE
    } else if (!z) {
      errs <- attr(z, "errors", TRUE)
      msg <- sprintf("'%s' %s", errs$field, errs$message)
    }
    list(
      success = z,
      msg = sprintf("%s: %s", basename(x), msg) |>
        paste(collapse = "\n")
    )
  }
  k <- lapply(files, .val)
  names(k) <- basename(files)

  idx <- which(!sapply(k, function(x) x$success))
  j <- sapply(idx, function(x) k[[x]]$msg)

  if (length(j) > 0) {
    cat(paste(j, collapse = "\n"))
    cat("\n")
    stop("json validation failed", call. = FALSE)
  }
}

#  Validate mentoring json
validate_jsons(
  list.files(here::here("data/mentoring/"), full.names = TRUE),
  here::here("scripts/json_shema/mentoring.json")
)

#  Validate global team json
validate_jsons(
  list.files(
    here::here("data/global_team"),
    full.names = TRUE,
    recursive = TRUE
  ),
  here::here("scripts/json_shema/global-team.json")
)

#  Validate chapters json
validate_jsons(
  list.files(here::here("data/chapters"), full.names = TRUE, recursive = TRUE),
  here::here("scripts/json_shema/chapter.json")
)
