#' Automatically translate a text file using DeepL API.
#'
#' @description
#' The `autotranslate` function translates a specified text file from the source
#' language to the target language using the `babeldown::deepl_translate_hugo`
#' function. It processes YAML fields for metadata translation, adds custom
#' YAML fields to indicate the translation status, and saves the translated file.
#'
#' @param to_lang A string specifying the target language (e.g., "en", "fr").
#' @param from_lang A string specifying the source language (e.g., "en", "de").
#' @param file A string specifying the file path of the text file to translate.
#'
#' @return
#' Nothing is returned. The translated file is saved to disk as a new file,
#' with the target language in its name.
#'
#' @examples
#' # Translate a file from English to French:
#' autotranslate("fr", "en", "posts/my_post.en.md")
#'
#' # Translate a file from German to English:
#' autotranslate("en", "de", "posts/article.de.md")
#'
#' @export
autotranslate <- function(to_lang, from_lang, file) {
  cat("  ", from_lang, "-->", to_lang, "\n ")

  new_file <- gsub(
    sprintf("[.]%s[.]", from_lang),
    sprintf(".%s.", to_lang),
    file
  )

  if (!file.exists(new_file)) {
    # Make sure file is sentence wrapped, for best translation.
    aeolus::unleash(file)

    deepl <- babeldown::deepl_translate_hugo(
      post_path = file,
      yaml_fields = c("title", "description", "summary"),
      glossary_name = NULL,
      source_lang = from_lang,
      target_lang = ifelse(to_lang == "pt", "pt-pt", to_lang),
      formality = "default",
    )

    # Add custom yaml to indicate auto translation
    deepl <- c(
      "---",
      sprintf("language: %s", to_lang),
      sprintf("translated: no"),
      deepl[2:(length(deepl))]
    )

    writeLines(deepl, new_file)
  }
}

# Get all index mds
index_files <- list.files(
  here::here("content/news"),
  "^index",
  recursive = TRUE,
  full.names = TRUE
)
index_files <- index_files[grepl("[.]md", index_files)]

bundles <- unique(dirname(index_files))

# Get the site languages
site_lang <- readLines(here::here("config/_default/languages.yaml"))
site_lang <- gsub(":", "", site_lang[grep("^[a-z]", site_lang)])

# Loop through dirs
for (bundle in bundles[2:length(bundles)]) {
  bundle_index <- index_files[grepl(bundle, index_files)]
  source_file <- bundle_index[1]

  j <- sapply(site_lang, function(x) {
    grepl(sprintf("[.]%s[.]md$", x), bundle_index)
  })
  if (!is.null(dim(j))) j <- apply(j, 2, any)
  if (all(j == FALSE)) {
    j["en"] <- TRUE
  }
  orig_lang <- names(j[j])[1]

  if (!grepl(sprintf("[.]%s[.]md", orig_lang), source_file)) {
    tmpf <- source_file
    source_file <- sprintf(
      "%s.%s.md",
      tools::file_path_sans_ext(source_file),
      orig_lang
    )
    file.rename(tmpf, source_file)
  }

  cat("Translating", source_file, "\n ")
  k <- lapply(
    names(j[!j]),
    autotranslate,
    from_lang = orig_lang,
    file = source_file
  )
  cat("\n ")
}

# If you've generated non-translated content to
# check out how it looks. Delete them again by
# running this function.
delete_autotranslated <- function() {
  # Find all non-post content
  content <- list.files("content", "index", recursive = TRUE, full.names = TRUE)
  yaml <- lapply(content, readLines, 15)

  idx <- which(sapply(yaml, function(x) {
    any(grepl("translated: no", x))
  }))

  sapply(content[idx], file.remove)
}
# delete_autotranslated()
