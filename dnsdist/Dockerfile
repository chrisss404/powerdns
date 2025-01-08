FROM alpine:3.18 AS builder

ARG DNSDIST_VERSION="1.9.7"

ARG COMPILER_FLAGS="-Os -fomit-frame-pointer"
ARG LINKER_FLAGS="-Wl,--as-needed"

# Get dependencies
RUN apk add --no-cache \
        autoconf \
        automake \
        boost-dev \
        cmake \
        curl \
        file \
        g++ \
        git \
        h2o-dev \
        lua-dev \
        libedit-dev \
        libsodium-dev \
        libtool \
        lmdb-dev \
        make \
        nghttp2-dev \
        openssl-dev \
        protobuf-dev \
        py3-virtualenv \
        ragel \
        re2-dev

# Download sources
RUN git clone -n https://github.com/PowerDNS/pdns.git /build && \
    cd /build && \
    git checkout $([ "${DNSDIST_VERSION}" = "latest" ] && echo "master" || echo "dnsdist-${DNSDIST_VERSION}")

WORKDIR /build/pdns/dnsdistdist

# Compile
RUN export BUILDER_VERSION=$([ "${DNSDIST_VERSION}" = "latest" ] && echo `date +%Y-%m-%d` || echo "${DNSDIST_VERSION}") && \
    sed -i -e "s|dist_man_MANS=\$(MANPAGES)|MANPAGES=\ndist_man_MANS=\$(MANPAGES)|g" Makefile.am && \
    autoreconf -vif && \
    CFLAGS=${COMPILER_FLAGS} CXXFLAGS=${COMPILER_FLAGS} LDFLAGS=${LINKER_FLAGS} ./configure \
            --sysconfdir=/etc/dnsdist \
            --enable-dnscrypt \
            --enable-dns-over-https \
            --enable-dns-over-tls \
            --with-libsodium \
            --with-lua \
            --with-nghttp2 \
            --with-re2 \
            --disable-shared \
            --enable-static && \
    make dist -j $(nproc) && \
    make install-strip


# Build image
FROM alpine:3.18

RUN apk add --no-cache h2o libedit libsodium lmdb lua5.1-libs nghttp2 protobuf re2 tzdata && \
    addgroup -S dnsdist && \
    adduser -S -D -G dnsdist dnsdist && \
    mkdir -p /etc/dnsdist /var/lib/dnsdist && \
    touch /etc/dnsdist/blocklist.txt

COPY --from=builder /usr/local/bin /usr/bin/
COPY ./docker-entrypoint.sh /usr/bin/
COPY ./conf /etc/dnsdist/

VOLUME ["/var/lib/dnsdist"]

EXPOSE 53/tcp 53/udp 443/tcp 853/tcp 8083/tcp 8443/tcp 8443/udp

HEALTHCHECK CMD ["dnsdist", "-e", "showVersion()", "||", "exit", "1"]
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["dnsdist", "--supervised", "--disable-syslog", "--uid", "dnsdist", "--gid", "dnsdist"]
