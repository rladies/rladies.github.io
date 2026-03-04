library(here)
library(yaml)

get_site_languages <- function() {
  lines <- readLines(here("config/_default/languages.yaml"))
  gsub(":", "", lines[grep("^[a-z]", lines)])
}

deepl_source_lang <- function(lang) {
  toupper(lang)
}

deepl_target_lang <- function(lang) {
  switch(lang,
    "pt" = "PT-PT",
    "en" = "EN-US",
    toupper(lang)
  )
}

detect_source_lang <- function(file) {
  lang_pattern <- "\\.(en|es|pt|fr)\\.md$"
  m <- regmatches(basename(file), regexpr(lang_pattern, basename(file)))
  if (length(m) == 0) return(NULL)
  gsub("^\\.|\\.[^.]+$", "", m)
}

glossary_name_for <- function(source_lang, target_lang) {
  sprintf("rladies-%s-%s", source_lang, target_lang)
}

sync_glossary <- function(source_lang, target_lang) {
  gfile <- here(sprintf(
    "translation/glossary-%s-%s.csv", source_lang, target_lang
  ))
  if (!file.exists(gfile)) return(invisible(NULL))
  gname <- glossary_name_for(source_lang, target_lang)
  cat("  Syncing glossary:", gname, "\n")
  babeldown::deepl_upsert_glossary(
    filename = gfile,
    glossary_name = gname,
    source_lang = deepl_source_lang(source_lang),
    target_lang = deepl_target_lang(target_lang)
  )
  gname
}

get_style_id <- function() {
  style_file <- here("translation/deepl-styles.yaml")
  if (!file.exists(style_file)) return(NULL)
  config <- yaml::yaml.load_file(style_file)
  config$style_id
}

get_style_context <- function(target_lang) {
  base <- paste(
    "This is content from RLadies+, a gender diversity organisation.",
    "Use a warm, welcoming, and empowering tone.",
    "Prefer gender-neutral language over masculine generics.",
    "Use informal address."
  )
  lang_code <- tolower(substr(target_lang, 1, 2))
  lang_note <- switch(lang_code,
    "es" = paste(
      "Use tú (not usted).",
      "Prefer neutral forms: 'personas organizadoras', 'quienes participan',",
      "'la comunidad' over masculine generics.",
      "Avoid -x and -e endings."
    ),
    "pt" = paste(
      "Use você.",
      "Prefer neutral forms: 'pessoas que organizam', 'quem participa',",
      "'a comunidade' over masculine generics."
    ),
    "fr" = paste(
      "Use tu (not vous).",
      "Prefer neutral forms: 'les personnes qui organisent', 'la communauté'.",
      "Use point médian (·) for roles where no neutral form exists."
    ),
    ""
  )
  paste(base, lang_note)
}

deepl_translate_with_style <- function(text, source_lang, target_lang,
                                        style_id = NULL, glossary_id = NULL,
                                        context = NULL) {
  api_key <- Sys.getenv("DEEPL_API_KEY")
  if (nchar(api_key) == 0) stop("DEEPL_API_KEY not set")

  base_url <- if (grepl(":fx$", api_key)) {
    "https://api-free.deepl.com"
  } else {
    "https://api.deepl.com"
  }

  body <- list(
    text = list(text),
    source_lang = source_lang,
    target_lang = target_lang,
    formality = formality_for_lang(tolower(substr(target_lang, 1, 2)))
  )
  if (!is.null(style_id)) body$style_id <- style_id
  if (!is.null(glossary_id)) body$glossary_id <- glossary_id
  if (!is.null(context)) body$context <- context

  resp <- httr2::request(base_url) |>
    httr2::req_url_path_append("v2", "translate") |>
    httr2::req_headers(Authorization = paste("DeepL-Auth-Key", api_key)) |>
    httr2::req_body_json(body) |>
    httr2::req_perform()

  httr2::resp_body_json(resp)$translations[[1]]$text
}

formality_for_lang <- function(lang) {
  switch(lang,
    "es" = "prefer_less",
    "pt" = "prefer_less",
    "fr" = "prefer_less",
    "default"
  )
}

translate_string <- function(text, source_lang, target_lang,
                             glossary_name = NULL, style_id = NULL,
                             context = NULL) {
  if (!is.character(text) || nchar(trimws(text)) == 0) return(text)
  if (!is.null(style_id) || !is.null(context)) {
    return(deepl_translate_with_style(
      text,
      source_lang = deepl_source_lang(source_lang),
      target_lang = deepl_target_lang(target_lang),
      style_id = style_id,
      context = context
    ))
  }
  babeldown::deepl_translate_markdown_string(
    text,
    source_lang = deepl_source_lang(source_lang),
    target_lang = deepl_target_lang(target_lang),
    glossary_name = glossary_name,
    formality = formality_for_lang(target_lang)
  )
}

translate_yaml_value <- function(value, source_lang, target_lang,
                                  skip_keys = NULL, glossary_name = NULL,
                                  style_id = NULL, context = NULL) {
  if (is.character(value) && length(value) == 1) {
    return(translate_string(value, source_lang, target_lang, glossary_name,
                            style_id, context))
  }
  if (is.character(value) && length(value) > 1) {
    return(vapply(
      value,
      translate_string,
      character(1),
      source_lang = source_lang,
      target_lang = target_lang,
      glossary_name = glossary_name,
      style_id = style_id,
      context = context,
      USE.NAMES = FALSE
    ))
  }
  if (is.list(value)) {
    for (nm in names(value)) {
      if (!is.null(skip_keys) && nm %in% skip_keys) next
      value[[nm]] <- translate_yaml_value(
        value[[nm]], source_lang, target_lang, skip_keys, glossary_name,
        style_id, context
      )
    }
    if (is.null(names(value))) {
      value <- lapply(value, function(item) {
        translate_yaml_value(item, source_lang, target_lang, skip_keys,
                             glossary_name, style_id, context)
      })
    }
    return(value)
  }
  value
}

