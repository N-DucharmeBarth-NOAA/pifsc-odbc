# Create an Oracle database connection

Establishes a connection to an Oracle database using ODBC, with
credentials retrieved from the system keyring.

## Usage

``` r
create_connection(
  host = "picdb.nmfs.local",
  port = 1521,
  sid = "pic.pifscproddbsn.pifscprodvcn.oraclevcn.com",
  driver = "Oracle in instantclient_23_9",
  uid_service = "PIFSC_Logbook_user",
  pwd_service = "PIFSC_Logbook_pwd",
  timeout = 10
)
```

## Arguments

- host:

  Character. Database host. Default: "picdb.nmfs.local".

- port:

  Integer. Database port. Default: 1521.

- sid:

  Character. Oracle service name. Default:
  "pic.pifscproddbsn.pifscprodvcn.oraclevcn.com".

- driver:

  Character. ODBC driver name. Default: "Oracle in instantclient_23_9".

- uid_service:

  Character. Keyring service name for the username. Default:
  "PIFSC_Logbook_user".

- pwd_service:

  Character. Keyring service name for the password. Default:
  "PIFSC_Logbook_pwd".

- timeout:

  Integer. Connection timeout in seconds. Default: 10.

## Value

An odbc connection object.

## Examples

``` r
if (FALSE) { # \dontrun{
con <- create_connection()
DBI::dbListTables(con)
DBI::dbDisconnect(con)
} # }
```
