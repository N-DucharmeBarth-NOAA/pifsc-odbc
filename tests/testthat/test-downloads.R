# Tests for downloads.R

# --- optimal_cores() ---

test_that("optimal_cores() returns an integer between 2 and max_cores", {
  result <- optimal_cores()
  expect_true(is.integer(result) || is.numeric(result))
  expect_gte(result, 2)
  expect_lte(result, 8)
})

test_that("optimal_cores() respects max_cores argument", {
  result <- optimal_cores(max_cores = 3)
  expect_lte(result, 3)
  expect_gte(result, 2)
})

# --- get_available_years() ---

test_that("get_available_years() has expected arguments", {
  args <- formals(get_available_years)
  expect_equal(args$schema, "llds")
  expect_true("con" %in% names(args))
  expect_true("table" %in% names(args))
  expect_true("year_col" %in% names(args))
})

# --- parallel_download() ---

test_that("parallel_download() has expected arguments and defaults", {
  args <- formals(parallel_download)
  expect_equal(args$schema, "llds")
  expect_null(args$years)
  expect_null(args$n_cores)
  expect_true(is.call(args$connection_args))
})

# --- simple_download() ---

test_that("simple_download() has expected arguments and defaults", {
  args <- formals(simple_download)
  expect_equal(args$schema, "llds")
  expect_null(args$year_col)
  expect_null(args$years)
  expect_true(is.call(args$connection_args))
})

# --- download_tables() ---

test_that("download_tables() has expected arguments and defaults", {
  args <- formals(download_tables)
  expect_equal(args$schema, "llds")
  expect_null(args$output_dir)
  expect_null(args$n_cores)
  expect_true(is.call(args$connection_args))
})

test_that("download_tables() creates output directory if needed", {
  tmp <- file.path(tempdir(), "pifsc_test_output")
  if (dir.exists(tmp)) unlink(tmp, recursive = TRUE)

  # Will fail at the download step since no DB, but directory should be created
  tryCatch(
    download_tables(
      table_info = list(list(table = "FAKE_TABLE", year_col = "YEAR")),
      output_dir = tmp
    ),
    error = function(e) NULL
  )

  expect_true(dir.exists(tmp))
  unlink(tmp, recursive = TRUE)
})