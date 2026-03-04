library(here)
library(yaml)

get_translation_status <- function() {
  content_files <- list.files(
    here("content"),
    pattern = "index\\.[a-z]{2}\\.md$",
    recursive = TRUE,
    full.names = TRUE
  )

  statuses <- vapply(content_files, function(f) {
    lines <- readLines(f, n = 20)
    yaml_end <- grep("^---$", lines)[2]
    if (is.na(yaml_end)) return("unknown")

    yaml_text <- paste(lines[2:(yaml_end - 1)], collapse = "\n")
    front <- tryCatch(yaml::yaml.load(yaml_text), error = function(e) list())

    translated <- front$translated
    if (is.null(translated)) return("human")
    if (isTRUE(translated)) return("human")
    if (identical(translated, "auto")) return("auto")
    if (isFALSE(translated)) return("placeholder")
    "unknown"
  }, character(1))

  langs <- gsub(".*\\.([a-z]{2})\\.md$", "\\1", content_files)
  sections <- gsub(
    paste0(here("content"), "/"), "",
    dirname(content_files),
    fixed = TRUE
  )

  data.frame(
    file = content_files,
    section = sections,
    lang = langs,
    status = statuses,
    stringsAsFactors = FALSE
  )
}

report_translation_coverage <- function() {
  df <- get_translation_status()

  lines <- readLines(here("config/_default/languages.yaml"))
  site_langs <- gsub(":", "", lines[grep("^[a-z]", lines)])

  cat("=== Translation Status Report ===\n\n")

  for (lang in site_langs) {
    subset <- df[df$lang == lang, ]
    n_total <- nrow(subset)
    n_human <- sum(subset$status == "human")
    n_auto <- sum(subset$status == "auto")
    n_placeholder <- sum(subset$status == "placeholder")

    cat(sprintf(
      "%s: %d total | %d human-reviewed | %d auto-translated | %d placeholder\n",
      lang, n_total, n_human, n_auto, n_placeholder
    ))
  }

  auto <- df[df$status == "auto", ]
  cat("\n=== Files needing review (auto-translated) ===\n")
  if (nrow(auto) > 0) {
    for (i in seq_len(nrow(auto))) {
      cat(sprintf("  [%s] %s\n", auto$lang[i], auto$file[i]))
    }
  } else {
    cat("  None\n")
  }

  placeholders <- df[df$status == "placeholder", ]
  cat("\n=== Missing translations (placeholder only) ===\n")
  if (nrow(placeholders) > 0) {
    for (i in seq_len(nrow(placeholders))) {
      cat(sprintf("  [%s] %s\n", placeholders$lang[i], placeholders$file[i]))
    }
  } else {
    cat("  None\n")
  }

  invisible(df)
}

if (!interactive()) {
  report_translation_coverage()
}
