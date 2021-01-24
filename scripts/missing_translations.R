
# Find all non-post content
content <- list.files("content","index", 
                      recursive = TRUE, 
                      full.names = TRUE)  
content <- content[grepl("[.]md", content)]

# Find content that is not translated
content_translated <- sapply(content, 
                       function(x){
                         y <- readLines(x)
                         y <- y[grep("translated:", y)]
                         !any(grepl("no", y))
                       })

# Delete non-translated content
# To update in-case english content has changed.
idx <- which(!content_translated)
invisible(file.remove(names(idx)))

# Get again all mds, now that we have deleted some
# Find all non-post content
content <- list.files("content","index", 
                      recursive = TRUE, 
                      full.names = TRUE)
content <- content[grepl("[.]md", content)]

# Get the unique directories
dirs <-  unique(dirname(content))


# Get the site languages
site_lang <- list.files("config/_default/menu/")
site_lang <- gsub("menu[.]|[.]toml", "", site_lang)

cat("Populating untranslated files:\n ")
# Loop through dirs
for(k in dirs){
  tmp <- content[grepl(k, content)]
  tmp_files <- basename(tmp)
  
  j <- sapply(site_lang, function(x) grepl(x, tmp_files))
  
  orig_file <- tmp[1]
  orig_cont <- readLines(orig_file)
  orig_lang <- sapply(sprintf(".%s.", site_lang), grepl, x = tmp)
  orig_lang <- site_lang[orig_lang]
  
  idx <- grep("---", orig_cont)[2]
  yaml <- orig_cont[1:idx]
  yaml <- c(yaml[1:(length(yaml)-1)], 
            "translated: no", 
            yaml[length(yaml)])
  
  for(lang in names(j)[which(!j)]){
    new_file <- gsub(sprintf("[.]%s[.]", orig_lang), 
                     sprintf(".%s.", lang), 
                     orig_file)
    new_cont <- c(yaml, orig_cont[-1:-idx], "")
    cat("... '", new_file, "'\n")
    writeLines(new_cont, new_file)
  }
}
