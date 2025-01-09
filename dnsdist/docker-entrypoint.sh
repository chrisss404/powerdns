#!/bin/sh
set -e

if [ "$1" = "dnsdist" ] && [ ! -f /etc/dnsdist/dnsdist.conf ]; then
    mv /etc/dnsdist/dnsdist.conf-dist /etc/dnsdist/dnsdist.conf
    CONSOLE_KEY=`dd if=/dev/urandom bs=1 count=32 status=none | base64`

    sed -i "s|setKey(\"replaceMe\")|setKey(\"${CONSOLE_KEY}\")|g" /etc/dnsdist/dnsdist.conf
    sed -i "s|    setWebserverConfig({password=\"pdns\", apiKey=\"pdns\", acl=\"0.0.0.0/0\"})|    setWebserverConfig({password=\"${DNSDIST_WEBSERVER_PASSWORD:-pdns}\", apiKey=\"${DNSDIST_API_KEY:-pdns}\", acl=\"0.0.0.0/0\"})|g" /etc/dnsdist/dnsdist.conf

    echo "-- Expose commandline console" > /etc/dnsdist/control-socket.conf
    echo "controlSocket('127.0.0.1:5199')" >> /etc/dnsdist/control-sockett.conf
    echo "setKey(\"${CONSOLE_KEY}\")" >> /etc/dnsdist/control-socket.conf
fi

exec "$@"
