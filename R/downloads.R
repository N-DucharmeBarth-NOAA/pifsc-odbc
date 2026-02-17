#' @title Parallel Data Download
#' @description Functions for parallel extraction of data from Oracle databases,
#'   with automatic year-based partitioning and chunked downloads across
#'   multiple cores.
#' @name downloads
#' @importFrom foreach %dopar%
NULL


#' Get available years for a table
#'
#' Queries a database table to find the distinct values of a year column.
#' Used to determine how to partition parallel downloads.
#'
#' @param con A DBI connection object.
#' @param schema Character. Schema name. Default: "llds".
#' @param table Character. Table name.
#' @param year_col Character. Name of the year column.
#'
#' @return Integer vector of available years, sorted ascending.
#' @export
#'
#' @examples
#' \dontrun{
#' con <- create_connection()
#' years <- get_available_years(con, table = "LLDS_HDR_20240315HAC", year_col = "LANDYR")
#' safe_disconnect(con)
#' }
get_available_years <- function(con, schema = "llds", table, year_col) {
  sql <- paste0(
    "SELECT DISTINCT ", year_col,
    " FROM ", schema, ".", table,
    " ORDER BY ", year_col
  )
  result <- DBI::dbGetQuery(con, sql)
  sort(result[[1]])
}


#' Determine optimal number of cores for parallel processing
#'
#' Uses 75% of available cores, bounded between 2 and a configurable maximum.
#'
#' @param max_cores Integer. Upper bound on cores to use. Default: 8.
#'
#' @return Integer. Number of cores to use.
#' @export
#'
#' @examples
#' optimal_cores()
optimal_cores <- function(max_cores = 8) {
  n <- parallel::detectCores()
  max(2L, min(as.integer(max_cores), floor(n * 0.75)))
}


#' Download a table in parallel by year
#'
#' Partitions a table by year column and downloads chunks in parallel across
#' multiple database connections. Each worker opens its own connection,
#' downloads its assigned years, and disconnects.
#'
#' @param table Character. Table name.
#' @param year_col Character. Name of the year column used for partitioning.
#' @param schema Character. Schema name. Default: "llds".
#' @param years Integer vector. Years to download. If NULL (default), all
#'   available years are queried automatically.
#' @param n_cores Integer. Number of parallel workers. If NULL (default),
#'   determined by \code{optimal_cores()}.
#' @param connection_args List. Additional arguments passed to
#'   \code{create_connection()} for each worker. Default: list().
#'
#' @return A \code{data.table} containing all downloaded rows.
#' @export
#'
#' @examples
#' \dontrun{
#' # Download with automatic year detection and core selection
#' hdr <- parallel_download(
#'   table = "LLDS_HDR_20240315HAC",
#'   year_col = "LANDYR"
#' )
#'
#' # Download specific years with custom core count
#' detail <- parallel_download(
#'   table = "LLDS_DETAIL_20240315HAC",
#'   year_col = "HDR_LANDYR",
#'   years = 2010:2023,
#'   n_cores = 4
#' )
#' }
parallel_download <- function(table,
                              year_col,
                              schema = "llds",
                              years = NULL,
                              n_cores = NULL,
                              connection_args = list()) {

  # Determine cores
  if (is.null(n_cores)) {
    n_cores <- optimal_cores()
  }

  # If years not supplied, query them
  if (is.null(years)) {
    cat("Querying available years...\n")
    con <- do.call(create_connection, connection_args)
    years <- get_available_years(con, schema = schema, table = table, year_col = year_col)
    safe_disconnect(con)
    cat("Found years:", min(years), "to", max(years), "(", length(years), "years)\n")
  }

  cat("Downloading", table, "using", n_cores, "cores...\n")
  start_time <- Sys.time()

  # Split years across cores
  year_chunks <- split(years, cut(seq_along(years), n_cores, labels = FALSE))

  # Set up cluster
  cl <- parallel::makeCluster(n_cores)
  doParallel::registerDoParallel(cl)
  on.exit({
    parallel::stopCluster(cl)
  }, add = TRUE)

  # Parallel download
  table_data <- foreach::foreach(
    year_chunk = year_chunks,
    .combine = function(...) data.table::rbindlist(list(...)),
    .packages = c("DBI", "odbc", "data.table", "keyring")
  ) %dopar% {
    # Each worker opens its own connection
    worker_con <- do.call(pifsc.odbc::create_connection, connection_args)

    worker_data <- data.table::data.table()

    for (year in year_chunk) {
      year_data <- tryCatch({
        sql <- paste0(
          "SELECT * FROM ", schema, ".", table,
          " WHERE ", year_col, " = ", year
        )
        data.table::as.data.table(DBI::dbGetQuery(worker_con, sql))
      }, error = function(e) {
        cat("Error for year", year, "in", table, ":", e$message, "\n")
        data.table::data.table()
      })

      if (nrow(year_data) > 0) {
        worker_data <- data.table::rbindlist(list(worker_data, year_data))
        cat("Table", table, "- Year", year, ":", nrow(year_data), "rows\n")
      }
    }

    pifsc.odbc::safe_disconnect(worker_con)
    worker_data
  }

  # Report results
  elapsed <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))
  cat("Downloaded", nrow(table_data), "rows from", table,
      "in", round(elapsed, 1), "sec",
      "(", round(nrow(table_data) / elapsed, 0), "rows/sec)\n")

  table_data
}


