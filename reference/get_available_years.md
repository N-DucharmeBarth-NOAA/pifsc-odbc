# Get available years for a table

Queries a database table to find the distinct values of a year column.
Used to determine how to partition parallel downloads.

## Usage

``` r
get_available_years(con, schema = "llds", table, year_col)
```

## Arguments

- con:

  A DBI connection object.

- schema:

  Character. Schema name. Default: "llds".

- table:

  Character. Table name.

- year_col:

  Character. Name of the year column.

## Value

Integer vector of available years, sorted ascending.

## Examples

``` r
if (FALSE) { # \dontrun{
con <- create_connection()
years <- get_available_years(con, table = "LLDS_HDR_20240315HAC", year_col = "LANDYR")
safe_disconnect(con)
} # }
```
