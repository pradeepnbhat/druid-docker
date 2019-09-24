#!/bin/bash
set -e

# Abort if no server type is given
if [ "${1:0:1}" = '' ]; then
    echo "Aborting: No druid server type set!"
    exit 1
fi

DB_CONNECT_URI="jdbc:${DB_TYPE}\:\/\/${DB_HOST}\:${DB_PORT}\/${DB_DBNAME}"

mkdir /opt/druid/conf/druid/_extension
echo 'druid.extensions.directory=/opt/druid/extensions' > /opt/druid/conf/druid/_extension/common.runtime.properties

sed -ri 's#druid.zk.service.host.*#druid.zk.service.host='${ZOOKEEPER_HOST}'#g' /opt/druid/conf/druid/_common/common.runtime.properties
sed -ri 's#druid.metadata.storage.type.*#druid.metadata.storage.type='${DB_TYPE}'#g' /opt/druid/conf/druid/_common/common.runtime.properties
sed -ri 's#druid.metadata.storage.connector.connectURI.*#druid.metadata.storage.connector.connectURI='${DB_CONNECT_URI}'#g' /opt/druid/conf/druid/_common/common.runtime.properties
sed -ri 's#druid.metadata.storage.connector.user.*#druid.metadata.storage.connector.user='${DB_USERNAME}'#g' /opt/druid/conf/druid/_common/common.runtime.properties
sed -ri 's#druid.metadata.storage.connector.password.*#druid.metadata.storage.connector.password='${DB_PASSWORD}'#g' /opt/druid/conf/druid/_common/common.runtime.properties
sed -ri 's#druid.azure.account.*#druid.azure.account='${AZURE_ACCOUNT}'#g' /opt/druid/conf/druid/_common/common.runtime.properties
sed -ri 's#druid.azure.key.*#druid.azure.key='${AZURE_KEY}'#g' /opt/druid/conf/druid/_common/common.runtime.properties
sed -ri 's#druid.azure.container.*#druid.azure.container='${AZURE_CONTAINER}'#g' /opt/druid/conf/druid/_common/common.runtime.properties
# sed -ri 's#druid.storage.bucket.*#druid.storage.bucket='${S3_STORAGE_BUCKET}'#g' /opt/druid/conf/druid/_common/common.runtime.properties
# sed -ri 's#druid.indexer.logs.s3Bucket.*#druid.indexer.logs.s3Bucket='${S3_INDEXING_BUCKET}'#g' /opt/druid/conf/druid/_common/common.runtime.properties

if [ "$DRUID_HOSTNAME" != "-" ]; then
    sed -ri 's/druid.host=.*/druid.host='${DRUID_HOSTNAME}'/g' /opt/druid/conf/druid/$1/runtime.properties
fi

if [ "$DRUID_LOGLEVEL" != "-" ]; then
    sed -ri 's/druid.emitter.logging.logLevel=.*/druid.emitter.logging.logLevel='${DRUID_LOGLEVEL}'/g' /opt/druid/conf/druid/_common/common.runtime.properties
fi

if [ "$DRUID_USE_CONTAINER_IP" != "-" ]; then
    ipaddress=`ip a|grep "global eth0"|awk '{print $2}'|awk -F '\/' '{print $1}'`
    sed -ri 's/druid.host=.*/druid.host='${ipaddress}'/g' /opt/druid/conf/druid/$1/runtime.properties
fi

# if [ "$DRUID_SEGMENTCACHE_LOCATION" != "-" ]; then
#     # sed -ri 's/druid.segmentCache.locations=[{"path":*,"maxSize"\:100000000000}]/druid.segmentCache.locations=[{"path":'${DRUID_SEGMENTCACHE_LOCATION}',"maxSize"\:100000000000}]/g' /opt/druid/conf/druid/$1/runtime.properties
#     sed -ri 's/var\/druid\/segment-cache/'${DRUID_SEGMENTCACHE_LOCATION}'/g' /opt/druid/conf/druid/$1/runtime.properties
# fi
#
# if [ "$DRUID_DEEPSTORAGE_LOCAL_DIR" != "-" ]; then
#     sed -ri 's/druid.storage.storageDirectory=.*/druid.storage.storageDirectory='${DRUID_DEEPSTORAGE_LOCAL_DIR}'/g' /opt/druid/conf/druid/_common/common.runtime.properties
# fi

java -cp /opt/druid/conf/druid/_extension:/opt/druid/lib/* org.apache.druid.cli.Main tools pull-deps -r "https://repo1.maven.org/maven2/" -c org.apache.druid.extensions.contrib:druid-azure-extensions:0.15.1-incubating --no-default-hadoop
java ${JAVA_OPTS} -cp /opt/druid/conf/druid/_common:/opt/druid/conf/druid/$1:/opt/druid/lib/*:/opt/druid/extensions/druid-azure-extensions/* org.apache.druid.cli.Main server $@
