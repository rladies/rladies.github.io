coc_url <- "https://raw.githubusercontent.com/rladies/.github/master/CODE_OF_CONDUCT.md"
coc <- readLines(coc_url)

# set content dir for coc
coc_dir <- "content/coc/"
dir.create(coc_dir)

# Search for languages in the first few rows
lang <- coc[grep("\\* \\[", coc[1:20])]
lang <- strsplit(lang, "\\[|\\]")
lang <- sapply(lang, function(x) x[2])

# get indexes of where the different languages begin
lang_ind <- sapply(lang, function(x){
  grep(x, coc)[-1]
})

# define yaml
yaml <- c("---", "type: coc", "---")

# loop through to create coc files
coc_lang <- list()
for(i in 1:length(lang_ind)){
  # define the start of content
  # drop the header
  start <- lang_ind[i]+1
  
  # define the last line
  end <- if((i+1) > length(lang_ind)){
    length(coc)
  }else{
    lang_ind[i+1]-1
  }
  
  # concatenate with yaml
  coc_lang[[i]] <- c(yaml,
                     coc[start:end])
  
  # define language acronym
  short <- switch(lang[i],
                  Portuguese = "pt",
                  English = "en",
                  Spanish = "es")
  
  # define filename
  filename <- sprintf("%s/index.%s.md", 
                      coc_dir, short)
  names(coc_lang)[i] <- filename
  
  # write the content file
  writeLines(coc_lang[[i]], here::here(filename))
  
}


