#!/bin/sh
set -e

if [ "$1" = "gunicorn" ] && [ ! -f /var/www/pdns-admin/powerdnsadmin/docker_config.py ]; then
    cat /var/www/pdns-admin/powerdnsadmin/default_config.py /var/www/pdns-admin/docker_config.py > /var/www/pdns-admin/powerdnsadmin/docker_config.py

    sed -i "s|SQLA_DB_USER = 'pda'|SQLA_DB_USER = '${ADMIN_DB_USER:-pda}'|g" /var/www/pdns-admin/powerdnsadmin/docker_config.py
    sed -i "s|SQLA_DB_PASSWORD = 'changeme'|SQLA_DB_PASSWORD = '${ADMIN_DB_PASS:-pda}'|g" /var/www/pdns-admin/powerdnsadmin/docker_config.py
    sed -i "s|SQLA_DB_HOST = '127.0.0.1'|SQLA_DB_HOST = '127.0.0.1'\nSQLA_DB_PORT = ${ADMIN_DB_PORT:-5432}|g" /var/www/pdns-admin/powerdnsadmin/docker_config.py
    sed -i "s|SQLA_DB_HOST = '127.0.0.1'|SQLA_DB_HOST = '${ADMIN_DB_HOST:-admin-db}'|g" /var/www/pdns-admin/powerdnsadmin/docker_config.py
    sed -i "s|SQLA_DB_NAME = 'pda'|SQLA_DB_NAME = '${ADMIN_DB_NAME:-pda}'|g" /var/www/pdns-admin/powerdnsadmin/docker_config.py
    sed -i "s|SQLALCHEMY_DATABASE_URI = 'mysql://'+SQLA_DB_USER+':'+SQLA_DB_PASSWORD+'@'+SQLA_DB_HOST+'/'+SQLA_DB_NAME|SQLALCHEMY_DATABASE_URI = 'postgresql://'+SQLA_DB_USER+':'+SQLA_DB_PASSWORD+'@'+SQLA_DB_HOST+':'+str(SQLA_DB_PORT)+'/'+SQLA_DB_NAME|g" /var/www/pdns-admin/powerdnsadmin/docker_config.py

    attempts=0
    while ! psql "host=${ADMIN_DB_HOST:-admin-db} dbname=${ADMIN_DB_NAME:-pda} user=${ADMIN_DB_USER:-pda} password=${ADMIN_DB_PASS:-pda} port=${ADMIN_DB_PORT:-5432}" >/dev/null 2>&1; do
      if test "${attempts}" -ge 15; then
        echo "Unable to connect to postgres db"
        exit 1
      fi

      echo "Waiting for connection to postgres db"
      sleep ${attempts}
      attempts=$(expr "${attempts}" + 1)
    done

    flask db upgrade
    python3 /var/www/pdns-admin/update_db_settings.py
fi

exec "$@"
