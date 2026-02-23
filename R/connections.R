#' Database Connection Management
#' Functions for establishing and managing Oracle database connections
#'   using keyring-based credential storage.
#' @name connections
#' @importFrom DBI dbConnect dbDisconnect dbGetQuery
#' @importFrom keyring key_set key_get
#' @importFrom odbc odbc
NULL

#' Set up database credentials in the system keyring
#'
#' Stores username and password for Oracle database access using the keyring package.
#' Must be run interactively (prompts for input). Only needs to be done once per machine.
#'
#' @param uid_service Character. Keyring service name for the username. Default: "PIFSC_Logbook_user".
#' @param pwd_service Character. Keyring service name for the password. Default: "PIFSC_Logbook_pwd".
#'
#' @return Invisible NULL. Called for side effect of storing credentials.
#' @export
#'
#' @examples
#' \dontrun{
#' # Run once in an interactive R session
#' setup_credentials()
#'
#' # Or with custom service names
#' setup_credentials(uid_service = "MY_DB_user", pwd_service = "MY_DB_pwd")
#' }
setup_credentials <- function(uid_service = "PIFSC_Logbook_user",
                              pwd_service = "PIFSC_Logbook_pwd") {
  if (!interactive()) {
    stop("setup_credentials() must be run in an interactive R session.")
  }

  cat("You will be prompted to enter your username and password.\n")
  cat("Setting username...\n")
  keyring::key_set(uid_service)
  cat("Setting password...\n")
  keyring::key_set(pwd_service)

  cat("Credentials stored successfully.\n")
  invisible(NULL)
}


#' Create an Oracle database connection
#'
#' Establishes a connection to an Oracle database using ODBC, with credentials
#' retrieved from the system keyring.
#'
#' @param host Character. Database host. Default: "picdb.nmfs.local".
#' @param port Integer. Database port. Default: 1521.
#' @param sid Character. Oracle service name. Default: "pic.pifscproddbsn.pifscprodvcn.oraclevcn.com".
#' @param driver Character. ODBC driver name. Default: "Oracle in instantclient_23_9".
#' @param uid_service Character. Keyring service name for the username. Default: "PIFSC_Logbook_user".
#' @param pwd_service Character. Keyring service name for the password. Default: "PIFSC_Logbook_pwd".
#' @param timeout Integer. Connection timeout in seconds. Default: 10.
#'
#' @return An odbc connection object.
#' @export
#'
#' @examples
#' \dontrun{
#' con <- create_connection()
#' DBI::dbListTables(con)
#' DBI::dbDisconnect(con)
#' }
create_connection <- function(host = "picdb.nmfs.local",
                              port = 1521,
                              sid = "pic.pifscproddbsn.pifscprodvcn.oraclevcn.com",
                              driver = "Oracle in instantclient_23_9",
                              uid_service = "PIFSC_Logbook_user",
                              pwd_service = "PIFSC_Logbook_pwd",
                              timeout = 10) {
  dbq_string <- paste0(host, ":", port, "/", sid)

  DBI::dbConnect(
    odbc::odbc(),
    driver = driver,
    dbq = dbq_string,
    uid = keyring::key_get(uid_service),
    pwd = keyring::key_get(pwd_service),
    timeout = timeout
  )
}


#' Create a connection using a pre-configured ODBC DSN
#'
#' Establishes a connection to a database using a pre-configured ODBC Data
#' Source Name (DSN). This is useful for databases that use Windows authentication
#' or other authentication methods not requiring credentials in R. Commonly used
#' for SQL Server databases like PIRO LOTUS observer database.
#'
#' @param dsn Character. The name of the ODBC Data Source Name configured in
#'   the ODBC Data Source Administrator.
#' @param timeout Integer. Connection timeout in seconds. Default: 10.
#'
#' @return An odbc connection object.
#' @export
#'
#' @examples
#' \dontrun{
#' # Connect to PIRO LOTUS observer database
#' con <- create_dsn_connection("PIRO LOTUS")
#' DBI::dbListTables(con)
#' DBI::dbDisconnect(con)
#' }
create_dsn_connection <- function(dsn, timeout = 10) {
  DBI::dbConnect(
    odbc::odbc(),
    dsn = dsn,
    timeout = timeout
  )
}


#' Safely disconnect from a database
#'
#' Wrapper around \code{DBI::dbDisconnect()} with error handling.
#'
#' @param con A DBI connection object.
#'
#' @return Invisible TRUE if disconnected successfully, FALSE otherwise.
#' @export
safe_disconnect <- function(con) {
  tryCatch({
    DBI::dbDisconnect(con)
    invisible(TRUE)
  }, error = function(e) {
    warning("Failed to disconnect: ", e$message)
    invisible(FALSE)
  })
}