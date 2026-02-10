# Safely disconnect from a database

Wrapper around
[`DBI::dbDisconnect()`](https://dbi.r-dbi.org/reference/dbDisconnect.html)
with error handling.

## Usage

``` r
safe_disconnect(con)
```

## Arguments

- con:

  A DBI connection object.

## Value

Invisible TRUE if disconnected successfully, FALSE otherwise.
