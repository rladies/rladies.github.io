# Get all mds
# Find all non-post content
library(here)
content <- list.files(here("content"),"index", 
                      recursive = TRUE, 
                      full.names = TRUE)
content <- content[grepl("[.]md", content)]

# Get the unique directories
dirs <-  unique(dirname(content))

# Get the site languages
site_lang <- readLines(here("config/_default/languages.yaml"))
site_lang <- gsub(":", "", site_lang[grep("^[a-z]", site_lang)])
cat("Populating untranslated files:\n ")
# Loop through dirs
for(k in dirs){
  tmp <- content[grepl(k, content)]
  tmp_files <- basename(tmp)
  
  j <- sapply(site_lang, function(x) grepl(x, tmp_files))
  if(!is.null(dim(j)))
    j <- apply(j, 2, any)
  j <- j[!j]
  
  orig_file <- tmp[1]
  orig_cont <- readLines(orig_file)
  orig_lang <- sapply(sprintf("\\.%s\\.", site_lang), grepl, x = orig_file)
  orig_lang <- site_lang[orig_lang]
  
  idx <- grep("---", orig_cont)[2]
  yaml <- orig_cont[1:idx]
  yaml <- c(yaml[1:(length(yaml)-1)], 
            "translated: no", 
            yaml[length(yaml)])
  yaml <- c(yaml[1:(length(yaml)-1)], 
            paste("language:", orig_lang), 
            yaml[length(yaml)])
  
  for(lang in names(j)){
    new_file <- gsub(sprintf("[.]%s[.]", orig_lang), 
                     sprintf(".%s.", lang), 
                     orig_file)
    yaml2 <- gsub(sprintf("language: %s", orig_lang), 
                  sprintf("language: %s", lang), 
                  yaml)
    new_cont <- c(yaml2, orig_cont[-1:-idx], "")
    cat(new_file, "'\n")
    writeLines(new_cont, new_file)
  }
}

# If you've generated non-translated content to
# check out how it looks. Delete them again by 
# running this function.
delete_non_translates <- function(){
  # Find all non-post content
  content <- list.files("content","index", 
                        recursive = TRUE, 
                        full.names = TRUE)
  yaml <- lapply(content, 
                 readLines, 
                 15)
  
  idx <- which(sapply(yaml, function(x){
    any(grepl("translated: no", x))
  }))
  
  sapply(content[idx], file.remove)
}
# delete_non_translates()
