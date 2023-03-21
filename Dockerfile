FROM quay.io/strimzi/kafka:0.33.2-kafka-3.4.0

ENV KAFKA_HOME=/opt/kafka
ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ARG AWS_DEFAULT_REGION=us-west-2
ARG DEBEZIUM_ORACLE_VERSION=2.1.3
ARG POSTGRES_VERSION=42.5.4
ARG KAFKA_JDBC_VERSION=10.6.1
ENV INSTANT_CLIENT_DIR=/instant_client/
ENV AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
ENV AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
ENV AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION

USER root:root

COPY download-plugins.sh .
RUN chmod +x download-plugins.sh

RUN curl -LJO "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
    && unzip awscli-exe-linux-x86_64.zip \
    && ./aws/install \
    && rm awscli-exe-linux-x86_64.zip

RUN aws s3 cp s3://fount-data/DevOps/instantclient-basiclite-linux.x64-19.18.0.0.0dbru.zip .

RUN unzip instantclient-basiclite-linux.x64-19.18.0.0.0dbru.zip; \
		mkdir -p $INSTANT_CLIENT_DIR; \
		cp instantclient_19_18/ojdbc8.jar ${KAFKA_HOME}/libs; \
		cp instantclient_19_18/xstreams.jar ${KAFKA_HOME}/libs; \
    mv ./instantclient_19_18/* $INSTANT_CLIENT_DIR; \
    rm -rf instantclient_19_18; \
    rm instantclient-basiclite-linux.x64-19.18.0.0.0dbru.zip

RUN set -ex; ./download-plugins.sh $KAFKA_HOME oracle 2.1.3 >> /var/log/download-plugins.log

RUN set -ex; ./download-plugins.sh $KAFKA_HOME postgres 2.1.3 >> /var/log/download-plugins.log

RUN set -ex; mkdir -p ${KAFKA_HOME}/plugins/kafka-connect-jdbc/jdbc \
				&& curl -L --output ${KAFKA_HOME}/plugins/kafka-connect-jdbc/jdbc.jar https://packages.confluent.io/maven/io/confluent/kafka-connect-jdbc/$KAFKA_JDBC_VERSION/kafka-connect-jdbc-$KAFKA_JDBC_VERSION.jar \
				&& curl -L --output ${KAFKA_HOME}/plugins/kafka-connect-jdbc/jdbc.sha1 https://packages.confluent.io/maven/io/confluent/kafka-connect-jdbc/$KAFKA_JDBC_VERSION/kafka-connect-jdbc-$KAFKA_JDBC_VERSION-tests.jar.sha1 \
				&& sha1sum ${KAFKA_HOME}/plugins/kafka-connect-jdbc/jdbc.sha1 > ${KAFKA_HOME}/plugins/kafka-connect-jdbc/jdbc.sha1sum \
				&& sha1sum ${KAFKA_HOME}/plugins/kafka-connect-jdbc/jdbc.sha1sum \
				&& rm -f ${KAFKA_HOME}/plugins/kafka-connect-jdbc/jdbc.sha1*

RUN curl -L --output ${KAFKA_HOME}/libs/postgresql-$POSTGRES_VERSION.jar https://jdbc.postgresql.org/download/postgresql-$POSTGRES_VERSION.jar
COPY NumberToIntegerConverter-1.0.jar ${KAFKA_HOME}/plugins/debezium-oracle-connect/oracle

WORKDIR $KAFKA_HOME
USER 1001
