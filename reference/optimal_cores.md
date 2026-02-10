# Determine optimal number of cores for parallel processing

Uses 75% of available cores, bounded between 2 and a configurable
maximum.

## Usage

``` r
optimal_cores(max_cores = 8)
```

## Arguments

- max_cores:

  Integer. Upper bound on cores to use. Default: 8.

## Value

Integer. Number of cores to use.

## Examples

``` r
optimal_cores()
#> [1] 3
```
