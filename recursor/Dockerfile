FROM alpine:3.10 AS builder

ARG RECURSOR_VERSION="latest"

ARG COMPILER_FLAGS="-Os -fomit-frame-pointer"
ARG LINKER_FLAGS="-Wl,--as-needed"

# Get dependencies
RUN apk add --no-cache \
        autoconf \
        automake \
        boost-dev \
        curl \
        file \
        g++ \
        git \
        libsodium-dev \
        libtool \
        lua-dev \
        make \
        openssl-dev \
        protobuf-dev \
        py3-virtualenv \
        ragel

# Download sources
RUN git clone -n https://github.com/PowerDNS/pdns.git /build && \
    cd /build && \
    git checkout $([ "${RECURSOR_VERSION}" = "latest" ] && echo "master" || echo "rec-${RECURSOR_VERSION}")

WORKDIR /build/pdns/recursordist

# Compile
RUN export BUILDER_VERSION=$([ "${RECURSOR_VERSION}" = "latest" ] && echo `date +%Y-%m-%d` || echo "${RECURSOR_VERSION}") && \
    sed -i -e "s|dist_man_MANS=\$(MANPAGES)|MANPAGES=\ndist_man_MANS=\$(MANPAGES)|g" Makefile.am && \
    autoreconf -vif && \
    CFLAGS=${COMPILER_FLAGS} CXXFLAGS=${COMPILER_FLAGS} LDFLAGS=${LINKER_FLAGS} ./configure \
            --sysconfdir=/etc/pdns-recursor \
            --enable-nod \
            --with-libsodium \
            --with-lua \
            --with-protobuf \
            --disable-shared \
            --enable-static && \
    make dist -j $(nproc) && \
    make install-strip


# Build image
FROM alpine:3.10

COPY --from=builder /usr/local/bin /usr/bin/
COPY --from=builder /usr/local/sbin /usr/sbin/
COPY --from=builder /etc/pdns-recursor /etc/pdns-recursor/
COPY ./docker-entrypoint.sh /usr/bin/

RUN apk add --no-cache boost-context boost-filesystem boost-system libsodium lua protobuf && \
    addgroup -S recursor && \
    adduser -S -D -G recursor recursor && \
    echo "pdnslog('Loading Lua Configuration')" > /etc/pdns-recursor/recursor.lua

EXPOSE 53/tcp 53/udp 8082/tcp

HEALTHCHECK CMD ["rec_control", "ping", "||", "exit", "1"]
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["pdns_recursor", "--setuid=recursor", "--setgid=recursor"]
