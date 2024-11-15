FROM bitnami/postgresql:13.17.0

USER root

ENV POSTGIS_VERSION=3.5.0

RUN install_packages wget gcc make build-essential libxml2-dev libgeos-dev libproj-dev libgdal-dev protobuf-c-compiler libproj15 \
    && cd /tmp \
    && wget "http://download.osgeo.org/postgis/source/postgis-${POSTGIS_VERSION}.tar.gz" \
    && export C_INCLUDE_PATH=/opt/bitnami/postgresql/include/:/opt/bitnami/common/include/ \
    && export LIBRARY_PATH=/opt/bitnami/postgresql/lib/:/opt/bitnami/common/lib/ \
    && export LD_LIBRARY_PATH=/opt/bitnami/postgresql/lib/:/opt/bitnami/common/lib/ \
    && tar zxf postgis-*.tar.gz && cd postgis-${POSTGIS_VERSION} \
    && ./configure --with-pgconfig=/opt/bitnami/postgresql/bin/pg_config \
    && make \
    && make install \
    && apt-get remove --purge --auto-remove -y wget build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/postgis*

# Create initialization script
RUN mkdir -p /docker-entrypoint-initdb.d && \
    echo 'CREATE EXTENSION IF NOT EXISTS postgis;' > /docker-entrypoint-initdb.d/enable_postgis.sql

# Set proper permissions
RUN chown -R 1001:1001 /docker-entrypoint-initdb.d

