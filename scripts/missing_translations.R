library(here)

content <- list.files(here("content"), "index",
                      recursive = TRUE,
                      full.names = TRUE)
content <- content[grepl("[.]md", content)]

dirs <- unique(dirname(content))

site_lang <- readLines(here("config/_default/languages.yaml"))
site_lang <- gsub(":", "", site_lang[grep("^[a-z]", site_lang)])
default_lang <- site_lang[1]
lang_pattern <- sprintf("\\.(%s)\\.md$", paste(site_lang, collapse = "|"))

if (length(site_lang) < 2) {
  cat("Only one site language; nothing to do.\n")
  quit(save = "no")
}

file_lang <- function(f) {
  m <- regmatches(f, regexpr(lang_pattern, f))
  if (length(m) == 0) default_lang else gsub("\\.md$|^\\.", "", m)
}

cat("Populating untranslated files:\n ")
for (k in dirs) {
  tmp <- content[grepl(k, content)]
  tmp_files <- basename(tmp)

  langs_present <- vapply(tmp_files, file_lang, character(1))
  missing_langs <- setdiff(site_lang, langs_present)
  if (length(missing_langs) == 0) next

  src_idx <- which(langs_present == default_lang)[1]
  if (is.na(src_idx)) src_idx <- 1
  orig_file <- tmp[src_idx]
  orig_lang <- langs_present[src_idx]
  has_lang_suffix <- grepl(lang_pattern, orig_file)
  orig_cont <- readLines(orig_file)

  idx <- grep("---", orig_cont)[2]
  yaml <- orig_cont[1:idx]
  yaml <- c(yaml[1:(length(yaml) - 1)],
            "translated: no",
            yaml[length(yaml)])
  if (!any(grepl("^language:", yaml))) {
    yaml <- c(yaml[1:(length(yaml) - 1)],
              paste("language:", orig_lang),
              yaml[length(yaml)])
  }

  for (lang in missing_langs) {
    if (has_lang_suffix) {
      new_file <- gsub(sprintf("[.]%s[.]", orig_lang),
                       sprintf(".%s.", lang),
                       orig_file)
    } else {
      new_file <- gsub("[.]md$", sprintf(".%s.md", lang), orig_file)
    }
    yaml2 <- gsub("language:.*$",
                  sprintf("language: %s", lang),
                  yaml)
    new_cont <- c(yaml2, orig_cont[-1:-idx], "")
    cat(new_file, "'\n")
    writeLines(new_cont, new_file)
  }
}

delete_non_translates <- function() {
  content <- list.files("content", "index",
                        recursive = TRUE,
                        full.names = TRUE)
  yaml <- lapply(content, readLines, 15)
  idx <- which(sapply(yaml, function(x) any(grepl("translated: no", x))))
  sapply(content[idx], file.remove)
}
