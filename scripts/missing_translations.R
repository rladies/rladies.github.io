
# Find all non-post content
content <- list.files("content","index", 
                      recursive = TRUE, 
                      full.names = TRUE)
content <- content[!grepl("/post|/placeholder",
                          content)]

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
content <- content[!grepl("/post|/placeholder",
                          content)]


# Get the unique directories
dirs <-  unique(dirname(content))


# Get the site languages
site_lang <- list.files("config/_default/menu/")
site_lang <- gsub("menu[.]|[.]toml", "", site_lang)


# Loop through dirs
for(k in dirs){
  tmp <- content[grepl(k, content)]
  tmp_files <- basename(tmp)
  
  j <- sapply(site_lang, function(x) grepl(x, tmp_files))
  
  en_file <- tmp[grep("index.en.md", tmp)]
  en_cont <- readLines(en_file)
  idx <- grep("---", en_cont)[2]
  yaml <- en_cont[1:idx]
  yaml <- c(yaml[1:(length(yaml)-1)], 
            "translated: no", 
            yaml[length(yaml)])
  
  for(lang in names(j)[which(!j)]){
    new_file <- gsub("[.]en[.]", 
                     sprintf(".%s.", lang), 
                     en_file)
    new_cont <- c(yaml, en_cont[-1:-idx], "")
    cat("Populating untranslated file '", new_file, "'\n")
    writeLines(new_cont, new_file)
  }
}
