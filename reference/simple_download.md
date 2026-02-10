# Download a table using a single connection

Simple single-threaded download of a table, optionally filtered by year.
Useful for small tables or environments where parallel connections are
not available.

## Usage

``` r
simple_download(
  table,
  year_col = NULL,
  schema = "llds",
  years = NULL,
  connection_args = list()
)
```

## Arguments

- table:

  Character. Table name.

- year_col:

  Character or NULL. Name of the year column for filtering. If NULL, the
  entire table is downloaded.

- schema:

  Character. Schema name. Default: "llds".

- years:

  Integer vector or NULL. Years to download. If NULL (default) and
  `year_col` is provided, all years are downloaded. If both `year_col`
  and `years` are NULL, the full table is downloaded.

- connection_args:

  List. Additional arguments passed to
  [`create_connection()`](https://n-ducharmebarth-noaa.github.io/pifsc-odbc/reference/create_connection.md).
  Default: list().

## Value

A `data.table` containing the downloaded rows.

## Examples

``` r
if (FALSE) { # \dontrun{
# Download an entire small table
ref <- simple_download(table = "LLDS_SOME_REF_TABLE")

# Download specific years
hdr <- simple_download(
  table = "LLDS_HDR_20240315HAC",
  year_col = "LANDYR",
  years = 2020:2023
)
} # }
```
