#!/usr/bin/env bash

set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

RDS_ENDPOINT=$1
RDS_PG_PORT=$2
RDS_PG_DATABASE=$3
RDS_PG_USERNAME=$4
RDS_PG_PASSWORD=$5

PG_CONN_STR="postgres://$RDS_PG_USERNAME:$RDS_PG_PASSWORD@$RDS_ENDPOINT:$RDS_PG_PORT/$RDS_PG_DATABASE"

# ensure logical replicaiton is enabled
echo "RDS Pre-Init: Logical Replication Check"
psql "$PG_CONN_STR" -v ON_ERROR_STOP=1 --no-password --no-psqlrc -f ./0-enable-logical-replication.sql

# run pre-init scripts
echo "RDS Pre-Init: Installing Extensions"
psql "$PG_CONN_STR" -v ON_ERROR_STOP=1 --no-password --no-psqlrc -f ./1-extensions.sql
psql "$PG_CONN_STR" -v ON_ERROR_STOP=1 --no-password --no-psqlrc -f ./2-pgjwt.sql

# run init scripts
for sql_file in $SCRIPT_DIR/../migrations/db/init-scripts/*.sql; do
    echo "Init: running $sql_file"
    psql "$PG_CONN_STR" -v ON_ERROR_STOP=1 --no-password --no-psqlrc -f "$sql_file"
done

# alter passwords
echo "Alter supabase_admin password"
psql "$PG_CONN_STR" -v ON_ERROR_STOP=1 --no-password --no-psqlrc -c "ALTER USER supabase_admin WITH PASSWORD '$RDS_PG_PASSWORD'"

echo "Alter authenticator password"
psql "$PG_CONN_STR" -v ON_ERROR_STOP=1 --no-password --no-psqlrc -c "ALTER USER authenticator WITH PASSWORD '$RDS_PG_PASSWORD'"

echo "Alter supabase_auth_admin password"
psql "$PG_CONN_STR" -v ON_ERROR_STOP=1 --no-password --no-psqlrc -c "ALTER USER supabase_auth_admin WITH PASSWORD '$RDS_PG_PASSWORD'"

echo "Alter supabase_storage_admin password"
psql "$PG_CONN_STR" -v ON_ERROR_STOP=1 --no-password --no-psqlrc -c "ALTER USER supabase_storage_admin WITH PASSWORD '$RDS_PG_PASSWORD'"


# run migrations
for sql_file in $SCRIPT_DIR/../migrations/db/migrations/*.sql; do
    echo "Init: running $sql_file"
    psql "$PG_CONN_STR" -v ON_ERROR_STOP=1 --no-password --no-psqlrc -f "$sql_file"
done

