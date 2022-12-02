FROM eclipse-temurin:11-jdk-jammy


ARG SCALA_VERSION="2.13"
ARG KAFKA_VERSION="3.3.1"

ENV DEBIAN_FRONTEND noninteractive
ENV KAFKA_HOME /opt/kafka

RUN apt-get update
RUN apt-get install -y openssl ca-certificates curl supervisor net-tools bash
RUN update-ca-certificates

COPY services/ /opt/services/
COPY supervisor/ /etc/supervisor/conf.d/

RUN curl -o /tmp/kafka_"$SCALA_VERSION"-"$KAFKA_VERSION".tgz http://apache.mirror.anlx.net/kafka/"$KAFKA_VERSION"/kafka_"$SCALA_VERSION"-"$KAFKA_VERSION".tgz && \
    tar xvfz /tmp/kafka_"$SCALA_VERSION"-"$KAFKA_VERSION".tgz -C /tmp && \
    rm /tmp/kafka_"$SCALA_VERSION-$KAFKA_VERSION".tgz && \
    mv /tmp/kafka_"$SCALA_VERSION-$KAFKA_VERSION" $KAFKA_HOME

EXPOSE 2181 9092

HEALTHCHECK --interval=10s --timeout=5s --start-period=5s --retries=6 CMD [ "/opt/services/healthcheck.sh" ]

CMD ["supervisord", "-n"]
