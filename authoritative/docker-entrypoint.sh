#!/bin/sh
set -e

if [ "$1" = "pdns_server" ] && [ ! -f /etc/pdns/pdns.conf ]; then
    cp /etc/pdns/pdns.conf-dist /etc/pdns/pdns.conf

    sed -i "s|# api=no|api=${AUTHORITATIVE_API:-no}|g" /etc/pdns/pdns.conf
    sed -i "s|# api-key=|api-key=${AUTHORITATIVE_API_KEY:-pdns}|g" /etc/pdns/pdns.conf
    sed -i "s|# api-readonly=no|api-readonly=${AUTHORITATIVE_API_READONLY:-no}|g" /etc/pdns/pdns.conf

    sed -i "s|# daemon=no|daemon=no|g" /etc/pdns/pdns.conf
    sed -i "s|# guardian=no|guardian=no|g" /etc/pdns/pdns.conf
    sed -i "s|# write-pid=yes|write-pid=no|g" /etc/pdns/pdns.conf
    sed -i "s|# disable-syslog=no|disable-syslog=yes|g" /etc/pdns/pdns.conf
    sed -i "s|# disable-tcp=no|disable-tcp=no|g" /etc/pdns/pdns.conf

    sed -i "s|# local-address=0.0.0.0|local-address=0.0.0.0|g" /etc/pdns/pdns.conf
    sed -i "s|# local-port=53|local-port=53|g" /etc/pdns/pdns.conf

    sed -i "s|# master=no|master=${AUTHORITATIVE_MASTER:-yes}|g" /etc/pdns/pdns.conf
    sed -i "s|# slave=no|slave=${AUTHORITATIVE_SLAVE:-no}|g" /etc/pdns/pdns.conf
    sed -i "s|# version-string=.*|version-string=anonymous|g" /etc/pdns/pdns.conf

    sed -i "s|# webserver=no|webserver=${AUTHORITATIVE_WEBSERVER:-no}|g" /etc/pdns/pdns.conf
    sed -i "s|# webserver-address=127.0.0.1|webserver-address=0.0.0.0|g" /etc/pdns/pdns.conf
    sed -i "s|# webserver-allow-from=127.0.0.1,::1|webserver-allow-from=0.0.0.0/0,::/0|g" /etc/pdns/pdns.conf
    sed -i "s|# webserver-password=|webserver-password=${AUTHORITATIVE_WEBSERVER_PASSWORD:-pdns}|g" /etc/pdns/pdns.conf
    sed -i "s|# webserver-port=8081|webserver-port=8081|g" /etc/pdns/pdns.conf

    sed -i "s|# launch=|launch=gpgsql|g" /etc/pdns/pdns.conf
    echo "gpgsql-user=${DB_USER:-pdns}" >> /etc/pdns/pdns.conf
    echo "gpgsql-host=${DB_HOST:-authoritative-db}" >> /etc/pdns/pdns.conf
    echo "gpgsql-port=${DB_PORT:-5432}" >> /etc/pdns/pdns.conf
    echo "gpgsql-password=${DB_PASS:-pdns}" >> /etc/pdns/pdns.conf
    echo "gpgsql-dbname=${DB_NAME:-pdns}" >> /etc/pdns/pdns.conf
    echo "gpgsql-dnssec=yes" >> /etc/pdns/pdns.conf

    attempts=0
    while ! psql "host=${DB_HOST:-authoritative-db} dbname=${DB_NAME:-pdns} user=${DB_USER:-pdns} password=${DB_PASS:-pdns} port=${DB_PORT:-5432}" >/dev/null 2>&1; do
      if test "${attempts}" -ge 15; then
        echo "Unable to connect to postgres db"
        exit 1
      fi

      echo "Waiting for connection to postgres db"
      sleep ${attempts}
      attempts=$(expr "${attempts}" + 1)
    done

    if psql "host=${DB_HOST:-authoritative-db} dbname=${DB_NAME:-pdns} user=${DB_USER:-pdns} password=${DB_PASS:-pdns} port=${DB_PORT:-5432}" -c "SELECT 1 FROM domains" >/dev/null 2>&1; then
      echo "Already provisioned postgres db"
    else
      echo "Provisioning postgres db"
      psql "host=${DB_HOST:-authoritative-db} dbname=${DB_NAME:-pdns} user=${DB_USER:-pdns} password=${DB_PASS:-pdns} port=${DB_PORT:-5432}" < /usr/share/doc/pdns/schema.pgsql.sql
    fi
fi

exec "$@"
