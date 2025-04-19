#' Get Site Languages from Configuration
#'
#' This function reads the `languages.yaml` file from the site's configuration and
#' extracts the list of language codes defined for the site. It is used to identify
#' the supported languages for content translation or other operations.
#'
#' @return A character vector containing the site language codes as defined in
#'         "config/_default/languages.yaml". Language codes are stripped of trailing colons.
#'
#' @description
#' The function reads the "languages.yaml" file, finds lines starting with lowercase
#' alphabets (assumed to correspond to language codes), removes trailing colons, and
#' returns them as a vector.
#'
#' @note This function requires the `here` package to locate the configuration file.
#'       Ensure the "languages.yaml" file exists at "config/_default/languages.yaml".
#'
#' @examples
#' # Get the list of supported site languages
#' site_languages <- get_site_lang()
#' print(site_languages)

get_site_lang <- function() {
  readLines(
    here::here(
      "config/_default/languages.yaml"
    )
  )
  gsub(
    ":",
    "",
    site_lang[grep("^[a-z]", site_lang)]
  )
}

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
      target_lang = switch(
        to_lang,
        "pt" = "pt-pt",
        "en" = "en-us",
        to_lang
      ),
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
#' translate_all(folder = "content", pattern = "index.md")
translate_all <- function(folder, pattern) {
  # Get all index mds
  index_files <- list.files(
    folder,
    pattern,
    recursive = TRUE,
    full.names = TRUE
  )

  # Don't run sections
  index_files <- index_files[!grepl("_index", index_files)]

  bundles <- unique(dirname(index_files))
  bundles <- lapply(bundles, function(x) {
    index_files[grepl(x, index_files)]
  })
  k <- lapply(bundles, translate_content)
}


#' Translate Content for Multiple Site Languages
#'
#' This function translates a given Markdown content file (`bundle`) into multiple
#' language versions available in the site configuration. Translations are generated
#' for site languages as needed when matching files do not already exist in the `bundle`.
#'
#' @param bundle A character vector containing file paths. The first element represents
#' the source content file, and the rest are related file paths if applicable.
#' @return None. The function translates the content and writes language-specific files
#' in place. It also renames the input file if necessary to align with the detected
#' source language format.
#'
#' @details
#' - Determines the site's configured languages by calling `get_site_lang()`.
#' - Identifies which language files already exist in `bundle`.
#' - If the English version (`en`) isn't found, it is assumed as the default source.
#' - Renames the source file if it does not match the detected language format.
#' - Automatically translates the content into missing language variants using the
#' `autotranslate()` function, specifying the original and target languages.
#'
#' @examples
#' # Example: Translating a file bundle to other languages
#' bundle <- c("content/example.md", "content/example.es.md")
#' translate_content(bundle)
#'
#' # Example: No translations exist; assumes 'en' as the default language
#' bundle <- c("content/example.md")
#' translate_content(bundle)
translate_content <- function(bundle) {
  source_file <- bundle[1]

  # Get the site languages
  site_lang <- get_site_lang()

  j <- sapply(site_lang, function(x) {
    grepl(sprintf("[.]%s[.]md$", x), bundle)
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

list.files(
  here::here("content/news"),
  "[.]md$",
  full.names = TRUE
) |>
  translate_content()

translate_all(
  folder = here::here("content/news"),
  pattern = "[.]md$"
)
# delete_autotranslated()
