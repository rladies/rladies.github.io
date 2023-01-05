cat("Session is non-interactive. Starting meetup authentication process.\n")

key <- cyphr::key_sodium(sodium::hex2bin(Sys.getenv("MEETUPR_PWD")))
temptoken <- tempfile(fileext = ".rds")
cyphr::decrypt_file(
  here::here("scripts/secret.rds"),
  key = key,
  dest = temptoken
)

token <- readRDS(temptoken)[[1]]
token <- meetupr::meetup_auth(
  token = temptoken,
  cache = FALSE
) 

Sys.setenv(MEETUPR_PAT = temptoken)

cat("\t authenticating...\n\n")
k <- meetupr::meetup_auth(token = temptoken)
