FROM alpine:3.9 AS builder

ARG ADMIN_VERSION="latest"

ARG BUILD_DEPENDENCIES="build-base \
    git \
    libffi-dev \
    libxml2-dev \
    mariadb-connector-c-dev \
    openldap-dev \
    py3-pip \
    python3-dev \
    xmlsec-dev \
    yarn"

# Get dependencies
RUN apk add --no-cache ${BUILD_DEPENDENCIES} && \
    ln -s /usr/bin/pip3 /usr/bin/pip

# Download sources
RUN git clone -n https://github.com/ngoduykhanh/PowerDNS-Admin.git /build && \
    cd /build && \
    git checkout $([ "${ADMIN_VERSION}" = "latest" ] && echo "master" || echo "${ADMIN_VERSION}")

WORKDIR /build

# Get application dependencies
RUN pip install -r requirements.txt

# Prepare assets
RUN cp /build/config_template.py /build/config.py && \
    yarn install --pure-lockfile && \
    sed -i -e "s|'cssmin','cssrewrite'|'cssmin'|g" /build/app/assets.py && \
    flask assets build

RUN mv /build/app/static /tmp/static && \
    mkdir /build/app/static && \
    cp -r /tmp/static/generated /build/app/static && \
    find /tmp/static/node_modules -name 'fonts' -exec cp -r {} /build/app/static \; && \
    find /tmp/static/node_modules/icheck/skins/square -name '*.png' -exec cp {} /build/app/static/generated \;

RUN { \
      echo "from flask_assets import Environment"; \
      echo "assets = Environment()"; \
      echo "assets.register('js_login', 'generated/login.js')"; \
      echo "assets.register('js_validation', 'generated/validation.js')"; \
      echo "assets.register('css_login', 'generated/login.css')"; \
      echo "assets.register('js_main', 'generated/main.js')"; \
      echo "assets.register('css_main', 'generated/main.css')"; \
    } > /build/app/assets.py

# Move application
RUN mkdir -p /var/www/pdns-admin && \
    cp -r /build/app/ /build/config_template.py /build/migrations/ /build/run.py /build/upload/ /var/www/pdns-admin

COPY ./admin.png /var/www/pdns-admin/upload/avatar/
COPY ./update_db_settings.py /var/www/pdns-admin/

# Cleanup
RUN pip install pip-autoremove && \
    pip-autoremove cssmin -y && \
    pip-autoremove jsmin -y && \
    pip-autoremove mysqlclient -y && \
    pip-autoremove pytest -y && \
    pip uninstall -y pip-autoremove && \
    apk del ${BUILD_DEPENDENCIES}


# Build image
FROM alpine:3.9

COPY --from=builder /usr/bin/flask /usr/bin/
COPY --from=builder /usr/lib/python3.6/site-packages /usr/lib/python3.6/site-packages/
COPY --from=builder /var/www/pdns-admin /var/www/pdns-admin/
COPY ./docker-entrypoint.sh /usr/bin/

WORKDIR /var/www/pdns-admin

RUN apk add --no-cache libldap postgresql-client py3-psycopg2 uwsgi uwsgi-python3 && \
    addgroup -S pda && \
    adduser -S -D -G pda pda && \
    chown -R pda:pda /var/www/pdns-admin

VOLUME ["/var/www/pdns-admin/upload"]

EXPOSE 3031/tcp

HEALTHCHECK CMD ["uwsgi", "--connect-and-read", "127.0.0.1:1717", "||", "exit", "1"]
ENTRYPOINT ["docker-entrypoint.sh"]
CMD [ "uwsgi", "--master", "--processes=4", "--threads=2", "--buffer-size", "32768", \
        "--socket", ":3031", "--stats", "127.0.0.1:1717", "--protocol", "uwsgi", \
        "--uid", "pda", "--gid", "pda", \
        "--manage-script-name", "--plugin", "python3", "--mount", "/=run:app" ]
