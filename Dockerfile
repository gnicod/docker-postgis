FROM bitnami/postgresql:17

USER root

ENV POSTGIS_VERSION=3.5.0

# Install required dependencies
RUN install_packages \
    wget \
    gcc \
    make \
    build-essential \
    libxml2-dev \
    libgeos-dev \
    libproj-dev \
    libgdal-dev \
    protobuf-c-compiler \
    pkg-config \
    libprotobuf-c-dev \
    libjson-c-dev \
    libcunit1-dev \
    postgresql-server-dev-all \
    gdal-bin \
    libgeos++-dev \
    proj-bin \
    proj-data

# Build and install PostGIS
RUN cd /tmp \
    && wget "http://download.osgeo.org/postgis/source/postgis-${POSTGIS_VERSION}.tar.gz" \
    && tar zxf postgis-*.tar.gz \
    && cd postgis-${POSTGIS_VERSION} \
    && export C_INCLUDE_PATH=/opt/bitnami/postgresql/include/:/opt/bitnami/common/include/ \
    && export LIBRARY_PATH=/opt/bitnami/postgresql/lib/:/opt/bitnami/common/lib/ \
    && export LD_LIBRARY_PATH=/opt/bitnami/postgresql/lib/:/opt/bitnami/common/lib/ \
    && ./configure \
        --with-pgconfig=/opt/bitnami/postgresql/bin/pg_config \
        --with-geosconfig=/usr/bin/geos-config \
        --with-projdir=/usr \
    && make \
    && make install

# Create symbolic links for required libraries
RUN LIBPROJ_PATH=$(find /usr/lib -name "libproj.so*" | sort | tail -n 1) \
    && ln -sf $LIBPROJ_PATH /opt/bitnami/postgresql/lib/libproj.so.15 \
    && ln -sf /usr/lib/x86_64-linux-gnu/libgeos_c.so /opt/bitnami/postgresql/lib/ \
    && ln -sf /usr/lib/x86_64-linux-gnu/libgdal.so /opt/bitnami/postgresql/lib/

# Cleanup
RUN apt-get remove --purge --auto-remove -y \
    wget \
    gcc \
    make \
    build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/postgis*

# Keep runtime dependencies
RUN install_packages \
    libgeos-c1v5 \
    libproj-dev \
    proj-data \
    libgdal30

# Create initialization script
RUN mkdir -p /docker-entrypoint-initdb.d \
    && echo 'CREATE EXTENSION IF NOT EXISTS postgis;' > /docker-entrypoint-initdb.d/enable_postgis.sql \
    && echo 'CREATE EXTENSION IF NOT EXISTS postgis_topology;' >> /docker-entrypoint-initdb.d/enable_postgis.sql \
    && echo 'CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder;' >> /docker-entrypoint-initdb.d/enable_postgis.sql

# Set proper permissions
RUN chown -R 1001:1001 /docker-entrypoint-initdb.d \
    && chown -R 1001:1001 /opt/bitnami/postgresql/lib/

USER 1001