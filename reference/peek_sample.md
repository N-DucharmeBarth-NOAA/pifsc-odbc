# Quick sample from a table

Retrieves a random sample of rows from a table using SQL's SAMPLE
clause. More efficient than ROWNUM for exploring large tables.

## Usage

``` r
peek_sample(con, table, schema = "llds", percent = 1)
```

## Arguments

- con:

  A DBI connection object.

- table:

  Character. Table name or quoted schema.table format.

- schema:

  Character. Schema name. Default: "llds". Ignored if table includes
  schema prefix.

- percent:

  Numeric. Percentage of rows to sample (0-100). Default: 1.

## Value

A data.frame with sampled rows.

## Examples

``` r
if (FALSE) { # \dontrun{
con <- create_connection()
sample_data <- peek_sample(con, table = "LLDS_HDR_20240315HAC", percent = 0.5)
safe_disconnect(con)
} # }
```
