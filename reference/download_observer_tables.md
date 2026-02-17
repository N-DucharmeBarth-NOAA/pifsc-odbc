# Download observer tables from LOTUS database

Convenience function for downloading observer data from the PIRO LOTUS
database using a DSN connection. By default, tables are downloaded in
parallel by partitioning on a year column. Set `year_col = NULL` to fall
back to sequential single-threaded downloads.

## Usage

``` r
download_observer_tables(
  tables = c("LDS_SET_ENVIRON_V", "LDS_CATCH_V", "LDS_GEAR_CFG_V"),
  schema = "newobs",
  dsn = "PIRO LOTUS",
  output_dir = NULL,
  timestamp = TRUE,
  year_col = "HAULBEGIN_YR",
  n_cores = NULL
)
```

## Arguments

- tables:

  Character vector. Table names to download. Default:
  `c("LDS_SET_ENVIRON_V", "LDS_CATCH_V", "LDS_GEAR_CFG_V")`.

- schema:

  Character. Schema name. Default: "newobs".

- dsn:

  Character. ODBC Data Source Name. Default: "PIRO LOTUS".

- output_dir:

  Character or NULL. Directory to save CSV files. If NULL (default),
  data is returned but not saved.

- timestamp:

  Logical. If TRUE and `output_dir` is provided, append timestamp to
  output filenames in format TABLE_YYYYMMDDHHMMSS.csv. Default: TRUE.

- year_col:

  Character or NULL. Name of the year column used for parallel
  partitioning. If NULL, tables are downloaded sequentially with a
  single connection. Default: "HAULBEGIN_YR".

- n_cores:

  Integer or NULL. Number of parallel workers. If NULL (default),
  determined by
  [`optimal_cores()`](https://n-ducharmebarth-noaa.github.io/pifsc-odbc/reference/optimal_cores.md).
  Ignored when `year_col` is NULL.

## Value

A named list of `data.table` objects, one per table.

## Examples

``` r
if (FALSE) { # \dontrun{
# Download default tables in parallel (uses HAULBEGIN_YR)
obs <- download_observer_tables()

# Download and save to disk with timestamps
obs <- download_observer_tables(output_dir = "obs-data", timestamp = TRUE)

# Download custom tables
obs <- download_observer_tables(
  tables = c("LDS_CATCH_V", "LDS_SET_ENVIRON_V"),
  output_dir = "obs-data"
)

# Fall back to single-threaded download
obs <- download_observer_tables(year_col = NULL)
} # }
```
