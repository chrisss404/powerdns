#!/bin/bash
set -e

/usr/local/bin/pg_ctl --pgdata="${PGDATA}" stop

rm -rf "${PGDATA}"/*
PGPASSWORD="${POSTGRES_REPLICATION_PASSWORD}" /usr/local/bin/pg_basebackup \
    --host=clu01.auth-db.internal \
    --username=replicator \
    --port=5432 \
    --pgdata="${PGDATA}" \
    --format=plain \
    --wal-method=stream \
    --progress \
    --write-recovery-conf \
    --dbname="sslmode=verify-full sslcert=/var/lib/postgresql/replicator.crt sslkey=/var/lib/postgresql/replicator.key sslrootcert=/var/lib/postgresql/root.crt sslcompression=0"

/usr/local/bin/pg_ctl --pgdata="${PGDATA}" start
