# Database Connections

## Prerequisites

Before using `pifsc.odbc` you need to complete two one-time setup steps:
installing the Oracle ODBC driver and storing your database credentials.

You must also be connected to the **PIFSC network** or the **NOAA VPN**
for all database connections.

### 1. Install Oracle Instant Client

The package requires an Oracle ODBC driver to communicate with the
database. Download and install [Oracle Instant
Client](https://www.oracle.com/database/technologies/instant-client/downloads.html)
(version 23.9 or later) for your operating system. Make sure to include
the ODBC component during installation. After installation, verify the
driver is available:

``` r
odbc::odbcListDrivers()
```

You should see an entry named `Oracle in instantclient_23_9` (or
similar). If the driver name differs on your machine, you can pass your
driver name to
[`create_connection()`](https://n-ducharmebarth-noaa.github.io/pifsc-odbc/reference/create_connection.md)
via the `driver` argument.

### 2. Store database credentials

`pifsc.odbc` uses the [keyring](https://r-lib.github.io/keyring/)
package to securely store your Oracle username and password in your
operating system’s credential manager. This only needs to be done once
per machine — credentials persist across R sessions.

Run the following in an **interactive** R session:

``` r
library(pifsc.odbc)
setup_credentials()
```

You will be prompted to enter your username and password. These are
stored under the service names `PIFSC_Logbook_user` and
`PIFSC_Logbook_pwd` by default.

If you prefer different service names (e.g., to manage credentials for
multiple databases), you can specify them during setup:

``` r
setup_credentials(uid_service = "MY_DB_user", pwd_service = "MY_DB_pwd")
```

You will then need to pass the same service names when creating a
connection:

``` r
con <- create_connection(uid_service = "MY_DB_user", pwd_service = "MY_DB_pwd")
```

## Opening a connection

Once the prerequisites are in place, connecting to the logbook database
is straightforward:

``` r
library(pifsc.odbc)

con <- create_connection()
```

This returns a standard DBI connection object. You can use it with any
DBI-compatible function:

``` r
# List available tables
DBI::dbListTables(con)

# Run a query
result <- DBI::dbGetQuery(con, "SELECT * FROM llds.SOME_TABLE WHERE ROWNUM <= 10")
```

### Custom connection parameters

If you need to connect to a different database or use non-default
settings, all parameters can be overridden:

``` r
con <- create_connection(
  host = "other-db.nmfs.local",
  port = 1521,
  sid = "other.service.name",
  driver = "Oracle in instantclient_21_3",
  timeout = 30
)
```

## Closing a connection

Always close your connection when finished. Use
[`safe_disconnect()`](https://n-ducharmebarth-noaa.github.io/pifsc-odbc/reference/safe_disconnect.md)
for error-tolerant cleanup, which is especially useful in scripts and
parallel workers:

``` r
safe_disconnect(con)
```

Or use the standard DBI approach:

``` r
DBI::dbDisconnect(con)
```

## Connecting via DSN

In addition to Oracle database connections, you can connect to other
databases using pre-configured ODBC Data Source Names (DSNs). This is
particularly useful for databases that use Windows authentication or
other authentication methods that do not require credentials to be
passed from R.

### When to use DSN connections

- **SQL Server databases** using Windows NT authentication (e.g., PIRO
  LOTUS observer database)
- Any database where a system administrator has pre-configured an ODBC
  DSN
- Databases requiring authentication methods not supported by direct
  connections

### Setting up a DSN for PIRO LOTUS

To access the PIRO LOTUS observer database, you need to configure an
ODBC DSN on Windows. This only needs to be done once per machine:

1.  Open **ODBC Data Source Administrator (64-bit)** from Windows
2.  Go to the **User DSN** tab and click **Add**
3.  Select **SQL Server** driver and click **Finish**
4.  Enter the following details:
    - **Name**: `PIRO LOTUS`
    - **Server**: `PIRO-S-SQLPROD1.NMFS.LOCAL,11433`
5.  Click **Next**, select **With Windows NT authentication**, click
    **Next**
6.  Check **Change the default database to**: `LOTUS`
7.  Click **Next**, enable:
    - **Use ANSI quoted identifiers**
    - **Use ANSI nulls, paddings and warnings**
8.  Click **Next**, optionally enable **Perform translation for
    character data**
9.  Click **Finish**, then **Test Data Source** to verify the connection

### Using DSN connections in R

Once the DSN is configured, connecting is simple:

``` r
library(pifsc.odbc)

# Connect to PIRO LOTUS observer database
con <- create_dsn_connection("PIRO LOTUS")

# List available tables
DBI::dbListTables(con)

# Query observer data
catch <- DBI::dbGetQuery(con, "SELECT * FROM newobs.LDS_CATCH_V")

# Disconnect when finished
DBI::dbDisconnect(con)
```

### Requirements

- You must be connected to the **PIFSC network** or **NOAA VPN**
- Windows authentication is handled automatically by the DSN
- No keyring credentials are needed for DSN connections
