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
  blogdown.subdir = "post",
  blogdown.title_case = TRUE,
  blogdown.hugo.version = "0.101.0"
)
