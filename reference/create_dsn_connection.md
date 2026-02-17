# Create a connection using a pre-configured ODBC DSN

Establishes a connection to a database using a pre-configured ODBC Data
Source Name (DSN). This is useful for databases that use Windows
authentication or other authentication methods not requiring credentials
in R. Commonly used for SQL Server databases like PIRO LOTUS observer
database.

## Usage

``` r
create_dsn_connection(dsn, timeout = 10)
```

## Arguments

- dsn:

  Character. The name of the ODBC Data Source Name configured in the
  ODBC Data Source Administrator.

- timeout:

  Integer. Connection timeout in seconds. Default: 10.

## Value

An odbc connection object.

## Examples

``` r
if (FALSE) { # \dontrun{
# Connect to PIRO LOTUS observer database
con <- create_dsn_connection("PIRO LOTUS")
DBI::dbListTables(con)
DBI::dbDisconnect(con)
} # }
```
