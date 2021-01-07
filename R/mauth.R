key <- cyphr::key_sodium(sodium::hex2bin(Sys.getenv("MEETUPR_PWD")))
temptoken <- tempfile(fileext = ".rds")
cyphr::decrypt_file(
  testthat::test_path("R/secret.rds"),
  key = key,
  dest = temptoken
)

token <- readRDS(temptoken)[[1]]
token <- meetupr::meetup_auth(
  token = token,
  set_renv = FALSE,
  cache = FALSE
) 

Sys.setenv(MEETUPR_PAT = temptoken)
