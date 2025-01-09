#!/bin/sh
set -e

if [ "$1" = "dnsdist" ] && [ ! -f /etc/dnsdist/dnsdist.conf ]; then
    mv /etc/dnsdist/dnsdist.conf-dist /etc/dnsdist/dnsdist.conf

    sed -i "s|    setWebserverConfig({password=\"pdns\", apiKey=\"pdns\", acl=\"0.0.0.0/0\"})|    setWebserverConfig({password=\"${DNSDIST_WEBSERVER_PASSWORD:-pdns}\", apiKey=\"${DNSDIST_API_KEY:-pdns}\", acl=\"0.0.0.0/0\"})|g" /etc/dnsdist/dnsdist.conf
fi

if [ "$1" = "dnsdist" ] && [ ! -f /etc/dnsdist/control-socket.conf ]; then
    mv /etc/dnsdist/control-socket.conf-dist /etc/dnsdist/control-socket.conf

    CONSOLE_KEY=`dd if=/dev/urandom bs=1 count=32 status=none | base64`
    sed -i "s|setKey(\".*\")|setKey(\"${CONSOLE_KEY}\")|g" /etc/dnsdist/control-socket.conf
    sed -i "s|setKey(\".*\")|setKey(\"${CONSOLE_KEY}\")|g" /etc/dnsdist/dnsdist.conf
fi

exec "$@"
