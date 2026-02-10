# Download multiple tables in parallel

Sequentially processes a list of table definitions, downloading each in
parallel by year. Optionally saves results to CSV.

## Usage

``` r
download_tables(
  table_info,
  schema = "llds",
  output_dir = NULL,
  n_cores = NULL,
  connection_args = list()
)
```

## Arguments

- table_info:

  A list of lists, each with elements:

  table

  :   Character. Table name.

  year_col

  :   Character. Year column name.

- schema:

  Character. Schema name. Default: "llds".

- output_dir:

  Character or NULL. Directory to save CSVs. If NULL (default), data is
  returned but not saved.

- n_cores:

  Integer. Number of parallel workers. If NULL (default), determined by
  [`optimal_cores()`](https://n-ducharmebarth-noaa.github.io/pifsc-odbc/reference/optimal_cores.md).

- connection_args:

  List. Additional arguments passed to
  [`create_connection()`](https://n-ducharmebarth-noaa.github.io/pifsc-odbc/reference/create_connection.md)
  for each worker. Default: list().

## Value

A named list of `data.table` objects, one per table.

## Examples

``` r
if (FALSE) { # \dontrun{
tables <- list(
  list(table = "LLDS_HDR_20240315HAC", year_col = "LANDYR"),
  list(table = "LLDS_DETAIL_20240315HAC", year_col = "HDR_LANDYR")
)

# Download and save to disk
results <- download_tables(tables, output_dir = "logbook-data")

# Download without saving
results <- download_tables(tables)
} # }
```
