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

#' Translate Content Files in a Folder
#'
#' This function identifies content files in a specified folder and translates them
#' into all languages defined in the site configuration ("languages.yaml"). It detects
#' untranslated files based on file naming patterns and calls the `autotranslate`
#' function for automatic translation.
#'
#' @param folder Character. The directory containing content files to process.
#' @param pattern Character. A regex pattern to identify index files (e.g., "index.md").
#'
#' @return This function performs actions on the filesystem and does not return a value.
#'
#' @description
#' The function scans the `folder` for content files matching `pattern`, groups files into
#' bundles, identifies missing translations, and translates them. It uses the site languages
#' defined in the "config/_default/languages.yaml" file and ensures that each file bundle has
#' translations for all target languages. If a "source" language is not explicitly specified
#' in the filename, the function renames it to include the source language code.
#'
#' If a file has no translations, it will be auto-translated from the source language.
#'
#' @note The function uses the `autotranslate` helper for translations. The `autotranslate`
#'       function must be implemented beforehand for this to work. Files are renamed and
#'       translated in
#'
#' @examples
#' # Translate all "index.md" files in the "content" folder
#' translate_content(folder = "content", pattern = "index.md")
translate_content <- function(folder, pattern) {
  # Get all index mds
  index_files <- list.files(
    folder,
    pattern,
    recursive = TRUE,
    full.names = TRUE
  )

  bundles <- unique(dirname(index_files))

  # Get the site languages
  site_lang <- readLines(here::here("config/_default/languages.yaml"))
  site_lang <- gsub(":", "", site_lang[grep("^[a-z]", site_lang)])

  # Loop through dirs
  for (bundle in bundles) {
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

    to_translate <- names(j[!j])
    if (length(to_translate) > 0) {
      cat("Translating", source_file, "\n ")
      k <- lapply(
        to_translate,
        autotranslate,
        from_lang = orig_lang,
        file = source_file
      )
      Sys.sleep(10)
      cat("\n ")
    }
  }
}

#' Delete Auto-Translated Content Files
#'
#' This function identifies and deletes content files within the "content"
#' directory that are marked as "translated: no" in their YAML front matter.
#' It is designed to help clean up auto-translated content that is deemed
#' unnecessary or incomplete.
#'
#' @return This function does not return any value. It performs an action by
#'         removing specific files from the filesystem.
#'
#' @note This function permanently deletes files. Use with caution.
#'
#' @examples
#' # To delete all files in the "content" directory marked "translated: no":
#' delete_autotranslated()
delete_autotranslated <- function() {
  # Find all non-post content
  content <- list.files("content", "index", recursive = TRUE, full.names = TRUE)
  yaml <- lapply(content, readLines, 15)

  idx <- which(sapply(yaml, function(x) {
    any(grepl("translated: no", x))
  }))

  sapply(content[idx], file.remove)
}

translate_content(
  here::here("content/about-us"),
  "[.]md$"
)
# delete_autotranslated()
