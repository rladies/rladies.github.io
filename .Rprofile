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

profile <- function(){
  profile <- strsplit(.libPaths(), "/")[[1]]
  idx <- grep("renv", profile)
  profile[idx[length(idx)]-1] 
}


cli::cli_h1("Welcome to the R-Ladies website code!")
cli::cli_alert(paste("renv profile:", profile()))
cli::cli_alert("Your libraries are located in:")
cli::cli_bullets(.libPaths())
