FROM alpine:3.24 AS builder

ARG DNSDIST_VERSION="nightly"

ARG COMPILER_FLAGS="-Os -fomit-frame-pointer"
ARG LINKER_FLAGS="-Wl,--as-needed"

# Get dependencies
RUN apk add --no-cache \
        boost-dev \
        curl \
        g++ \
        git \
        lua-dev \
        libedit-dev \
        libsodium-dev \
        lmdb-dev \
        meson \
        nghttp2-dev \
        openssl-dev \
        protobuf-dev \
        py3-pyaml \
        py3-virtualenv \
        ragel \
        re2-dev

# Download sources
RUN git clone -n https://github.com/PowerDNS/pdns.git /build && \
    cd /build && \
    git checkout $([ "${DNSDIST_VERSION}" = "nightly" ] && echo "master" || echo "dnsdist-${DNSDIST_VERSION}")

WORKDIR /build/pdns/dnsdistdist

# Compile
RUN export BUILDER_VERSION=$([ "${DNSDIST_VERSION}" = "nightly" ] && echo `date +%Y-%m-%d` || echo "${DNSDIST_VERSION}") && \
    CFLAGS=${COMPILER_FLAGS} CXXFLAGS=${COMPILER_FLAGS} LDFLAGS=${LINKER_FLAGS} meson setup build \
            --sysconfdir=/etc/dnsdist \
            -Ddnscrypt=enabled \
            -Ddns-over-https=enabled \
            -Ddns-over-tls=enabled \
            -Dlibsodium=enabled \
            -Dre2=enabled \
            -Dsystemd-service=disabled \
            -Ddefault_library=static && \
    meson compile -C build && \
    meson install -C build --strip


# Build image
FROM alpine:3.24

RUN apk add --no-cache abseil-cpp-vlog-config-internal libedit libsodium lmdb lua5.1-libs nghttp2 protobuf re2 tzdata && \
    addgroup -S dnsdist && \
    adduser -S -D -G dnsdist dnsdist && \
    mkdir -p /etc/dnsdist /var/lib/dnsdist && \
    touch /etc/dnsdist/blocklist.txt

COPY --from=builder /usr/local/bin /usr/bin/
COPY ./docker-entrypoint.sh /usr/bin/
COPY ./conf /etc/dnsdist/

VOLUME ["/var/lib/dnsdist"]

EXPOSE 53/tcp 53/udp 443/tcp 853/tcp 8083/tcp 8443/tcp 8443/udp

HEALTHCHECK CMD ["dnsdist", "-C", "/etc/dnsdist/control-socket.conf", "-e", "showVersion()", "||", "exit", "1"]
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["dnsdist", "--supervised", "--disable-syslog", "--uid", "dnsdist", "--gid", "dnsdist"]
