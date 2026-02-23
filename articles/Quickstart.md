# Quickstart

``` r
library(pifsc.odbc)
```

## Installation

``` r
# install.packages("renv")
renv::install("N-DucharmeBarth-NOAA/pifsc-odbc")
```

## Prerequisites

Before using `pifsc.odbc`, ensure you have:

1.  **Oracle Instant Client 23.9+** installed with ODBC component
2.  Access to **PIFSC network** or **NOAA VPN**

Verify the Oracle driver is available:

``` r
odbc::odbcListDrivers()
```

You should see `Oracle in instantclient_23_9` (or similar).

## One-time Setup

Store your database credentials using the system keyring. This only
needs to be done once per machine:

``` r
setup_credentials()
```

You’ll be prompted to enter your Oracle username and password.

## Basic Usage

### Download a single table in parallel

``` r
# Automatic year detection and core selection
hdr <- parallel_download(
  table = "LLDS_HDR_20240315HAC",
  year_col = "LANDYR"
)
```

### Download specific years

``` r
hdr_recent <- parallel_download(
  table = "LLDS_HDR_20240315HAC",
  year_col = "LANDYR",
  years = 2020:2023,
  n_cores = 4
)
```

### Download multiple tables

``` r
tables <- list(
  list(table = "LLDS_HDR_20240315HAC", year_col = "LANDYR"),
  list(table = "LLDS_DETAIL_20240315HAC", year_col = "HDR_LANDYR")
)

# Download and save to CSV
results <- download_tables(tables, output_dir = "logbook-data")

# Or just return data without saving
results <- download_tables(tables)
```

### Simple single-threaded download

For small tables or when you don’t need parallelization:

``` r
# Entire table
ref <- simple_download(table = "LLDS_SOME_REF_TABLE")

# Specific years
hdr <- simple_download(
  table = "LLDS_HDR_20240315HAC",
  year_col = "LANDYR",
  years = 2020:2023
)
```

## Exploring tables with peek functions

Before downloading large tables, use the peek functions to explore
structure and content:

``` r
con <- create_connection()

# View first 10 rows and structure
peek_table(con, table = "LLDS_HDR_20240315HAC")

# View just column metadata (efficient for very large tables)
peek_columns(con, table = "LLDS_HDR_20240315HAC")

# Get a random sample (efficient for huge tables)
sample_data <- peek_sample(con, table = "BIG_TABLE", percent = 1)

safe_disconnect(con)
```

These functions are especially useful for: - Understanding table
structure before writing queries - Inspecting data types and column
names - Validating data in large tables without pulling all rows

## Working with connections directly

If you need more control, you can manage connections yourself:

``` r
con <- create_connection()

# Use standard DBI functions
tables <- DBI::dbListTables(con)
data <- DBI::dbGetQuery(con, "SELECT * FROM llds.SOME_TABLE WHERE ROWNUM <= 100")

# Always disconnect when done
safe_disconnect(con)
```

## Next Steps

- **Detailed setup**: See
  [`vignette("connections")`](https://n-ducharmebarth-noaa.github.io/pifsc-odbc/articles/connections.md)
  for credential management and custom connection parameters
- **Advanced downloads**: See
  [`vignette("downloads")`](https://n-ducharmebarth-noaa.github.io/pifsc-odbc/articles/downloads.md)
  for parallel processing strategies and performance tuning
