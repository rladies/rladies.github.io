readRenviron("~/.Renviron")

# Source only the functions, not the CLI block
local({
  lines <- readLines(here::here("scripts/translate_content.R"))
  cli_start <- grep("^if \\(!interactive\\(\\)", lines)
  if (length(cli_start) > 0) {
    lines <- lines[seq_len(cli_start - 1)]
  }
  eval(parse(text = lines), envir = globalenv())
})

fix_unicode_escapes <- function(file) {
  raw <- readBin(file, "raw", file.info(file)$size)
  txt <- rawToChar(raw)
  Encoding(txt) <- "UTF-8"
  txt <- gsub("<U\\+([0-9A-Fa-f]{4})>", "\\\\u\\1", txt)
  txt <- stringi::stri_unescape_unicode(txt)
  writeBin(charToRaw(txt), file)
}

files_to_fix <- c(
  "content/about-us/involved/index.fr.md",
  "content/about-us/faq/index.pt.md",
  "content/about-us/faq/index.fr.md"
)

sid <- get_style_id()

for (f in files_to_fix) {
  full_path <- here::here(f)
  lang <- gsub(".*\\.(\\w+)\\.md$", "\\1", f)
  cat("Translating nested frontmatter:", f, "\n")
  tryCatch({
    translate_nested_frontmatter(full_path, "en", lang, glossary_name = NULL,
                                 style_id = sid)
    cat("  Done\n")
  }, error = function(e) {
    cat("  ERROR:", conditionMessage(e), "\n")
  })
  cat("  Waiting 10s to avoid rate limit...\n")
  Sys.sleep(10)
}

cat("\nFixing unicode escapes in all translated files...\n")
all_translated <- list.files(
  here::here("content"), pattern = "\\.(es|pt|fr)\\.md$",
  recursive = TRUE, full.names = TRUE
)
for (f in all_translated) {
  raw <- readBin(f, "raw", file.info(f)$size)
  txt <- rawToChar(raw)
  if (grepl("<U\\+[0-9A-Fa-f]{4}>", txt)) {
    cat("  Fixing:", f, "\n")
    fix_unicode_escapes(f)
  }
}
cat("Done.\n")
