#!/bin/bash

KAFKA_HOME=$1
PLUGIN_NAME=$2
VERSION=$3

download_debezium_plugin() {
	local PLUGIN_DIR=${KAFKA_HOME}/plugins/debezium-${PLUGIN_NAME}-connect/${PLUGIN_NAME}

	mkdir -p ${PLUGIN_DIR}
	curl -L --output ${PLUGIN_DIR}.tgz https://repo1.maven.org/maven2/io/debezium/debezium-connector-${PLUGIN_NAME}/${VERSION}.Final/debezium-connector-${PLUGIN_NAME}-${VERSION}.Final-plugin.tar.gz
	curl -L --output ${PLUGIN_DIR}.sha1 https://repo1.maven.org/maven2/io/debezium/debezium-connector-${PLUGIN_NAME}/${VERSION}.Final/debezium-connector-${PLUGIN_NAME}-${VERSION}.Final-plugin.tar.gz.sha1
	sha1sum ${PLUGIN_DIR}.sha1 >${PLUGIN_DIR}.sha1sum
	sha1sum -c ${PLUGIN_DIR}.sha1
	rm -f ${PLUGIN_DIR}.sha1*
	tar xvfz ${PLUGIN_DIR}.tgz -C ${PLUGIN_DIR} --strip-components=1
	rm -vf ${PLUGIN_DIR}.tgz
}

download_debezium_plugin $KAFKA_HOME $PLUGIN_NAME $VERSION
