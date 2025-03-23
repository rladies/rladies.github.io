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
  airtabler::airtable(
    base = base,
    tables = tables
  )
}

#' Convert a Named List to JSON-like Structure
#'
#' This function converts a named list into a
#' JSON-like structure by reformulating
#' the input's elements into a specific nested
#' format. Any empty elements (length 0)
#' are excluded from the resulting list.
#'
#' @details{
#'
#'   - `name`: A single character string.
#'   - `role`: A character vector.
#'   - `start`: A single character string (optional).
#'   - `end`: A single character string (optional).
#'   - `img`: list with `url` and/or `credit`
#' }
#'
#' @param x A named list
#' @return A list reformatted to a JSON-like
#'    structure where `name`, `start`, and
#'   `end` are unboxed strings, and `img` is
#'    nested as a list with an unboxed URL.
#'   Elements with length 0 are excluded
#'   from the output list.
#'
#' @details This function uses `jsonlite::unbox`
#'   to ensure single values are stored
#'   as scalars. It filters out any empty
#'   elements (length 0) before returning
#'   the final structure.
#'
#' @examples
#' input <- list(
#'   name = "Alice",
#'   role = c("Developer", "Team Lead"),
#'   start = "2023-01-01",
#'   end = "2023-12-31",
#'   img = "https://example.com/image.png"
#' )
#'
#' tojson(input)
tojson <- function(x) {
  json <- list(
    name = jsonlite::unbox(x$name),
    role = x$role,
    start = jsonlite::unbox(x$start),
    end = jsonlite::unbox(x$end)
  )

  if (!is.na(x$img)) {
    json$img = list(
      url = jsonlite::unbox(x$img)
    )
  }
  idx <- sapply(
    json,
    function(y) {
      length(y) != 0
    }
  )
  lapply(which(idx), function(y) {
    json[[y]]
  })
}

#' Write and Save Data to JSON Files
#' and Download Images
#'
#' This function processes a data
#' table, downloads images associated with each
#' row's `img` column, and saves each row's
#' data as a JSON file in a specified
#' folder.
#'
#' @details(
#' table should contain:
#' - `name`: Name of the entity (used for filenames).
#' - `role`: Role associated with the entity.
#' - `start`: Start information (e.g., employment start date).
#' - `end`: End information (e.g., employment end date).
#' - `img`: A list column containing sub-columns:
#'    - `type`: File type of the image (e.g., "jpg", "png").
#'    - `url`: URL for downloading the image.
#' )
#'
#' @param table A data frame containing the data to process.
#' @param folder A string specifying the folder to save the
#'    resulting JSON files.
#'
#' @return This function does not return a value. It
#'   performs the side effects of
#' downloading images to the
#' "content/about-us/global-team/img" folder and saving
#' JSON files in the `folder` parameter location.
#'
#' @examples
#' \dontrun{
#' # Example data table
#' data <- data.frame(
#'   name = c("Alice Smith", "Bob Johnson"),
#'   role = c("Manager", "Engineer"),
#'   start = c("2020-01-01", "2021-05-15"),
#'   end = c("2023-01-01", NA),
#'   img = I(list(
#'     list(type = "jpg", url = "http://example.com/alice.jpg"),
#'     list(type = "png", url = "http://example.com/bob.png")
#'   ))
#' )
#'
#' # Save data to JSON folder
#' write_data(data, folder = "output/json")
#' }
write_data <- function(table, folder) {
  table$img <- sapply(1:nrow(table), function(x) {
    y <- as.list(table[x, ])
    if (length(y$img[[1]]$type) == 0) return(NA)
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

  apply(table, 1, function(x) {
    filename <- sprintf(
      "%s/%s.json",
      folder,
      gsub(" ", "-", tolower(x$name)),
      na = "null"
    )

    y <- tojson(x)
    jsonlite::write_json(
      y,
      filename,
      pretty = TRUE
    )
    y
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
  write_data(
    here::here("data", "global_team", "current")
  )

# Alumni ----
alum <- airt$Alumni$select_all()

if (ncol(alum) > 0) {
  alum <- alum |>
    dplyr::transmute(
      id = id,
      name = Name,
      role = strsplit(History, ", "),
      img = photo,
      start = `Start Date`,
      end = `End Date`
    )

  write_jsons(
    alum,
    here::here("data", "global_team", "alumni")
  )

  # Delete from Airtable, to keep tidy.
  # Singular place for history of Global Team members
  # is website repo.
  airt$Alumni$delete(record_id = alum$id)
}
