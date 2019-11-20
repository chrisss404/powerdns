FROM alpine AS builder

ARG DNSDIST_VERSION="1.4.0"
ARG H2O_VERSION="2.2.5"

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
        lua-dev \
        libedit-dev \
        libsodium-dev \
        libtool \
        make \
        openssl-dev \
        protobuf-dev \
        py3-virtualenv \
        ragel \
        re2-dev

# Compile and install libh2o
RUN wget https://github.com/h2o/h2o/archive/v${H2O_VERSION}.tar.gz -O - | tar -xz && \
    cd h2o-${H2O_VERSION} && \
    cmake -DCMAKE_INSTALL_PREFIX=/usr -DWITH_BUNDLED_SSL=off . && \
    make && \
    make install && \
    cp /usr/lib64/libh2o-evloop.a /usr/lib/libh2o-evloop.a && \
    cp /usr/lib64/pkgconfig/libh2o-evloop.pc /usr/lib/pkgconfig/libh2o-evloop.pc

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
            --with-protobuf \
            --with-re2 \
            --disable-shared \
            --enable-static && \
    make dist -j $(nproc) && \
    make install-strip


# Build image
FROM alpine:3.9

COPY --from=builder /usr/local/bin /usr/bin/
COPY ./docker-entrypoint.sh /usr/bin/
COPY ./conf /etc/dnsdist/

RUN apk add --no-cache libedit libsodium lua protobuf re2 && \
    addgroup -S dnsdist && \
    adduser -S -D -G dnsdist dnsdist && \
    touch /etc/dnsdist/blacklist.txt && \
    mkdir -p /var/lib/dnsdist

VOLUME ["/var/lib/dnsdist"]

EXPOSE 53/tcp 53/udp 443/tcp 853/tcp 8083/tcp 8443/tcp 8443/udp

HEALTHCHECK CMD ["dnsdist", "-e", "showVersion()", "||", "exit", "1"]
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["dnsdist", "--supervised", "--disable-syslog", "--uid", "dnsdist", "--gid", "dnsdist"]
