#' Fetch Tables from an Airtable Base
#'
#' This function retrieves tables from a
#' specified Airtable base using the
#' `airtabler` package.
#'
#' @param base A string. The ID of the Airtable
#'    base to fetch tables from.
#' @param tables A character vector. The names of
#'    the tables to retrieve.
#'
#' @return An airtable object containing the
#'    requested tables.
#'
#' @examples
#' # Set your Airtable base and table names
#' base_id <- "appXXXXXXXXXXXXXX"
#' table_names <- c("Table1", "Table2")
#'
#' # Fetch tables
#' tables <- get_tables(base_id, table_names)
#' @export
get_tables <- function(base, tables) {
  cli::cli_alert_info("Fetching tables...")
  airtabler::airtable(base = base, tables = tables)
}
get_tables <- function(base, tables) {
  cli::cli_alert_info("Fetching tables...")

  airtabler::airtable(
    base = base,
    tables = tables
  )
}

#' Write JSON Files for Each Row in a Table
#'
#' This function creates JSON files for each row
#' of a given table. Each file is
#' named based on the `name` field (converted to
#' lowercase and hyphen-separated)
#' and saved in the "data/global_team/current"
#' directory relative to the project's
#' root using the `here` package.
#'
#' @details{
#'  The data should contain:
#'   - `name`: The name of the person (string).
#'   - `role`: The role of the person (string vector).
#'   - `start`: Start date (date, optional).
#'   - `end`: End date (date, optional).
#'   - `img`: URL to the image (string).
#' }
#'
#' @param table A data frame.
#'
#' @return This function does not return a value; it writes
#'    JSON files to disk.
#'
#' @examples
#' # Example data
#' table <- data.frame(
#'   name = c("Alice", "Bob"),
#'   role = c("Developer", "Designer"),
#'   start = c("2023-01-01", "2023-02-01"),
#'   end = c("2023-12-31", "2023-11-30"),
#'   img = c("https://example.com/alice.jpg", "https://example.com/bob.jpg"),
#'   stringsAsFactors = FALSE
#' )
#'
#' # Write JSON files for each row in the table
#' write_jsons(table)
#'
#' @export
write_jsons <- function(table, folder) {
  apply(table, 1, function(x) {
    filename <- sprintf(
      "%s/%s.json",
      folder,
      gsub(" ", "-", tolower(x$name))
    )

    jsonlite::write_json(
      list(
        name = jsonlite::unbox(x$name),
        role = x$role,
        start = jsonlite::unbox(x$start),
        end = jsonlite::unbox(x$end),
        img = list(
          url = jsonlite::unbox(x$img)
        )
      ),
      filename,
      pretty = TRUE
    )
  })
}

# Run things ----

airt <- get_tables(
  "appZjaV7eM0Y9FsHZ",
  c("Members", "Teams", "Alumni")
)

teams <- airt$Teams$select_all() |>
  dplyr::transmute(
    role = Team,
    id = id
  )

# Global team ----
airt$Members$select_all() |>
  dplyr::transmute(
    name = Name,
    id = `Team membership`,
    img = photo,
    start = `Start date`,
    end = NA
  ) |>
  tidyr::unnest(id) |>
  dplyr::left_join(teams) |>
  dplyr::group_by(name, img) |>
  dplyr::summarise(
    role = list(role)
  ) |>
  dplyr::group_by(name) |>
  tidyr::unnest(img) |>
  dplyr::summarise(
    img = list(url = url),
    role
  ) |>
  dplyr::ungroup() |>
  write_jsons(
    here::here("data", "global_team", "current")
  )

# Alumni ----
alum <- airt$Alumni$select_all() |>
  dplyr::transmute(
    name = Name,
    role = strsplit(History, ", "),
    img = photo,
    start = `Start Date`,
    end = `End Date`
  )

alum$img <- sapply(1:nrow(alum), function(x) {
  y <- as.list(alum[x, ])
  filename <- sprintf(
    "%s/%s.%s",
    here::here("content/about-us/global-team/img"),
    gsub(" ", "-", tolower(y$name)),
    basename(y$img[[1]]$type)
  )
  download.file(
    y$img[[1]]$url,
    filename,
    quiet = TRUE
  )
  basename(filename)
})

alum |>
  dplyr::group_by(name, start, end) |>
  dplyr::summarise(
    img = list(url = img),
    role
  ) |>
  dplyr::ungroup() |>
  write_jsons(
    here::here("data", "global_team", "alumni")
  )
