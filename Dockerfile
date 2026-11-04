# syntax=docker/dockerfile:1

# The download runs on the build platform, so multi-arch builds don't fetch and
# unpack Kafka once per architecture under QEMU.
FROM --platform=$BUILDPLATFORM alpine:3.24 AS download

ARG SCALA_VERSION="2.13"
ARG KAFKA_VERSION="4.4.0"

RUN apk add --no-cache curl

# The CDN and main site only host currently supported releases; older ones live in the archive.
RUN set -eu; \
    file="kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz"; \
    for base in https://dlcdn.apache.org/kafka https://downloads.apache.org/kafka https://archive.apache.org/dist/kafka; do \
      curl -fsSL --connect-timeout 15 --speed-limit 10240 --speed-time 30 --retry 2 -o "/tmp/$file" "$base/$KAFKA_VERSION/$file" \
        && curl -fsSL --connect-timeout 15 --speed-limit 10240 --speed-time 30 --retry 2 -o "/tmp/$file.sha512" "$base/$KAFKA_VERSION/$file.sha512" \
        && break; \
    done; \
    expected="$(tr -d ' \n' < "/tmp/$file.sha512" | cut -d: -f2 | tr 'A-F' 'a-f')"; \
    echo "$expected  /tmp/$file" | sha512sum -c -; \
    mkdir -p /opt/kafka; \
    tar -xzf "/tmp/$file" -C /opt/kafka --strip-components=1; \
    rm -rf /opt/kafka/site-docs /opt/kafka/bin/windows

FROM eclipse-temurin:21-jre-alpine

ARG KAFKA_VERSION="4.4.0"

ENV KAFKA_HOME=/opt/kafka \
    PATH=/opt/kafka/bin:$PATH \
    LOG_DIR=/var/lib/kafka/logs \
    KAFKA_HEAP_OPTS="-Xms512m -Xmx512m" \
    KAFKA_CLUSTER_ID=5L6g3nShT-eMCtK--X86sw

LABEL org.opencontainers.image.title="kafka" \
      org.opencontainers.image.description="Single-node Apache Kafka (KRaft) for development and testing" \
      org.opencontainers.image.version="${KAFKA_VERSION}" \
      org.opencontainers.image.licenses="MIT"

RUN apk add --no-cache bash \
    && addgroup -S -g 1000 kafka \
    && adduser -S -D -H -u 1000 -G kafka -h /var/lib/kafka kafka

COPY --from=download /opt/kafka /opt/kafka
COPY config/server.properties /etc/kafka/server.properties
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN mkdir -p /var/lib/kafka/data /var/lib/kafka/logs \
    && chown -R kafka:kafka /var/lib/kafka /opt/kafka/config

USER kafka
WORKDIR /var/lib/kafka

EXPOSE 9092
VOLUME ["/var/lib/kafka/data"]

HEALTHCHECK --interval=10s --timeout=3s --start-period=60s --start-interval=1s --retries=3 CMD ["nc", "-z", "127.0.0.1", "9092"]

ENTRYPOINT ["docker-entrypoint.sh"]
