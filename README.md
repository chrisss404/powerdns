
## Private Recursor

Create `secure-recursor.yml` like this:

    version: '2'
    
    services:
    
      gateway:
        image: jwilder/nginx-proxy:alpine
        volumes:
          - "/var/run/docker.sock:/tmp/docker.sock:ro"
          - "/etc/nginx/vhost.d"
          - "/usr/share/nginx/html"
          - "/etc/nginx/certs"
        ports:
          - "80:80"
    
      letsencrypt:
        image: jrcs/letsencrypt-nginx-proxy-companion:latest
        volumes:
          - "/var/run/docker.sock:/var/run/docker.sock:ro"
        volumes_from:
          - gateway
    
      dnsdist:
        image: chrisss404/powerdns:latest-dnsdist
        environment:
          - VIRTUAL_HOST=dot.example.com
          - VIRTUAL_PORT=9999
          - LETSENCRYPT_HOST=dot.example.com
          - LETSENCRYPT_EMAIL=you@example.com
          - DNSDIST_DNSCRYPT=yes
          - DNSDIST_DNS_OVER_TLS=yes
          - DNSDIST_DNS_OVER_TLS_DOMAIN=dot.example.com
        volumes:
          - "./blacklist.txt:/etc/dnsdist/blacklist.txt:ro"
        volumes_from:
          - gateway:ro
        networks:
          - recursor
        ports:
          - "853:853/tcp"
          - "8443:8443/udp"
          - "8443:8443/tcp"
    
      recursor:
        image: chrisss404/powerdns:latest-recursor
        networks:
          recursor:
            ipv4_address: 172.31.117.117
    
    networks:
      recursor:
        ipam:
          driver: default
          config:
            - subnet: "172.31.117.0/24"

Create `blacklist.txt` like this:

    googleadservices.com
    ...

Then

    # start secure recursor (restart dnsdist when let's encrypt certificate is ready)
    docker-compose -f secure-recursor.yml up
    
    # get DNSCrypt provider public key fingerprint
    docker-compose -f secure-recursor.yml exec dnsdist dnsdist -e 'printDNSCryptProviderFingerprint("/var/lib/dnsdist/providerPublic.key")'
    
    # create DNS stamp using python dnsstamps library
    dnsstamp.py dnscrypt -s -a 1.2.3.4:8443 -n 2.dnscrypt-cert.example.com -k 2251:468C:FE4C:C39F:9DF3:C2BA:7C95:ED8F:94F6:06BC:7A24:0493:D168:DE9E:7682:E8AD

### Connect using DNSCrypt Proxy

* Install dnscrypt proxy as described [here](https://github.com/jedisct1/dnscrypt-proxy/wiki/Installation#os-specific-instructions).
* Configure dnscrypt proxy to use previously created dnsstamp, e.g.: vim /etc/dnscrypt-proxy/dnscrypt-proxy.toml

```diff
-server_names = ['cisco', 'cloudflare']
+server_names = ['example']

[static]
+  [static.'example']
+  stamp = 'sdns://AQEAAAAAAAAADDEuMi4zLjQ6ODQ0MyAiUUaM_kzDn53zwrp8le2PlPYGvHokBJPRaN6edoLorRsyLmRuc2NyeXB0LWNlcnQuZXhhbXBsZS5jb20'
```

### Connect using Android

* Go to `Settings` > `Network & Internet` > `Advanced` > `Private DNS` > `Private DNS provider hostname`
* Enter DoT hostname: `dot.example.com`

<a href="https://raw.githubusercontent.com/chrisss404/powerdns/master/android-dot.png"><img src="https://raw.githubusercontent.com/chrisss404/powerdns/master/android-dot.png" height="200"/></a>


## Private Authoritative Server

Create `private-authoritative.yml` like this:

    version: '2'
    
    services:
    
      gateway:
        image: jwilder/nginx-proxy:alpine
        volumes:
          - "/var/run/docker.sock:/tmp/docker.sock:ro"
        networks:
          - gateway
        ports:
          - "80:80"
    
      admin:
        image: chrisss404/powerdns:latest-admin
        depends_on:
          - gateway
          - admin-db
          - authoritative
        environment:
          - VIRTUAL_PROTO=uwsgi
          - VIRTUAL_HOST=admin.example.com
          - VIRTUAL_PORT=3031
          - ADMIN_PDNS_API_KEY=api-secret-authoritative
          - ADMIN_USER_PASSWORD=very-secret
        networks:
          - gateway
          - admin-db
          - authoritative
    
      admin-db:
        image: postgres:10.4-alpine
        environment:
          - POSTGRES_DB=pda
          - POSTGRES_INITDB_ARGS=--data-checksums
          - POSTGRES_PASSWORD=pda
          - POSTGRES_USER=pda
        networks:
          - admin-db
    
      authoritative:
        image: chrisss404/powerdns:latest-authoritative
        depends_on:
          - authoritative-db
        environment:
          - AUTHORITATIVE_API_KEY=api-secret-authoritative
          - AUTHORITATIVE_WEBSERVER=yes
          - AUTHORITATIVE_WEBSERVER_PASSWORD=web-secret-authoritative
        networks:
          authoritative:
            ipv4_address: 172.31.118.118
          authoritative-db:
        ports:
          - "8081:8081/tcp"
    
      authoritative-db:
        image: postgres:10.4-alpine
        environment:
          - POSTGRES_DB=pdns
          - POSTGRES_INITDB_ARGS=--data-checksums
          - POSTGRES_PASSWORD=pdns
          - POSTGRES_USER=pdns
        networks:
          - authoritative-db
    
      dnsdist:
        image: chrisss404/powerdns:latest-dnsdist
        environment:
          - DNSDIST_API_KEY=api-secret-dnsdist
          - DNSDIST_QUIET=no
          - DNSDIST_WEBSERVER=yes
          - DNSDIST_WEBSERVER_PASSWORD=web-secret-dnsdist
          - DNSDIST_PLAIN=yes
        networks:
          - recursor
        ports:
          - "1053:53/tcp"
          - "1053:53/udp"
          - "8083:8083/tcp"
    
      recursor:
        image: chrisss404/powerdns:latest-recursor
        environment:
          - RECURSOR_API_KEY=api-secret-recursor
          - RECURSOR_DNSSEC=validate
          - RECURSOR_FORWARD_ZONES=sys=172.31.118.118
          - RECURSOR_QUIET=no
          - RECURSOR_TRUST_ANCHORS=sys=54970 13 1 27efe1c1a790c3cbb43b947d6d6dfac62507097e
          - RECURSOR_WEBSERVER=yes
          - RECURSOR_WEBSERVER_PASSWORD=web-secret-recursor
        networks:
          recursor:
            ipv4_address: 172.31.117.117
          authoritative:
        ports:
          - "8082:8082/tcp"
    
    networks:
      gateway:
      admin-db:
      authoritative:
        ipam:
          driver: default
          config:
            - subnet: "172.31.118.0/24"
      authoritative-db:
      recursor:
        ipam:
          driver: default
          config:
            - subnet: "172.31.117.0/24"


Then

    # start powerdns stack
    docker-compose -f private-authoritative.yml up
    
    # send DNS queries
    dig -p 1053 example.com

    # PowerDNS admin interface
    http://admin.example.com
    
    # PowerDNS authoritative stats
    http://localhost:8081

    # PowerDNS recursor stats
    http://localhost:8082

    # PowerDNS dnsdist stats
    http://localhost:8083


## Settings

### Admin

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


### Authoritative

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


### Dnsdist

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


### Recursor

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

