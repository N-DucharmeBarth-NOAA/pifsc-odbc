# Download a DSN table in parallel by year

Partitions a table accessible via an ODBC Data Source Name (DSN) by a
year column and downloads chunks in parallel. Each worker opens its own
DSN connection, downloads its assigned years, and disconnects. This is
the DSN equivalent of
[`parallel_download`](https://n-ducharmebarth-noaa.github.io/pifsc-odbc/reference/parallel_download.md),
which targets Oracle connections.

## Usage

``` r
parallel_dsn_download(
  table,
  year_col,
  schema = "newobs",
  dsn = "PIRO LOTUS",
  years = NULL,
  n_cores = NULL
)
```

## Arguments

- table:

  Character. Table name.

- year_col:

  Character. Name of the year column used for partitioning.

- schema:

  Character. Schema name. Default: "newobs".

- dsn:

  Character. ODBC Data Source Name. Default: "PIRO LOTUS".

- years:

  Integer vector. Years to download. If NULL (default), all available
  years are queried automatically.

- n_cores:

  Integer. Number of parallel workers. If NULL (default), determined by
  [`optimal_cores()`](https://n-ducharmebarth-noaa.github.io/pifsc-odbc/reference/optimal_cores.md).

## Value

A `data.table` containing all downloaded rows.

## Examples

``` r
if (FALSE) { # \dontrun{
# Download with automatic year detection and core selection
catch <- parallel_dsn_download(
  table = "LDS_CATCH_V",
  year_col = "HAULBEGIN_YR"
)

# Download specific years with custom core count
environ <- parallel_dsn_download(
  table = "LDS_SET_ENVIRON_V",
  year_col = "HAULBEGIN_YR",
  years = 2015:2023,
  n_cores = 4
)
} # }
```
