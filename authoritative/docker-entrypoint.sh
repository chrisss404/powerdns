#!/bin/sh
set -e

if [ "$1" = "pdns_server" ] && [ ! -f /etc/pdns/pdns.conf ]; then
    cp /etc/pdns/pdns.conf-dist /etc/pdns/pdns.conf

    sed -i "s|# allow-axfr-ips=127.0.0.0/8,::1|allow-axfr-ips=${AUTHORITATIVE_ALLOW_AXFR_IPS:-127.0.0.0/8,::1}|g" /etc/pdns/pdns.conf
    sed -i "s|# allow-notify-from=0.0.0.0/0,::/0|allow-notify-from=${AUTHORITATIVE_ALLOW_NOTIFY_FROM:-0.0.0.0/0,::/0}|g" /etc/pdns/pdns.conf

    sed -i "s|# api=no|api=${AUTHORITATIVE_API:-no}|g" /etc/pdns/pdns.conf
    sed -i "s|# api-key=|api-key=${AUTHORITATIVE_API_KEY:-pdns}|g" /etc/pdns/pdns.conf
    sed -i "s|# api-readonly=no|api-readonly=${AUTHORITATIVE_API_READONLY:-no}|g" /etc/pdns/pdns.conf

    sed -i "s|# daemon=no|daemon=no|g" /etc/pdns/pdns.conf
    sed -i "s|# direct-dnskey=no|direct-dnskey=${AUTHORITATIVE_DIRECT_DNSKEY:-no}|g" /etc/pdns/pdns.conf
    sed -i "s|# disable-axfr=no|disable-axfr=${AUTHORITATIVE_DISABLE_AXFR:-yes}|g" /etc/pdns/pdns.conf
    sed -i "s|# guardian=no|guardian=no|g" /etc/pdns/pdns.conf
    sed -i "s|# write-pid=yes|write-pid=no|g" /etc/pdns/pdns.conf
    sed -i "s|# disable-syslog=no|disable-syslog=yes|g" /etc/pdns/pdns.conf
    sed -i "s|# disable-tcp=no|disable-tcp=no|g" /etc/pdns/pdns.conf

    sed -i "s|# local-address=0.0.0.0, ::|local-address=0.0.0.0, ::|g" /etc/pdns/pdns.conf
    sed -i "s|# local-port=53|local-port=53|g" /etc/pdns/pdns.conf
    sed -i "s|# log-dns-details=no|log-dns-details=${AUTHORITATIVE_LOG_DNS_DETAILS:-no}|g" /etc/pdns/pdns.conf
    sed -i "s|# log-dns-queries=no|log-dns-queries=${AUTHORITATIVE_LOG_DNS_QUERIES:-no}|g" /etc/pdns/pdns.conf
    sed -i "s|# loglevel=4|loglevel=${AUTHORITATIVE_LOGLEVEL:-4}|g" /etc/pdns/pdns.conf

    sed -i "s|# master=no|master=${AUTHORITATIVE_MASTER:-no}|g" /etc/pdns/pdns.conf
    sed -i "s|# slave=no|slave=${AUTHORITATIVE_SLAVE:-no}|g" /etc/pdns/pdns.conf
    sed -i "s|# version-string=.*|version-string=anonymous|g" /etc/pdns/pdns.conf

    sed -i "s|# dname-processing=no|dname-processing=${AUTHORITATIVE_DNAME_PROCESSING:-no}|g" /etc/pdns/pdns.conf
    sed -i "s|# expand-alias=no|expand-alias=${AUTHORITATIVE_EXPAND_ALIAS:-no}|g" /etc/pdns/pdns.conf
    sed -i "s|# query-logging=no|query-logging=${AUTHORITATIVE_QUERY_LOGGING:-no}|g" /etc/pdns/pdns.conf
    sed -i "s|# resolver=no|resolver=${AUTHORITATIVE_RESOLVER:-no}|g" /etc/pdns/pdns.conf
    sed -i "s|# reuseport=no|reuseport=${AUTHORITATIVE_REUSEPORT:-no}|g" /etc/pdns/pdns.conf

    sed -i "s|# receiver-threads=1|receiver-threads=${AUTHORITATIVE_RECEIVER_THREADS:-1}|g" /etc/pdns/pdns.conf
    sed -i "s|# retrieval-threads=2|retrieval-threads=${AUTHORITATIVE_RETRIEVAL_THREADS:-2}|g" /etc/pdns/pdns.conf
    sed -i "s|# signing-threads=3|signing-threads=${AUTHORITATIVE_SIGNING_THREADS:-3}|g" /etc/pdns/pdns.conf

    sed -i "s|# max-tcp-connection-duration=0|max-tcp-connection-duration=${AUTHORITATIVE_MAX_TCP_CONNECTION_DURATION:-0}|g" /etc/pdns/pdns.conf
    sed -i "s|# max-tcp-connections=20|max-tcp-connections=${AUTHORITATIVE_MAX_TCP_CONNECTIONS:-20}|g" /etc/pdns/pdns.conf
    sed -i "s|# tcp-fast-open=0|tcp-fast-open=${AUTHORITATIVE_TCP_FAST_OPEN:-0}|g" /etc/pdns/pdns.conf

    sed -i "s|# default-ksk-algorithm=ecdsa256|default-ksk-algorithm=${AUTHORITATIVE_DEFAULT_KSK_ALGORITHM:-ecdsa256}|g" /etc/pdns/pdns.conf
    sed -i "s|# default-ksk-size=0|default-ksk-size=${AUTHORITATIVE_DEFAULT_KSK_SIZE:-0}|g" /etc/pdns/pdns.conf
    sed -i "s|# default-publish-cdnskey=|default-publish-cdnskey=${AUTHORITATIVE_DEFAULT_PUBLISH_CDNSKEY:-}|g" /etc/pdns/pdns.conf
    sed -i "s|# default-publish-cds=|default-publish-cds=${AUTHORITATIVE_DEFAULT_PUBLISH_CDS:-}|g" /etc/pdns/pdns.conf
    sed -i "s|# default-zsk-algorithm=|default-zsk-algorithm=${AUTHORITATIVE_DEFAULT_ZSK_ALGORITHM:-}|g" /etc/pdns/pdns.conf
    sed -i "s|# default-zsk-size=0|default-zsk-size=${AUTHORITATIVE_DEFAULT_ZSK_SIZE:-0}|g" /etc/pdns/pdns.conf

    sed -i "s|# webserver=no|webserver=${AUTHORITATIVE_WEBSERVER:-no}|g" /etc/pdns/pdns.conf
    sed -i "s|# webserver-address=127.0.0.1|webserver-address=0.0.0.0|g" /etc/pdns/pdns.conf
    sed -i "s|# webserver-allow-from=127.0.0.1,::1|webserver-allow-from=0.0.0.0/0,::/0|g" /etc/pdns/pdns.conf
    sed -i "s|# webserver-password=|webserver-password=${AUTHORITATIVE_WEBSERVER_PASSWORD:-pdns}|g" /etc/pdns/pdns.conf
    sed -i "s|# webserver-port=8081|webserver-port=8081|g" /etc/pdns/pdns.conf

    sed -i "s|# security-poll-suffix=.*|security-poll-suffix=${RECURSOR_SECURITY_POOL_SUFFIX:-secpoll.powerdns.com.}|g" /etc/pdns/pdns.conf

    sed -i "s|# launch=|launch=gpgsql|g" /etc/pdns/pdns.conf
    echo "gpgsql-user=${AUTHORITATIVE_DB_USER:-pdns}" >> /etc/pdns/pdns.conf
    echo "gpgsql-host=${AUTHORITATIVE_DB_HOST:-authoritative-db}" >> /etc/pdns/pdns.conf
    echo "gpgsql-port=${AUTHORITATIVE_DB_PORT:-5432}" >> /etc/pdns/pdns.conf
    echo "gpgsql-password=${AUTHORITATIVE_DB_PASS:-pdns}" >> /etc/pdns/pdns.conf
    echo "gpgsql-dbname=${AUTHORITATIVE_DB_NAME:-pdns}" >> /etc/pdns/pdns.conf
    echo "gpgsql-dnssec=yes" >> /etc/pdns/pdns.conf

    attempts=0
    while ! psql "host=${AUTHORITATIVE_DB_HOST:-authoritative-db} dbname=${AUTHORITATIVE_DB_NAME:-pdns} user=${AUTHORITATIVE_DB_USER:-pdns} password=${AUTHORITATIVE_DB_PASS:-pdns} port=${AUTHORITATIVE_DB_PORT:-5432}" -c 'select 1' >/dev/null 2>&1; do
      if test "${attempts}" -ge 15; then
        echo "Unable to connect to postgres db"
        exit 1
      fi

      echo "Waiting for connection to postgres db"
      sleep ${attempts}
      attempts=$(expr "${attempts}" + 1)
    done

    if psql "host=${AUTHORITATIVE_DB_HOST:-authoritative-db} dbname=${AUTHORITATIVE_DB_NAME:-pdns} user=${AUTHORITATIVE_DB_USER:-pdns} password=${AUTHORITATIVE_DB_PASS:-pdns} port=${AUTHORITATIVE_DB_PORT:-5432}" -c "SELECT 1 FROM domains;" >/dev/null 2>&1; then
      echo "Already provisioned postgres db"
    else
      echo "Provisioning postgres db"
      psql "host=${AUTHORITATIVE_DB_HOST:-authoritative-db} dbname=${AUTHORITATIVE_DB_NAME:-pdns} user=${AUTHORITATIVE_DB_USER:-pdns} password=${AUTHORITATIVE_DB_PASS:-pdns} port=${AUTHORITATIVE_DB_PORT:-5432}" < /usr/share/doc/pdns/schema.pgsql.sql
    fi
fi

exec "$@"
