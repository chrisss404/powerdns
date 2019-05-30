
## Admin

| Env-Variable         | Description                                              |
| -------------------- | -------------------------------------------------------- |
| ADMIN_DB_HOST        | Postgres host (default: admin-db)                        |
| ADMIN_DB_NAME        | Postgres database (default: pda)                         |
| ADMIN_DB_PASS        | Postgres password (default: pda)                         |
| ADMIN_DB_PORT        | Postgres port (default: 5432)                            |
| ADMIN_DB_USER        | Postgres username (default: pda)                         |
| ADMIN_PDNS_API_KEY   | PowerDNS API key (default: pdns)                         |
| ADMIN_PDNS_API_URL   | PowerDNS API URL (default: http://authoritative:8081/)   |
| ADMIN_PDNS_VERSION   | PowerDNS version number (default: 4.1.8)                 |
| ADMIN_SIGNUP_ENABLED | Allow users to sign up (default: no)                     |
| ADMIN_USER_EMAIL     | Email address of admin user (default: admin@example.org) |
| ADMIN_USER_FIRSTNAME | First name of admin user (default: Administrator)        |
| ADMIN_USER_LASTNAME  | Last name of admin user (default: User)                  |
| ADMIN_USER_PASSWORD  | Password of admin user (default: admin)                  |


## Authoritative

| Env-Variable                     | Description                                                                     |
| -------------------------------- | ------------------------------------------------------------------------------- |
| AUTHORITATIVE_API                | Enable/disable the REST API (default: no)                                       |
| AUTHORITATIVE_API_KEY            | Static pre-shared authentication key for access to the REST API (default: pdns) |
| AUTHORITATIVE_API_READONLY       | Disallow data modification through the REST API when set (default: no)          |
| AUTHORITATIVE_DB_HOST            | Postgres host (default: authoritative-db)                                       |
| AUTHORITATIVE_DB_NAME            | Postgres database (default: pdns)                                               |
| AUTHORITATIVE_DB_PASS            | Postgres password (default: pdns)                                               |
| AUTHORITATIVE_DB_PORT            | Postgres port (default: 5432)                                                   |
| AUTHORITATIVE_DB_USER            | Postgres username (default: pdns)                                               |
| AUTHORITATIVE_MASTER             | Act as a master (default: yes)                                                  |
| AUTHORITATIVE_SLAVE              | Act as a slave (default: no)                                                    |
| AUTHORITATIVE_WEBSERVER          | Start a webserver for monitoring on port 8081 (default: no)                     |
| AUTHORITATIVE_WEBSERVER_PASSWORD | Password required for accessing the webserver (default: pdns)                   |


## Dnsdist

| Env-Variable                   | Description                                                                     |
| ------------------------------ | ------------------------------------------------------------------------------- |
| DNSDIST_API_KEY                | Static pre-shared authentication key for access to the REST API (default: pdns) |
| DNSDIST_DNS_OVER_TLS           | Listen for DNS-over-TLS queries on port 853 (default: no)                       |
| DNSDIST_DNS_OVER_TLS_DOMAIN    | Domain name of DNS server.                                                      |
| DNSDIST_DNSCRYPT               | Listen for DNSCrypt queries on port 8443 (default: no)                          |
| DNSDIST_DNSCRYPT_PROVIDER_NAME | DNSCrypt provider name (default: 2.dnscrypt-cert.example.com)                   |
| DNSDIST_PLAIN                  | Listen for plain DNS queries on port 53 (default: no)                           |
| DNSDIST_QUIET                  | Suppress logging of questions and answers (default: no)                         |
| DNSDIST_WEBSERVER              | Start a webserver for REST API on port 8083 (default: no)                       |
| DNSDIST_WEBSERVER_PASSWORD     | Password required for accessing the webserver (default: pdns)                   |


## Recursor

| Env-Variable                   | Description                                                                                       |
| ------------------------------ | ------------------------------------------------------------------------------------------------- |
| RECURSOR_API_KEY               | Static pre-shared authentication key for access to the REST API (default: pdns)                   |
| RECURSOR_API_READONLY          | Disallow data modification through the REST API when set (default: yes)                           |
| RECURSOR_DNSSEC                | DNSSEC mode: off / process-no-validate (default) / process / log-fail / validate                  |
| RECURSOR_FORWARD_ZONES         | Zones for which we forward queries, comma separated domain=ip pairs                               |
| RECURSOR_FORWARD_ZONES_RECURSE | Zones for which we forward queries with recursion bit, comma separated domain=ip pairs            |
| RECURSOR_QUIET                 | Suppress logging of questions and answers (default: no)                                           |
| RECURSOR_TRUST_ANCHORS         | Trust anchors for private zones when using DNSSEC validation, comma separated domain=ds-key pairs |
| RECURSOR_WEBSERVER             | Start a webserver for REST API on port 8082 (default: no)                                         |
| RECURSOR_WEBSERVER_PASSWORD    | Password required for accessing the webserver (default: pdns)                                     |
