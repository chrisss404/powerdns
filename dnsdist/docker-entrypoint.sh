#!/bin/sh
set -e

if [ "$1" = "dnsdist" ] && [ ! -f /etc/dnsdist/dnsdist.conf ]; then
    mv /etc/dnsdist/dnsdist.conf-dist /etc/dnsdist/dnsdist.conf

    sed -i "s|    setWebserverConfig({password=\"pdns\", apiKey=\"pdns\", acl=\"0.0.0.0/0\"})|    setWebserverConfig({password=\"${DNSDIST_WEBSERVER_PASSWORD:-pdns}\", apiKey=\"${DNSDIST_API_KEY:-pdns}\", acl=\"0.0.0.0/0\"})|g" /etc/dnsdist/dnsdist.conf
fi

exec "$@"
