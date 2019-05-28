#!/bin/sh
set -e

if [ "$1" = "dnsdist" ] && [ ! -f /etc/dnsdist/dnsdist.conf ]; then
    mv /etc/dnsdist/dnsdist.conf-dist /etc/dnsdist/dnsdist.conf

    sed -i "s|    addDNSCryptBind.*|addDNSCryptBind(\"0.0.0.0:${DNSDIST_DNSCRYPT_PORT:-8443}\", \"${DNSDIST_DNSCRYPT_PROVIDER_NAME:-2.dnscrypt.example.com}\", \"/var/lib/dnsdist/resolver.cert\", \"/var/lib/dnsdist/resolver.key\")|g" /etc/dnsdist/dnsdist.conf
    sed -i "s|    addDOHLocal.*|    addDOHLocal(\"0.0.0.0:${DNSDIST_DOH_PORT:-443}\", doh_fullchain, doh_key, { doh_path })|g" /etc/dnsdist/dnsdist.conf
    sed -i "s|    addTLSLocal(\"0.0.0.0:853\", dot_fullchain, dot_key)|    addTLSLocal(\"0.0.0.0:${DNSDIST_DOT_PORT:-853}\", dot_fullchain, dot_key)|g" /etc/dnsdist/dnsdist.conf

    sed -i "s|local start_webserver = \"yes\"|local start_webserver = \"${DNSDIST_WEBSERVER:-yes}\"|g" /etc/dnsdist/dnsdist.conf
    sed -i "s|    webserver(\"0.0.0.0:8083\", \"pdns\", \"pdns\")|    webserver(\"0.0.0.0:8083\", \"${DNSDIST_WEBSERVER_PASSWORD:-pdns}\", \"${DNSDIST_API_KEY:-pdns}\")|g" /etc/dnsdist/dnsdist.conf
fi

exec "$@"
