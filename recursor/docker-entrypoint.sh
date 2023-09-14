#!/bin/sh
set -e

if [ "$1" = "pdns_recursor" ] && [ ! -f /etc/powerdns/recursor.conf ]; then
    cp /etc/powerdns/recursor.conf-dist /etc/powerdns/recursor.conf

    sed -i "s|# allow-from=127.0.0.0/8, 10.0.0.0/8, 100.64.0.0/10, 169.254.0.0/16, 192.168.0.0/16, 172.16.0.0/12, ::1/128, fc00::/7, fe80::/10|allow-from=${RECURSOR_ALLOW_FROM:-127.0.0.0/8, 10.0.0.0/8, 100.64.0.0/10, 169.254.0.0/16, 192.168.0.0/16, 172.16.0.0/12, ::1/128, fc00::/7, fe80::/10}|g" /etc/powerdns/recursor.conf
    sed -i "s|# api-key=|api-key=${RECURSOR_API_KEY:-pdns}|g" /etc/powerdns/recursor.conf

    sed -i "s|# daemon=no|daemon=no|g" /etc/powerdns/recursor.conf
    sed -i "s|# write-pid=yes|write-pid=no|g" /etc/powerdns/recursor.conf
    sed -i "s|# disable-syslog=no|disable-syslog=yes|g" /etc/powerdns/recursor.conf

    sed -i "s|# dnssec=process|dnssec=${RECURSOR_DNSSEC:-process-no-validate}|g" /etc/powerdns/recursor.conf
    sed -i "s|# dnssec-log-bogus=no|dnssec-log-bogus=yes|g" /etc/powerdns/recursor.conf

    sed -i "s|# forward-zones=|forward-zones=${RECURSOR_FORWARD_ZONES}|g" /etc/powerdns/recursor.conf
    sed -i "s|# forward-zones-recurse=|forward-zones-recurse=${RECURSOR_FORWARD_ZONES_RECURSE}|g" /etc/powerdns/recursor.conf

    sed -i "s|# local-address=127.0.0.1|local-address=0.0.0.0|g" /etc/powerdns/recursor.conf
    sed -i "s|# local-port=53|local-port=53|g" /etc/powerdns/recursor.conf
    sed -i "s|# loglevel=6|loglevel=${RECURSOR_LOGLEVEL:-3}|g" /etc/powerdns/recursor.conf
    sed -i "s|# lua-config-file=|lua-config-file=/etc/powerdns/config.lua|g" /etc/powerdns/recursor.conf
    sed -i "s|# lua-dns-script=|lua-dns-script=/etc/powerdns/dns.lua|g" /etc/powerdns/recursor.conf

    sed -i "s|# quiet=yes|quiet=${RECURSOR_QUIET:-no}|g" /etc/powerdns/recursor.conf
    sed -i "s|# socket-dir=|socket-dir=/var/run|g" /etc/powerdns/recursor.conf
    sed -i "s|# version-string=.*|version-string=anonymous|g" /etc/powerdns/recursor.conf
    sed -i "s|# tcp-fast-open=0|tcp-fast-open=${RECURSOR_TCP_FAST_OPEN:-0}|g" /etc/powerdns/recursor.conf
    sed -i "s|# threads=2|threads=${RECURSOR_THREADS:-2}|g" /etc/powerdns/recursor.conf
    sed -i "s|# trace=no|trace=fail|g" /etc/powerdns/recursor.conf

    sed -i "s|# webserver=no|webserver=${RECURSOR_WEBSERVER:-no}|g" /etc/powerdns/recursor.conf
    sed -i "s|# webserver-address=127.0.0.1|webserver-address=0.0.0.0|g" /etc/powerdns/recursor.conf
    sed -i "s|# webserver-allow-from=127.0.0.1, ::1|webserver-allow-from=0.0.0.0/0,::/0|g" /etc/powerdns/recursor.conf
    sed -i "s|# webserver-password=|webserver-password=${RECURSOR_WEBSERVER_PASSWORD:-pdns}|g" /etc/powerdns/recursor.conf
    sed -i "s|# webserver-port=8082|webserver-port=8082|g" /etc/powerdns/recursor.conf

    sed -i "s|# security-poll-suffix=.*|security-poll-suffix=${RECURSOR_SECURITY_POLL_SUFFIX:-secpoll.powerdns.com.}|g" /etc/powerdns/recursor.conf

    echo "pdnslog('Loading Lua Configuration')" > /etc/powerdns/config.lua
    if [ -n "${RECURSOR_TRUST_ANCHORS}" ]; then
        echo "${RECURSOR_TRUST_ANCHORS//,/$'\n'}" | while read anchor ; do
            zone=$(echo "${anchor}" | cut -d= -f1)
            key=$(echo "${anchor}" | cut -d= -f2)
            echo "addTA(\"${zone}\", \"${key}\")" >> /etc/powerdns/config.lua
        done
    fi

    echo "pdnslog('Loading DNS Interceptors')" > /etc/powerdns/dns.lua
    if [ -n "${RECURSOR_TRUST_ANCHORS}" ]; then
        echo "function preresolve(dq)" >> /etc/powerdns/dns.lua
        echo "    resolved = false" >> /etc/powerdns/dns.lua

        echo "${RECURSOR_TRUST_ANCHORS//,/$'\n'}" | while read anchor ; do
            zone=$(echo "${anchor}" | cut -d= -f1)
            key=$(echo "${anchor}" | cut -d= -f2)
            echo "    if(dq.qtype == pdns.DS and dq.qname:equal(\"${zone}\")) then" >> /etc/powerdns/dns.lua
            echo "        dq:addAnswer(pdns.DS, \"${key}\")" >> /etc/powerdns/dns.lua
            echo "        resolved = true" >> /etc/powerdns/dns.lua
            echo "    end" >> /etc/powerdns/dns.lua
        done

        echo "    return resolved" >> /etc/powerdns/dns.lua
        echo "end" >> /etc/powerdns/dns.lua
    fi
fi

exec "$@"
