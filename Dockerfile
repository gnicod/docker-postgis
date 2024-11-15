FROM bitnami/postgresql:13.17.0-debian-12-r0

USER root
RUN apt-get update && \
    apt-get install -y postgresql-13-postgis-3 postgresql-13-postgis-3-scripts && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Add initdb script to create the PostGIS extension
COPY initdb-postgis.sh /docker-entrypoint-initdb.d/

# Ensure script permissions
RUN chmod +x /docker-entrypoint-initdb.d/initdb-postgis.sh

# Set the default user back to the PostgreSQL user
USER 1001

# Expose the default PostgreSQL port
EXPOSE 5432
