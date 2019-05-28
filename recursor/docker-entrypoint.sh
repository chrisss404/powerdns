#!/bin/sh
set -e

if [ "$1" = "pdns_recursor" ] && [ ! -f /etc/pdns-recursor/recursor.conf ]; then
    cp /etc/pdns-recursor/recursor.conf-dist /etc/pdns-recursor/recursor.conf

    sed -i "s|# api-key=|api-key=${RECURSOR_API_KEY:-pdns}|g" /etc/pdns-recursor/recursor.conf
    sed -i "s|# api-readonly=no|api-readonly=${RECURSOR_API_READONLY:-yes}|g" /etc/pdns-recursor/recursor.conf

    sed -i "s|# daemon=no|daemon=no|g" /etc/pdns-recursor/recursor.conf
    sed -i "s|# write-pid=yes|write-pid=no|g" /etc/pdns-recursor/recursor.conf
    sed -i "s|# disable-syslog=no|disable-syslog=yes|g" /etc/pdns-recursor/recursor.conf

    sed -i "s|# dnssec=process-no-validate|dnssec=${RECURSOR_DNSSEC:-process-no-validate}|g" /etc/pdns-recursor/recursor.conf
    sed -i "s|# dnssec-log-bogus=no|dnssec-log-bogus=yes|g" /etc/pdns-recursor/recursor.conf

    sed -i "s|# forward-zones=|forward-zones=${RECURSOR_FORWARD_ZONES}|g" /etc/pdns-recursor/recursor.conf
    sed -i "s|# forward-zones-recurse=|forward-zones-recurse=${RECURSOR_FORWARD_ZONES_RECURSE}|g" /etc/pdns-recursor/recursor.conf

    sed -i "s|# local-address=127.0.0.1|local-address=0.0.0.0|g" /etc/pdns-recursor/recursor.conf
    sed -i "s|# local-port=53|local-port=53|g" /etc/pdns-recursor/recursor.conf
    sed -i "s|# lua-config-file=|lua-config-file=/etc/pdns-recursor/recursor.lua|g" /etc/pdns-recursor/recursor.conf

    sed -i "s|# quiet=|quiet=${RECURSOR_QUIET:-no}|g" /etc/pdns-recursor/recursor.conf
    sed -i "s|# version-string=.*|version-string=anonymous|g" /etc/pdns-recursor/recursor.conf
    sed -i "s|# trace=off|trace=fail|g" /etc/pdns-recursor/recursor.conf

    sed -i "s|# webserver=no|webserver=${RECURSOR_WEBSERVER:-no}|g" /etc/pdns-recursor/recursor.conf
    sed -i "s|# webserver-address=127.0.0.1|webserver-address=0.0.0.0|g" /etc/pdns-recursor/recursor.conf
    sed -i "s|# webserver-allow-from=127.0.0.1,::1|webserver-allow-from=0.0.0.0/0,::/0|g" /etc/pdns-recursor/recursor.conf
    sed -i "s|# webserver-password=|webserver-password=${RECURSOR_WEBSERVER_PASSWORD:-pdns}|g" /etc/pdns-recursor/recursor.conf
    sed -i "s|# webserver-port=8082|webserver-port=8082|g" /etc/pdns-recursor/recursor.conf

    if [ -n "${RECURSOR_TRUST_ANCHORS}" ]; then
        echo "${RECURSOR_TRUST_ANCHORS//,/$'\n'}" | while read anchor ; do
            zone=$(echo "${anchor}" | cut -d= -f1)
            key=$(echo "${anchor}" | cut -d= -f2)
            echo "addDS(\"${zone}\", \"${key}\")" >> /etc/pdns-recursor/recursor.lua
        done
    fi
fi

exec "$@"
