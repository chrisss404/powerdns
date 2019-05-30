#!/bin/sh
set -e

if [ "$1" = "dnsdist" ] && [ ! -f /etc/dnsdist/dnsdist.conf ]; then
    mv /etc/dnsdist/dnsdist.conf-dist /etc/dnsdist/dnsdist.conf

    sed -i "s|    webserver(\"0.0.0.0:8083\", \"pdns\", \"pdns\")|    webserver(\"0.0.0.0:8083\", \"${DNSDIST_WEBSERVER_PASSWORD:-pdns}\", \"${DNSDIST_API_KEY:-pdns}\")|g" /etc/dnsdist/dnsdist.conf
fi

exec "$@"