#' Download a table using a single connection
#'
#' Simple single-threaded download of a table, optionally filtered by year.
#' Useful for small tables or environments where parallel connections are
#' not available.
#'
#' @param table Character. Table name.
#' @param year_col Character or NULL. Name of the year column for filtering.
#'   If NULL, the entire table is downloaded.
#' @param schema Character. Schema name. Default: "llds".
#' @param years Integer vector or NULL. Years to download. If NULL (default)
#'   and \code{year_col} is provided, all years are downloaded. If both
#'   \code{year_col} and \code{years} are NULL, the full table is downloaded.
#' @param con A DBI connection object or NULL. If provided, this connection
#'   is used directly and the caller is responsible for managing the connection
#'   lifecycle. If NULL (default), a connection is created internally using
#'   \code{connection_args} and disconnected on exit.
#' @param connection_args List. Additional arguments passed to
#'   \code{create_connection()} when \code{con} is NULL. Default: list().
#'
#' @return A \code{data.table} containing the downloaded rows.
#' @export
#'
#' @examples
#' \dontrun{
#' # Download an entire small table
#' ref <- simple_download(table = "LLDS_SOME_REF_TABLE")
#'
#' # Download specific years
#' hdr <- simple_download(
#'   table = "LLDS_HDR_20240315HAC",
#'   year_col = "LANDYR",
#'   years = 2020:2023
#' )
#'
#' # Download using a provided connection (e.g., DSN connection)
#' con <- create_dsn_connection("PIRO LOTUS")
#' catch <- simple_download(
#'   table = "LDS_CATCH_V",
#'   schema = "newobs",
#'   con = con
#' )
#' DBI::dbDisconnect(con)
#' }
simple_download <- function(table,
                            year_col = NULL,
                            schema = "llds",
                            years = NULL,
                            con = NULL,
                            connection_args = list()) {

  cat("Downloading", table, "(single-threaded)...\n")
  start_time <- Sys.time()

  # Use provided connection or create a new one
  if (is.null(con)) {
    con <- do.call(create_connection, connection_args)
    on.exit(safe_disconnect(con), add = TRUE)
  }

  if (is.null(year_col) && is.null(years)) {
    # Download full table
    sql <- paste0("SELECT * FROM ", schema, ".", table)
    table_data <- data.table::as.data.table(DBI::dbGetQuery(con, sql))
  } else if (!is.null(year_col) && is.null(years)) {
    # Download all years
    sql <- paste0("SELECT * FROM ", schema, ".", table)
    table_data <- data.table::as.data.table(DBI::dbGetQuery(con, sql))
  } else {
    # Download year by year and combine
    table_data <- data.table::data.table()
    for (year in years) {
      year_data <- tryCatch({
        sql <- paste0(
          "SELECT * FROM ", schema, ".", table,
          " WHERE ", year_col, " = ", year
        )
        data.table::as.data.table(DBI::dbGetQuery(con, sql))
      }, error = function(e) {
        cat("Error for year", year, "in", table, ":", e$message, "\n")
        data.table::data.table()
      })

      if (nrow(year_data) > 0) {
        table_data <- data.table::rbindlist(list(table_data, year_data))
        cat("Table", table, "- Year", year, ":", nrow(year_data), "rows\n")
      }
    }
  }

  elapsed <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))
  cat("Downloaded", nrow(table_data), "rows from", table,
      "in", round(elapsed, 1), "sec",
      "(", round(nrow(table_data) / max(elapsed, 0.001), 0), "rows/sec)\n")

  table_data
}


