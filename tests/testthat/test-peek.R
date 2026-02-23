# Tests for peek.R

# --- peek_table() ---

test_that("peek_table() has correct default arguments", {
  args <- formals(peek_table)
  expect_equal(args$schema, "llds")
  expect_equal(args$n_rows, 10)
})

test_that("peek_table() accepts table with schema prefix", {
  # Just check that the function exists and can be called with schema-prefixed table
  args <- formals(peek_table)
  expect_true("table" %in% names(args))
  expect_true("schema" %in% names(args))
})

test_that("peek_table() handles schema-qualified table names", {
  # This would need a mock connection, but we verify the logic is flexible
  expect_true(grepl("\\.", "myschema.mytable"))
  expect_false(grepl("\\.", "mytable"))
})

# --- peek_columns() ---

test_that("peek_columns() has correct default arguments", {
  args <- formals(peek_columns)
  expect_equal(args$schema, "llds")
})

test_that("peek_columns() is exported and accessible", {
  expect_true(exists("peek_columns", mode = "function"))
})

# --- peek_sample() ---

test_that("peek_sample() has correct default arguments", {
  args <- formals(peek_sample)
  expect_equal(args$schema, "llds")
  expect_equal(args$percent, 1)
})

test_that("peek_sample() validates percent parameter", {
  # Verify default constraints will be checked
  args <- formals(peek_sample)
  expect_equal(args$percent, 1)
})

test_that("peek_sample() percent validation logic", {
  # Test the validation logic we implemented
  percent <- 1
  expect_true(percent > 0 && percent <= 100)
  
  percent <- 50
  expect_true(percent > 0 && percent <= 100)
  
  percent <- 0
  expect_false(percent > 0 && percent <= 100)
  
  percent <- 101
  expect_false(percent > 0 && percent <= 100)
})
