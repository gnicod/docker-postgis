#!/bin/bash
set -e

echo "Creating PostGIS extension..."

# Connect to the default database and create the PostGIS extension
psql --username="$POSTGRESQL_USERNAME" --dbname="$POSTGRESQL_DATABASE" <<-EOSQL
  CREATE EXTENSION IF NOT EXISTS postgis;
  CREATE EXTENSION IF NOT EXISTS postgis_topology;
EOSQL

echo "PostGIS extension created successfully."
