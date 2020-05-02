FROM alpine:3.11 AS builder

ARG PDNS_VERSION="latest"

ARG COMPILER_FLAGS="-Os -fomit-frame-pointer"
ARG LINKER_FLAGS="-Wl,--as-needed"

# Get dependencies
RUN apk add --no-cache \
        autoconf \
        automake \
        bison \
        boost-dev \
        curl \
        curl-dev \
        file \
        flex \
        g++ \
        git \
        libsodium-dev \
        libtool \
        lua-dev \
        make \
        openssl-dev \
        postgresql-dev \
        protobuf-dev \
        py3-virtualenv \
        ragel

# Download sources
RUN git clone -n https://github.com/PowerDNS/pdns.git /build && \
    cd /build && \
    git checkout $([ "${PDNS_VERSION}" = "latest" ] && echo "master" || echo "auth-${PDNS_VERSION}")

WORKDIR /build

# Compile
RUN export BUILDER_VERSION=$([ "${PDNS_VERSION}" = "latest" ] && echo `date +%Y-%m-%d` || echo "${PDNS_VERSION}") && \
    tee docs/Makefile.am && \
    autoreconf -vif && \
    CFLAGS=${COMPILER_FLAGS} CXXFLAGS=${COMPILER_FLAGS} LDFLAGS=${LINKER_FLAGS} ./configure \
            --sysconfdir=/etc/pdns \
            --with-dynmodules= \
            --with-libsodium \
            --with-modules="gpgsql" \
            --with-protobuf \
            --disable-shared \
            --enable-static && \
    make dist -j $(nproc) && \
    make install-strip && \
    mkdir /etc/pdns/conf.d


# Build image
FROM alpine:3.11

RUN apk add --no-cache boost-program_options libcurl libsodium lua postgresql-client postgresql-libs protobuf && \
    addgroup -S pdns && \
    adduser -S -D -G pdns pdns

COPY --from=builder /usr/local/bin /usr/bin/
COPY --from=builder /usr/local/sbin /usr/sbin/
COPY --from=builder /usr/local/share/doc/pdns /usr/share/doc/pdns/
COPY --from=builder /etc/pdns /etc/pdns/
COPY ./docker-entrypoint.sh /usr/bin/

EXPOSE 53/tcp 53/udp 8081/tcp

HEALTHCHECK CMD ["pdns_control", "rping", "||", "exit", "1"]
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["pdns_server", "--setuid=pdns", "--setgid=pdns"]
