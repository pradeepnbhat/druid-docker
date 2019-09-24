# VERSION 0.12.3-2
FROM anapsix/alpine-java:8_server-jre_unlimited

MAINTAINER Pradeep Narayan <pradeepnbhat@gmail.com>
# Forked from https://github.com/maver1ck/druid-docker

ENV DB_HOST            mysql
ENV DB_PORT            3306
ENV DB_DBNAME          druid
ENV DB_USERNAME        druid
ENV DB_PASSWORD        druid
ENV ZOOKEEPER_HOST     zookeeper
ENV DRUID_VERSION      0.15.1-incubating
ENV AZURE_ACCOUNT      '-'
ENV AZURE_KEY          '-'
ENV AZURE_CONTAINER    '-'

# Druid env variable
ENV DRUID_XMX          '16g'
ENV DRUID_XMS          '-'
ENV DRUID_NEWSIZE      '-'
ENV DRUID_MAXNEWSIZE   '-'
ENV DRUID_HOSTNAME     '-'
ENV DRUID_LOGLEVEL     '-'
ENV DRUID_USE_CONTAINER_IP '-'
ENV DRUID_SEGMENTCACHE_LOCATION  '-'
ENV DRUID_DEEPSTORAGE_LOCAL_DIR  '-'

RUN apk update \
    && apk add --no-cache bash curl \
    && mkdir /tmp/druid \
    && curl \
    http://mirrors.sonic.net/apache/incubator/druid/$DRUID_VERSION/apache-druid-$DRUID_VERSION-bin.tar.gz | tar -xzf - -C /opt \
    && ln -s /opt/apache-druid-$DRUID_VERSION /opt/druid
RUN curl http://static.druid.io/artifacts/releases/mysql-metadata-storage-0.12.3.tar.gz | tar -xzf - -C /opt/druid/extensions

COPY conf /opt/druid/conf
COPY start-druid.sh /start-druid.sh

ENTRYPOINT ["/start-druid.sh"]
