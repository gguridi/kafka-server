#!/bin/bash -e

KAFKA_STATUS=$(/opt/services/kafka.sh status)
if [[ "$KAFKA_STATUS" != *"Kafka is Running as PID"* ]]; then
    echo "Exiting: $KAFKA_STATUS"
    exit 1
fi

ZOOKEEPER_STATUS=$(/opt/services/zookeeper.sh status)
if [[ "$ZOOKEEPER_STATUS" != *"Zookeeper is Running as PID"* ]]; then
    echo "Exiting: $ZOOKEEPER_STATUS"
    exit 1
fi

echo "All services up & running..."
exit 0
