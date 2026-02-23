# Peek at a database table

Displays the structure and first n rows of a database table, useful for
quick exploration without downloading the entire table. Shows column
names, types, and a sample of data.

## Usage

``` r
peek_table(con, table, schema = "llds", n_rows = 10)
```

## Arguments

- con:

  A DBI connection object.

- table:

  Character. Table name or quoted schema.table format.

- schema:

  Character. Schema name. Default: "llds". Ignored if table includes
  schema prefix.

- n_rows:

  Integer. Number of rows to display. Default: 10.

## Value

Invisibly returns the queried data as a data.frame. Called for display
side effect.

## Examples

``` r
if (FALSE) { # \dontrun{
con <- create_connection()
peek_table(con, table = "LLDS_HDR_20240315HAC")
peek_table(con, table = "MY_TABLE", n_rows = 5)
safe_disconnect(con)
} # }
```
