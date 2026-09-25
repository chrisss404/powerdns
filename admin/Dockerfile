FROM alpine:3.24 AS builder

ENV FLASK_APP=/build/powerdnsadmin/__init__.py

ARG ADMIN_VERSION="nightly"

ARG BUILD_DEPENDENCIES="build-base \
    cargo \
    git \
    libffi-dev \
    libpq-dev \
    libxml2-dev \
    mariadb-connector-c-dev \
    npm \
    openldap-dev \
    python3-dev \
    xmlsec-dev"

# Get dependencies
RUN apk add --no-cache ${BUILD_DEPENDENCIES} py3-pip && \
    npm install -g corepack@latest --force && \
        corepack enable && \
        corepack prepare yarn@4.1.0 --activate && \
    rm /usr/lib/python3.14/EXTERNALLY-MANAGED

# Download sources
RUN git clone -n https://github.com/ngoduykhanh/PowerDNS-Admin.git /build && \
    cd /build && \
    git checkout $([ "${ADMIN_VERSION}" = "nightly" ] && echo "master" || echo "${ADMIN_VERSION}")

WORKDIR /build

# Get application dependencies
RUN npm install && \
    pip install -r requirements.txt

# Prepare assets
RUN yarn cache clean && \
    sed -i -r -e "s|'rcssmin',\s?'cssrewrite'|'rcssmin'|g" /build/powerdnsadmin/assets.py && \
    mv /build/node_modules /build/powerdnsadmin/static && \
    SESSION_TYPE=filesystem SQLALCHEMY_DATABASE_URI=sqlite:///:memory: flask assets build

RUN mv /build/powerdnsadmin/static /tmp/static && \
    mkdir /build/powerdnsadmin/static && \
    cp -r /tmp/static/generated /build/powerdnsadmin/static && \
    cp -r /tmp/static/assets /build/powerdnsadmin/static && \
    cp -r /tmp/static/img /build/powerdnsadmin/static && \
    cp -a /tmp/static/node_modules/@fortawesome/fontawesome-free/webfonts /build/powerdnsadmin/static

RUN { \
      echo "from flask_assets import Environment"; \
      echo "assets = Environment()"; \
      echo "assets.register('js_login', 'generated/login.js')"; \
      echo "assets.register('js_validation', 'generated/validation.js')"; \
      echo "assets.register('css_login', 'generated/login.css')"; \
      echo "assets.register('js_main', 'generated/main.js')"; \
      echo "assets.register('css_main', 'generated/main.css')"; \
    } > /build/powerdnsadmin/assets.py

# Move application
RUN mkdir -p /var/www/pdns-admin && \
    cp -r /build/migrations/ /build/powerdnsadmin/ /build/run.py /var/www/pdns-admin

COPY docker_config.py ./update_db_settings.py /var/www/pdns-admin/

# Cleanup
RUN pip install pip-autoremove "setuptools<81" && \
    pip-autoremove cssmin -y && \
    pip-autoremove jsmin -y && \
    pip-autoremove mysqlclient -y && \
    pip uninstall -y pip-autoremove pytest setuptools && \
    apk del ${BUILD_DEPENDENCIES}


# Build image
FROM alpine:3.24

ENV FLASK_APP=/var/www/pdns-admin/powerdnsadmin/__init__.py

RUN apk add --no-cache libldap postgresql-client py3-gunicorn py3-psycopg2 tzdata xmlsec && \
    addgroup -S pda && \
    adduser -S -D -G pda pda

COPY --from=builder /usr/bin/flask /usr/bin/
COPY --from=builder /usr/lib/python3.14/site-packages /usr/lib/python3.14/site-packages/
COPY --from=builder --chown=pda:pda /var/www/pdns-admin /var/www/pdns-admin/
COPY ./docker-entrypoint.sh /usr/bin/

WORKDIR /var/www/pdns-admin

EXPOSE 3031/tcp

HEALTHCHECK CMD ["wget", "--output-document=-", "--quiet", "--tries=1", "http://127.0.0.1:3031/"]
ENTRYPOINT ["docker-entrypoint.sh"]
CMD [ "gunicorn", "powerdnsadmin:create_app()", "--timeout", "120", "--workers", "4", \
        "--user", "pda", "--group", "pda", "--bind", "0.0.0.0:3031", "--log-level", "info"]
