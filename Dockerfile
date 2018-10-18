FROM java:openjdk-8-jre

ARG SCALA_VERSION="2.11"
ARG KAFKA_VERSION="2.0.0"

ENV DEBIAN_FRONTEND noninteractive
ENV KAFKA_HOME /opt/kafka

RUN apt-get update

RUN apt-get install -y wget supervisor dnsutils net-tools vim

RUN wget -q http://apache.mirrors.spacedump.net/kafka/"$KAFKA_VERSION"/kafka_"$SCALA_VERSION"-"$KAFKA_VERSION".tgz -O /tmp/kafka_"$SCALA_VERSION"-"$KAFKA_VERSION".tgz && \
    tar xfz /tmp/kafka_"$SCALA_VERSION"-"$KAFKA_VERSION".tgz -C /opt && \
    rm /tmp/kafka_"$SCALA_VERSION"-"$KAFKA_VERSION".tgz && \
    mv /opt/kafka_"$SCALA_VERSION"-"$KAFKA_VERSION" $KAFKA_HOME

COPY services/kafka services/zookeeper /opt/services/

COPY supervisor/kafka.conf supervisor/zookeeper.conf /etc/supervisor/conf.d/

EXPOSE 2181 9092

CMD ["supervisord", "-n"]
