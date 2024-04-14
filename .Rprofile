source("renv/activate.R")

# Project Renvironment in this case must take
# precedent over user Renvironment.
if (file.exists("~/.Rprofile")) {
  base::sys.source("~/.Rprofile", envir = environment())
}

options(
  blogdown.method = 'markdown',
  blogdown.new_bundle = TRUE,
  blogdown.knit.on_save = FALSE,
  blogdown.ext = ".Rmd",
  blogdown.subdir = "blog",
  blogdown.title_case = TRUE,
  blogdown.hugo.version = "0.111.2",
  
  renv.config.sandbox.enabled = FALSE,
  renv.config.auto.snapshot = FALSE
)

if(interactive()){
  cat(
    "",
    "This project uses different renv profiles for different operations",
    "You should be on the default profile if you are contributing a blogpost",
    " - `renv::activate('json')` enables profile with packages for json validation",
    " - `renv::activate('production')` enables profile with packages needed to build the website",
    " - `renv::activate('dev')` enables profile with all packages working locally on the website",
    "",
    sep="\n"
  )
}