# Keys within nested structures that should not be translated
SKIP_KEYS <- c(
  "icon", "url", "style", "type", "layout", "weight", "home",
  "slug", "aliases", "source", "image", "outputs", "cascade",
  "date", "directory_id", "path", "alt"
)

# Top-level YAML fields that babeldown handles (simple strings)
BABELDOWN_FIELDS <- c("title", "description", "summary")

# Top-level YAML fields with nested translatable content
NESTED_FIELDS <- c("faq", "pillars", "sections", "ctas")

translate_nested_frontmatter <- function(file, source_lang, target_lang,
                                          glossary_name = NULL,
                                          style_id = NULL) {
  lines <- readLines(file)
  yaml_end <- grep("^---$", lines)[2]
  if (is.na(yaml_end) || yaml_end <= 2) return(invisible(NULL))

  yaml_text <- paste(lines[2:(yaml_end - 1)], collapse = "\n")
  front <- yaml::yaml.load(yaml_text)

  fields_present <- intersect(names(front), NESTED_FIELDS)
  if (length(fields_present) == 0) return(invisible(NULL))

  cat("  Translating nested frontmatter fields:",
      paste(fields_present, collapse = ", "), "\n")

  context <- get_style_context(deepl_target_lang(target_lang))

  for (field in fields_present) {
    front[[field]] <- translate_yaml_value(
      front[[field]], source_lang, target_lang, SKIP_KEYS, glossary_name,
      style_id, context
    )
  }

  yaml_out <- yaml::as.yaml(front, indent.mapping.sequence = TRUE,
                            unicode = TRUE)
  con <- file(file, encoding = "UTF-8")
  writeLines(
    c("---", trimws(yaml_out), "---", lines[(yaml_end + 1):length(lines)]),
    con
  )
  close(con)
}

patch_frontmatter <- function(file, source_lang) {
  lines <- readLines(file)
  yaml_end <- grep("^---$", lines)[2]
  if (is.na(yaml_end)) return(invisible(NULL))

  yaml_section <- lines[1:yaml_end]
  yaml_section <- yaml_section[!grepl("^translated:", yaml_section)]
  yaml_section <- yaml_section[!grepl("^language:", yaml_section)]

  yaml_section <- c(
    yaml_section[1:(length(yaml_section) - 1)],
    sprintf("language: %s", source_lang),
    "translated: auto",
    "---"
  )

  con <- file(file, encoding = "UTF-8")
  writeLines(c(yaml_section, lines[(yaml_end + 1):length(lines)]), con)
  close(con)
}

translate_file <- function(source_file, target_lang, source_lang) {
  target_file <- gsub(
    sprintf("[.]%s[.]", source_lang),
    sprintf(".%s.", target_lang),
    source_file
  )

  if (file.exists(target_file)) {
    existing <- readLines(target_file, n = 15)
    has_auto <- any(grepl("translated: auto", existing))
    has_yes <- any(grepl("translated: yes", existing)) ||
      any(grepl("translated: true", existing))
    if (has_auto || has_yes) {
      cat("  Skipping", target_lang, "- already translated\n")
      return(invisible(NULL))
    }
  }

  cat("  Translating", source_lang, "-->", target_lang, "\n")

  gname <- tryCatch(
    sync_glossary(source_lang, target_lang),
    error = function(e) {
      cat("  WARNING: glossary sync failed:", conditionMessage(e), "\n")
      NULL
    }
  )

  babeldown::deepl_translate_hugo(
    post_path = source_file,
    force = TRUE,
    yaml_fields = BABELDOWN_FIELDS,
    source_lang = deepl_source_lang(source_lang),
    target_lang = deepl_target_lang(target_lang),
    formality = formality_for_lang(target_lang),
    glossary_name = gname
  )

  sid <- get_style_id()

  translate_nested_frontmatter(target_file, source_lang, target_lang, gname,
                               sid)
  patch_frontmatter(target_file, source_lang)
  cat("  Written:", target_file, "\n")
}

translate_changed_content <- function(changed_files) {
  site_langs <- get_site_languages()

  for (src in changed_files) {
    source_lang <- detect_source_lang(src)
    if (is.null(source_lang)) {
      cat("Skipping (no language detected):", src, "\n")
      next
    }

    target_langs <- setdiff(site_langs, source_lang)
    cat("Processing:", src, "(", source_lang, ")\n")

    for (lang in target_langs) {
      tryCatch(
        translate_file(src, lang, source_lang),
        error = function(e) {
          cat("  ERROR translating to", lang, ":", conditionMessage(e), "\n")
        }
      )
    }
  }
}

if (!interactive()) {
  args <- commandArgs(trailingOnly = TRUE)

  if (length(args) == 0) {
    cat("Usage: Rscript scripts/translate_content.R <file1> [file2] ...\n")
    cat("   or: Rscript scripts/translate_content.R --all\n")
    quit(status = 1)
  }

  if (args[1] == "--all") {
    lang_pattern <- sprintf(
      "\\.(%s)\\.md$",
      paste(get_site_languages(), collapse = "|")
    )
    all_content <- list.files(
      here("content"),
      pattern = lang_pattern,
      recursive = TRUE,
      full.names = TRUE
    )
    translate_changed_content(all_content)
  } else {
    translate_changed_content(args)
  }
}