#' Download multiple tables in parallel
#'
#' Sequentially processes a list of table definitions, downloading each in
#' parallel by year. Optionally saves results to CSV.
#'
#' @param table_info A list of lists, each with elements:
#'   \describe{
#'     \item{table}{Character. Table name.}
#'     \item{year_col}{Character. Year column name.}
#'   }
#' @param schema Character. Schema name. Default: "llds".
#' @param output_dir Character or NULL. Directory to save CSVs. If NULL
#'   (default), data is returned but not saved.
#' @param n_cores Integer. Number of parallel workers. If NULL (default),
#'   determined by \code{optimal_cores()}.
#' @param connection_args List. Additional arguments passed to
#'   \code{create_connection()} for each worker. Default: list().
#'
#' @return A named list of \code{data.table} objects, one per table.
#' @export
#'
#' @examples
#' \dontrun{
#' tables <- list(
#'   list(table = "LLDS_HDR_20240315HAC", year_col = "LANDYR"),
#'   list(table = "LLDS_DETAIL_20240315HAC", year_col = "HDR_LANDYR")
#' )
#'
#' # Download and save to disk
#' results <- download_tables(tables, output_dir = "logbook-data")
#'
#' # Download without saving
#' results <- download_tables(tables)
#' }
download_tables <- function(table_info,
                            schema = "llds",
                            output_dir = NULL,
                            n_cores = NULL,
                            connection_args = list()) {

  if (!is.null(output_dir) && !dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }

  start_time <- Sys.time()
  results <- list()

  for (i in seq_along(table_info)) {
    info <- table_info[[i]]
    cat("\n=== Processing table:", info$table, "===\n")

    dt <- parallel_download(
      table = info$table,
      year_col = info$year_col,
      schema = schema,
      n_cores = n_cores,
      connection_args = connection_args
    )

    if (!is.null(output_dir) && nrow(dt) > 0) {
      out_path <- file.path(output_dir, paste0(info$table, ".csv"))
      data.table::fwrite(dt, file = out_path)
      cat("Saved to", out_path, "\n")
    }

    results[[info$table]] <- dt
  }

  elapsed <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))
  cat("\n=== COMPLETE ===\n")
  cat("Tables processed:", length(table_info), "\n")
  cat("Total time:", round(elapsed, 1), "seconds\n")

  results
}


#' Download observer tables from LOTUS database
#'
#' Convenience function for downloading observer data from the PIRO LOTUS
#' database using a DSN connection. Downloads tables sequentially using a
#' single connection and optionally saves results to CSV files.
#'
#' @param tables Character vector. Table names to download. Default:
#'   \code{c("LDS_SET_ENVIRON_V", "LDS_CATCH_V", "LDS_GEAR_CFG_V")}.
#' @param schema Character. Schema name. Default: "newobs".
#' @param dsn Character. ODBC Data Source Name. Default: "PIRO LOTUS".
#' @param output_dir Character or NULL. Directory to save CSV files. If NULL
#'   (default), data is returned but not saved.
#' @param timestamp Logical. If TRUE and \code{output_dir} is provided, append
#'   timestamp to output filenames in format TABLE_YYYYMMDDHHMMSS.csv.
#'   Default: TRUE.
#'
#' @return A named list of \code{data.table} objects, one per table.
#' @export
#'
#' @examples
#' \dontrun{
#' # Download default tables and return data
#' obs <- download_observer_tables()
#'
#' # Download and save to disk with timestamps
#' obs <- download_observer_tables(output_dir = "obs-data", timestamp = TRUE)
#'
#' # Download custom tables
#' obs <- download_observer_tables(
#'   tables = c("LDS_CATCH_V", "LDS_SET_ENVIRON_V"),
#'   output_dir = "obs-data"
#' )
#' }
download_observer_tables <- function(
    tables = c("LDS_SET_ENVIRON_V", "LDS_CATCH_V", "LDS_GEAR_CFG_V"),
    schema = "newobs",
    dsn = "PIRO LOTUS",
    output_dir = NULL,
    timestamp = TRUE) {

  if (!is.null(output_dir) && !dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }

  start_time <- Sys.time()
  cat("Connecting to", dsn, "...\n")
  con <- create_dsn_connection(dsn)
  on.exit(safe_disconnect(con), add = TRUE)

  results <- list()

  for (table in tables) {
    cat("\n=== Downloading table:", table, "===\n")

    dt <- simple_download(
      table = table,
      schema = schema,
      con = con
    )

    if (!is.null(output_dir) && nrow(dt) > 0) {
      if (timestamp) {
        timestamp_str <- format(Sys.time(), "%Y%m%d%H%M%S")
        filename <- paste0(table, "_", timestamp_str, ".csv")
      } else {
        filename <- paste0(table, ".csv")
      }
      out_path <- file.path(output_dir, filename)
      data.table::fwrite(dt, file = out_path)
      cat("Saved to", out_path, "\n")
    }

    results[[table]] <- dt
  }

  elapsed <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))
  cat("\n=== COMPLETE ===\n")
  cat("Tables downloaded:", length(tables), "\n")
  cat("Total time:", round(elapsed, 1), "seconds\n")

  results
}