# Peek at table shape and metadata

Displays table dimensions, column names, and data types without loading
data. Useful for very large tables where you only want metadata.

## Usage

``` r
peek_columns(con, table, schema = "llds")
```

## Arguments

- con:

  A DBI connection object.

- table:

  Character. Table name or quoted schema.table format.

- schema:

  Character. Schema name. Default: "llds". Ignored if table includes
  schema prefix.

## Value

Invisibly returns a data.frame with column metadata (name and type).
Called for display side effect.

## Examples

``` r
if (FALSE) { # \dontrun{
con <- create_connection()
peek_columns(con, table = "LLDS_HDR_20240315HAC")
safe_disconnect(con)
} # }
```
