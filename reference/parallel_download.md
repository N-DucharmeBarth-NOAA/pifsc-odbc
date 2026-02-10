# Download a table in parallel by year

Partitions a table by year column and downloads chunks in parallel
across multiple database connections. Each worker opens its own
connection, downloads its assigned years, and disconnects.

## Usage

``` r
parallel_download(
  table,
  year_col,
  schema = "llds",
  years = NULL,
  n_cores = NULL,
  connection_args = list()
)
```

## Arguments

- table:

  Character. Table name.

- year_col:

  Character. Name of the year column used for partitioning.

- schema:

  Character. Schema name. Default: "llds".

- years:

  Integer vector. Years to download. If NULL (default), all available
  years are queried automatically.

- n_cores:

  Integer. Number of parallel workers. If NULL (default), determined by
  [`optimal_cores()`](https://n-ducharmebarth-noaa.github.io/pifsc-odbc/reference/optimal_cores.md).

- connection_args:

  List. Additional arguments passed to
  [`create_connection()`](https://n-ducharmebarth-noaa.github.io/pifsc-odbc/reference/create_connection.md)
  for each worker. Default: list().

## Value

A `data.table` containing all downloaded rows.

## Examples

``` r
if (FALSE) { # \dontrun{
# Download with automatic year detection and core selection
hdr <- parallel_download(
  table = "LLDS_HDR_20240315HAC",
  year_col = "LANDYR"
)

# Download specific years with custom core count
detail <- parallel_download(
  table = "LLDS_DETAIL_20240315HAC",
  year_col = "HDR_LANDYR",
  years = 2010:2023,
  n_cores = 4
)
} # }
```
