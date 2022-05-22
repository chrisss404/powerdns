#!/bin/sh
set -e

if [ "$1" = "pdns_recursor" ] && [ ! -f /etc/pdns-recursor/recursor.conf ]; then
    cp /etc/pdns-recursor/recursor.conf-dist /etc/pdns-recursor/recursor.conf

    sed -i "s|# allow-from=127.0.0.0/8, 10.0.0.0/8, 100.64.0.0/10, 169.254.0.0/16, 192.168.0.0/16, 172.16.0.0/12, ::1/128, fc00::/7, fe80::/10|allow-from=${RECURSOR_ALLOW_FROM:-127.0.0.0/8, 10.0.0.0/8, 100.64.0.0/10, 169.254.0.0/16, 192.168.0.0/16, 172.16.0.0/12, ::1/128, fc00::/7, fe80::/10}|g" /etc/pdns-recursor/recursor.conf
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
    sed -i "s|# loglevel=6|loglevel=${RECURSOR_LOGLEVEL:-3}|g" /etc/pdns-recursor/recursor.conf
    sed -i "s|# lua-config-file=|lua-config-file=/etc/pdns-recursor/config.lua|g" /etc/pdns-recursor/recursor.conf
    sed -i "s|# lua-dns-script=|lua-dns-script=/etc/pdns-recursor/dns.lua|g" /etc/pdns-recursor/recursor.conf

    sed -i "s|# query-local-address6=|query-local-address6=::|g" /etc/pdns-recursor/recursor.conf
    sed -i "s|# quiet=|quiet=${RECURSOR_QUIET:-no}|g" /etc/pdns-recursor/recursor.conf
    sed -i "s|# socket-dir=|socket-dir=/var/run|g" /etc/pdns-recursor/recursor.conf
    sed -i "s|# version-string=.*|version-string=anonymous|g" /etc/pdns-recursor/recursor.conf
    sed -i "s|# tcp-fast-open=0|tcp-fast-open=${RECURSOR_TCP_FAST_OPEN:-0}|g" /etc/pdns-recursor/recursor.conf
    sed -i "s|# threads=2|threads=${RECURSOR_THREADS:-2}|g" /etc/pdns-recursor/recursor.conf
    sed -i "s|# trace=off|trace=fail|g" /etc/pdns-recursor/recursor.conf

    sed -i "s|# webserver=no|webserver=${RECURSOR_WEBSERVER:-no}|g" /etc/pdns-recursor/recursor.conf
    sed -i "s|# webserver-address=127.0.0.1|webserver-address=0.0.0.0|g" /etc/pdns-recursor/recursor.conf
    sed -i "s|# webserver-allow-from=127.0.0.1,::1|webserver-allow-from=0.0.0.0/0,::/0|g" /etc/pdns-recursor/recursor.conf
    sed -i "s|# webserver-password=|webserver-password=${RECURSOR_WEBSERVER_PASSWORD:-pdns}|g" /etc/pdns-recursor/recursor.conf
    sed -i "s|# webserver-port=8082|webserver-port=8082|g" /etc/pdns-recursor/recursor.conf

    sed -i "s|# security-poll-suffix=.*|security-poll-suffix=${RECURSOR_SECURITY_POLL_SUFFIX:-secpoll.powerdns.com.}|g" /etc/pdns-recursor/recursor.conf

    echo "pdnslog('Loading Lua Configuration')" > /etc/pdns-recursor/config.lua
    if [ -n "${RECURSOR_TRUST_ANCHORS}" ]; then
        echo "${RECURSOR_TRUST_ANCHORS//,/$'\n'}" | while read anchor ; do
            zone=$(echo "${anchor}" | cut -d= -f1)
            key=$(echo "${anchor}" | cut -d= -f2)
            echo "addTA(\"${zone}\", \"${key}\")" >> /etc/pdns-recursor/config.lua
        done
    fi

    echo "pdnslog('Loading DNS Interceptors')" > /etc/pdns-recursor/dns.lua
    if [ -n "${RECURSOR_TRUST_ANCHORS}" ]; then
        echo "function preresolve(dq)" >> /etc/pdns-recursor/dns.lua
        echo "    resolved = false" >> /etc/pdns-recursor/dns.lua

        echo "${RECURSOR_TRUST_ANCHORS//,/$'\n'}" | while read anchor ; do
            zone=$(echo "${anchor}" | cut -d= -f1)
            key=$(echo "${anchor}" | cut -d= -f2)
            echo "    if(dq.qtype == pdns.DS and dq.qname:equal(\"${zone}\")) then" >> /etc/pdns-recursor/dns.lua
            echo "        dq:addAnswer(pdns.DS, \"${key}\")" >> /etc/pdns-recursor/dns.lua
            echo "        resolved = true" >> /etc/pdns-recursor/dns.lua
            echo "    end" >> /etc/pdns-recursor/dns.lua
        done

        echo "    return resolved" >> /etc/pdns-recursor/dns.lua
        echo "end" >> /etc/pdns-recursor/dns.lua
    fi
fi

exec "$@"
