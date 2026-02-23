#' Table Preview Functions
#' Functions for quickly inspecting database tables without full download.
#' @name peek
NULL

#' Peek at a database table
#'
#' Displays the structure and first n rows of a database table, useful for
#' quick exploration without downloading the entire table. Shows column names,
#' types, and a sample of data.
#'
#' @param con A DBI connection object.
#' @param table Character. Table name or quoted schema.table format.
#' @param schema Character. Schema name. Default: "llds". Ignored if table
#'   includes schema prefix.
#' @param n_rows Integer. Number of rows to display. Default: 10.
#'
#' @return Invisibly returns the queried data as a data.frame. Called for
#'   display side effect.
#' @export
#'
#' @examples
#' \dontrun{
#' con <- create_connection()
#' peek_table(con, table = "LLDS_HDR_20240315HAC")
#' peek_table(con, table = "MY_TABLE", n_rows = 5)
#' safe_disconnect(con)
#' }
peek_table <- function(con, table, schema = "llds", n_rows = 10) {
  # Determine full table name with schema
  if (grepl("\\.", table)) {
    # Table already includes schema prefix
    full_table <- table
  } else {
    full_table <- paste0(schema, ".", table)
  }

  # Query first n rows
  sql <- paste0("SELECT * FROM ", full_table, " WHERE ROWNUM <= ", n_rows)
  data <- DBI::dbGetQuery(con, sql)

  # Display structure
  cat("Table: ", full_table, "\n")
  cat("Dimensions: ", nrow(data), " rows (displayed) x ", ncol(data), " columns\n\n")

  cat("Structure:\n")
  str(data)

  cat("\n")
  cat("First ", nrow(data), " rows:\n")
  print(data)

  invisible(data)
}


#' Peek at table shape and metadata
#'
#' Displays table dimensions, column names, and data types without loading data.
#' Useful for very large tables where you only want metadata.
#'
#' @param con A DBI connection object.
#' @param table Character. Table name or quoted schema.table format.
#' @param schema Character. Schema name. Default: "llds". Ignored if table
#'   includes schema prefix.
#'
#' @return Invisibly returns a data.frame with column metadata (name and type).
#'   Called for display side effect.
#' @export
#'
#' @examples
#' \dontrun{
#' con <- create_connection()
#' peek_columns(con, table = "LLDS_HDR_20240315HAC")
#' safe_disconnect(con)
#' }
peek_columns <- function(con, table, schema = "llds") {
  # Determine full table name with schema
  if (grepl("\\.", table)) {
    full_table <- table
  } else {
    full_table <- paste0(schema, ".", table)
  }

  # Get column info
  col_info <- DBI::dbGetFields(con, full_table)

  # Try to get record count
  count_sql <- paste0("SELECT COUNT(*) as row_count FROM ", full_table)
  tryCatch(
    {
      count_result <- DBI::dbGetQuery(con, count_sql)
      row_count <- count_result$row_count[1]
    },
    error = function(e) {
      row_count <<- NA
    }
  )

  # Display info
  cat("Table: ", full_table, "\n")
  if (!is.na(row_count)) {
    cat("Total rows: ", format(row_count, big.mark = ","), "\n")
  }
  cat("Total columns: ", length(col_info), "\n\n")
  cat("Columns:\n")
  for (i in seq_along(col_info)) {
    cat(sprintf("  %2d. %-30s [%s]\n", i, names(col_info)[i], col_info[i]))
  }

  # Return metadata invisibly
  metadata <- data.frame(
    column_name = names(col_info),
    column_type = unname(col_info),
    row.names = NULL
  )
  invisible(metadata)
}


#' Quick sample from a table
#'
#' Retrieves a random sample of rows from a table using SQL's SAMPLE clause.
#' More efficient than ROWNUM for exploring large tables.
#'
#' @param con A DBI connection object.
#' @param table Character. Table name or quoted schema.table format.
#' @param schema Character. Schema name. Default: "llds". Ignored if table
#'   includes schema prefix.
#' @param percent Numeric. Percentage of rows to sample (0-100). Default: 1.
#'
#' @return A data.frame with sampled rows.
#' @export
#'
#' @examples
#' \dontrun{
#' con <- create_connection()
#' sample_data <- peek_sample(con, table = "LLDS_HDR_20240315HAC", percent = 0.5)
#' safe_disconnect(con)
#' }
peek_sample <- function(con, table, schema = "llds", percent = 1) {
  # Validate percent
  if (percent <= 0 || percent > 100) {
    stop("percent must be between 0 and 100")
  }

  # Determine full table name with schema
  if (grepl("\\.", table)) {
    full_table <- table
  } else {
    full_table <- paste0(schema, ".", table)
  }

  # Query with SAMPLE clause (Oracle specific)
  sql <- paste0("SELECT * FROM ", full_table, " SAMPLE(", percent, ")")
  data <- DBI::dbGetQuery(con, sql)

  cat("Sample (", percent, "%) from ", full_table, ": ",
    nrow(data), " rows\n", sep = "")
  print(data)

  invisible(data)
}
