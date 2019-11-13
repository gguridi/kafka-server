#!/bin/bash

DAEMON_PATH=/opt/kafka/bin
DAEMON_NAME=kafka
KAFKA_CONFIG=/opt/kafka/config/server.properties
# Check that networking is up.
#[ ${NETWORKING} = "no" ] && exit 0

PATH=$PATH:$DAEMON_PATH

current_dir="$(dirname "$0")"
. "$current_dir/configure.sh"

# See how we were called.
case "$1" in
  start)
        CONFIGURED_FILE="$HOME/.kafka_configured"
        if [ ! -f $CONFIGURED_FILE ]; then
          configure "KAFKA__" $KAFKA_CONFIG
          touch $CONFIGURED_FILE
          echo "Configuring $KAFKA_CONFIG."
        fi

        # Wait until Zookeeper started and listens on port 2181.
        while [ -z "`netstat -tln | grep 2181`" ]; do
          echo 'Waiting for Zookeeper to start ...'
          sleep 1
        done
        echo 'Zookeeper started. Proceeding to start Kafka.'

        # Start daemon.
        pid=`jps -ml | grep -i 'kafka.Kafka' | grep -v grep | awk '{print $1}'`
        if [ -n "$pid" ]
          then
            echo "Kafka is already running"
        else
          echo "Starting $DAEMON_NAME"
          $DAEMON_PATH/kafka-server-start.sh $KAFKA_CONFIG
        fi
        ;;
  stop)
        echo "Shutting down $DAEMON_NAME"
        $DAEMON_PATH/kafka-server-stop.sh
        ;;
  restart)
        $0 stop
        sleep 2
        $0 start
        ;;
  status)
        pid=`jps -ml | grep -i 'kafka.Kafka' | grep -v grep | awk '{print $1}'`
        if [ -n "$pid" ]
          then
          echo "Kafka is Running as PID: $pid"
        else
          echo "Kafka is not Running"
        fi
        ;;
  *)
        echo "Usage: $0 {start|stop|restart|status}"
        exit 1
esac

exit 0
