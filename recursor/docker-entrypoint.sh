#!/bin/sh
set -e

if [ "$1" = "pdns_recursor" ] && [ -f /etc/powerdns/recursor.conf ]; then
    echo "WARNING: the config format has changed, please upgrade. Trying to convert your configuration file to YAML on the fly..."
    echo "https://doc.powerdns.com/recursor/appendices/yamlconversion.html"
    echo ""

    # convert config to yml
    rec_control show-yaml /etc/powerdns/recursor.conf > /etc/powerdns/recursor.yml
fi

if [ "$1" = "pdns_recursor" ] && [ ! -f /etc/powerdns/recursor.yml ]; then
    cp /etc/powerdns/recursor.yml-dist /etc/powerdns/recursor.yml

    yq -i ".incoming.allow_from = [${RECURSOR_ALLOW_FROM:-\"127.0.0.0/8\", \"10.0.0.0/8\", \"100.64.0.0/10\", \"169.254.0.0/16\", \"192.168.0.0/16\", \"172.16.0.0/12\", \"::1/128\", \"fc00::/7\", \"fe80::/10\"}]" /etc/powerdns/recursor.yml
    yq -i ".webservice.api_key = \"${RECURSOR_API_KEY:-pdns}\"" /etc/powerdns/recursor.yml

    yq -i '.recursor.daemon = false' /etc/powerdns/recursor.yml
    yq -i '.recursor.write_pid = false' /etc/powerdns/recursor.yml
    yq -i '.logging.disable_syslog = true' /etc/powerdns/recursor.yml

    yq -i ".dnssec.validation = \"${RECURSOR_DNSSEC:-process-no-validate}\"" /etc/powerdns/recursor.yml
    yq -i '.dnssec.log_bogus = true' /etc/powerdns/recursor.yml

    yq -i ".recursor.forward_zones = [${RECURSOR_FORWARD_ZONES}]" /etc/powerdns/recursor.yml
    yq -i ".recursor.forward_zones_recurse = [${RECURSOR_FORWARD_ZONES_RECURSE}]" /etc/powerdns/recursor.yml

    yq -i '.incoming.listen = ["0.0.0.0"]' /etc/powerdns/recursor.yml
    yq -i '.incoming.port = 53' /etc/powerdns/recursor.yml
    yq -i ".logging.loglevel = ${RECURSOR_LOGLEVEL:-6}" /etc/powerdns/recursor.yml
    yq -i '.recursor.lua_config_file = "/etc/powerdns/config.lua"' /etc/powerdns/recursor.yml
    yq -i '.recursor.lua_dns_script = "/etc/powerdns/dns.lua"' /etc/powerdns/recursor.yml

    yq -i ".logging.quiet = ${RECURSOR_QUIET:-false}" /etc/powerdns/recursor.yml
    yq -i '.recursor.socket_dir = "/var/run"' /etc/powerdns/recursor.yml
    yq -i '.recursor.version_string = "anonymous"' /etc/powerdns/recursor.yml
    yq -i ".incoming.tcp_fast_open = ${RECURSOR_TCP_FAST_OPEN:-0}" /etc/powerdns/recursor.yml
    yq -i ".recursor.threads = ${RECURSOR_THREADS:-2}" /etc/powerdns/recursor.yml
    yq -i '.logging.trace = "fail"' /etc/powerdns/recursor.yml

    yq -i ".webservice.webserver = ${RECURSOR_WEBSERVER:-false}" /etc/powerdns/recursor.yml
    yq -i '.webservice.address = "0.0.0.0"' /etc/powerdns/recursor.yml
    yq -i '.webservice.allow_from = ["0.0.0.0/0", "::/0"]' /etc/powerdns/recursor.yml
    yq -i ".webservice.password = \"${RECURSOR_WEBSERVER_PASSWORD:-pdns}\"" /etc/powerdns/recursor.yml
    yq -i '.webservice.port = 8082' /etc/powerdns/recursor.yml

    yq -i ".recursor.security_poll_suffix = \"${RECURSOR_SECURITY_POLL_SUFFIX:-secpoll.powerdns.com.}\"" /etc/powerdns/recursor.yml

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
