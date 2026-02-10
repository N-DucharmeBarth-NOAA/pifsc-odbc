# Set up database credentials in the system keyring

Stores username and password for Oracle database access using the
keyring package. Must be run interactively (prompts for input). Only
needs to be done once per machine.

## Usage

``` r
setup_credentials(
  uid_service = "PIFSC_Logbook_user",
  pwd_service = "PIFSC_Logbook_pwd"
)
```

## Arguments

- uid_service:

  Character. Keyring service name for the username. Default:
  "PIFSC_Logbook_user".

- pwd_service:

  Character. Keyring service name for the password. Default:
  "PIFSC_Logbook_pwd".

## Value

Invisible NULL. Called for side effect of storing credentials.

## Examples

``` r
if (FALSE) { # \dontrun{
# Run once in an interactive R session
setup_credentials()

# Or with custom service names
setup_credentials(uid_service = "MY_DB_user", pwd_service = "MY_DB_pwd")
} # }
```
