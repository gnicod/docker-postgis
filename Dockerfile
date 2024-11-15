FROM bitnami/postgresql:13.17.0

USER root

ENV POSTGIS_VERSION=3.5.0

RUN install_packages wget gcc make build-essential libxml2-dev libgeos-dev libproj-dev libgdal-dev protobuf-c-compiler \
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

RUN echo '-- Enable PostGIS (includes raster)\n\
CREATE EXTENSION postgis;\n\
-- Enable Topology\n\
CREATE EXTENSION postgis_topology;\n\
' >> activate_postgis.sql \
    && sed -i 's;postgresql_custom_init_scripts;info "Activating PostGIS extensions"\ncp activate_postgis.sql docker-entrypoint-initdb.d/\npostgresql_custom_init_scripts;g' setup.sh


USER 1001
