# Tests for connections.R

# --- setup_credentials() ---

test_that("setup_credentials() errors in non-interactive sessions", {
  skip_if(interactive(), "Cannot test non-interactive check from an interactive session")
  expect_error(setup_credentials(), "interactive")
})

test_that("setup_credentials() is a function with expected arguments", {
  args <- formals(setup_credentials)
  expect_equal(args$uid_service, "PIFSC_Logbook_user")
  expect_equal(args$pwd_service, "PIFSC_Logbook_pwd")
})

# --- create_connection() ---

test_that("create_connection() requires valid keyring credentials", {
  expect_error(
    create_connection(uid_service = "nonexistent_service",
                      pwd_service = "nonexistent_pwd"),
    class = "error"
  )
})

test_that("create_connection() default arguments are correct", {
  args <- formals(create_connection)
  expect_equal(args$host, "picdb.nmfs.local")
  expect_equal(args$port, 1521)
  expect_equal(args$sid, "pic.pifscproddbsn.pifscprodvcn.oraclevcn.com")
  expect_equal(args$driver, "Oracle in instantclient_23_9")
  expect_equal(args$uid_service, "PIFSC_Logbook_user")
  expect_equal(args$pwd_service, "PIFSC_Logbook_pwd")
  expect_equal(args$timeout, 10)
})

# --- safe_disconnect() ---

test_that("safe_disconnect() handles invalid connection gracefully", {
  expect_warning(result <- safe_disconnect("not_a_connection"))
  expect_false(result)
})