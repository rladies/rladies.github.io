# Generate new token for meetupr auth
token_path <- "~/.rladies_meetup_token.rds"
usethis::use_build_ignore(token_path)
usethis::use_git_ignore(token_path)

meetupr::meetup_auth(
  token = NULL,
  cache = TRUE,
  use_appdir = FALSE,
  token_path = token_path
)

sodium_key <- sodium::keygen()

# save an environment secret in the repo
# "MEETUPR_PWD" = sodium::bin2hex(sodium_key)

# key <- cyphr::key_sodium(sodium::hex2bin(sodium::bin2hex(sodium_key)))

cyphr::encrypt_file(
  token_path,
  key = key,
  dest = "scripts/secret.rds"
)
