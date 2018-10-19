FROM openjdk:8-jre-alpine

ARG SCALA_VERSION="2.12"
ARG KAFKA_VERSION="2.0.0"

ENV DEBIAN_FRONTEND noninteractive
ENV KAFKA_HOME /opt/kafka

RUN apk update
RUN apk add openssl ca-certificates curl supervisor bind-tools net-tools bash
RUN update-ca-certificates

COPY services/kafka services/zookeeper /opt/services/
COPY supervisor/kafka.conf supervisor/zookeeper.conf /etc/supervisor/conf.d/

RUN curl -o /tmp/kafka_"$SCALA_VERSION"-"$KAFKA_VERSION".tgz http://apache.mirror.anlx.net/kafka/"$KAFKA_VERSION"/kafka_"$SCALA_VERSION"-"$KAFKA_VERSION".tgz && \
    tar xvfz /tmp/kafka_"$SCALA_VERSION"-"$KAFKA_VERSION".tgz -C /tmp && \
    rm /tmp/kafka_"$SCALA_VERSION-$KAFKA_VERSION".tgz && \
    mv /tmp/kafka_"$SCALA_VERSION-$KAFKA_VERSION" $KAFKA_HOME

EXPOSE 2181 9092

CMD ["supervisord", "-n"]
