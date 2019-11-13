#!/bin/bash
#/etc/init.d/zookeeper
DAEMON_PATH=/opt/kafka/bin
DAEMON_NAME=zookeeper
ZOOKEEPER_CONFIG=/opt/kafka/config/zookeeper.properties
# Check that networking is up.
#[ ${NETWORKING} = "no" ] && exit 0

PATH=$PATH:$DAEMON_PATH

current_dir="$(dirname "$0")"
. "$current_dir/configure.sh"

# See how we were called.
case "$1" in
  start)
        CONFIGURED_FILE="$HOME/.zookeeper_configured"
        if [ ! -f $CONFIGURED_FILE ]; then
          configure "ZOOKEEPER__" $ZOOKEEPER_CONFIG
          touch $CONFIGURED_FILE
          echo "Configuring $ZOOKEEPER_CONFIG."
        fi

        # Start daemon.
        pid=`ps ax | grep -i 'org.apache.zookeeper' | grep -v grep | awk '{print $1}'`
        if [ -n "$pid" ]
          then
            echo "Zookeeper is already running";
        else
          echo "Starting $DAEMON_NAME";
          $DAEMON_PATH/zookeeper-server-start.sh $ZOOKEEPER_CONFIG
        fi
        ;;
  stop)
        echo "Shutting down $DAEMON_NAME";
        $DAEMON_PATH/zookeeper-server-stop.sh
        ;;
  restart)
        $0 stop
        sleep 2
        $0 start
        ;;
  status)
        pid=`jps -ml | grep -i 'org.apache.zookeeper' | grep -v grep | awk '{print $1}'`
        if [ -n "$pid" ]
          then
          echo "Zookeeper is Running as PID: $pid"
        else
          echo "Zookeeper is not Running"
        fi
        ;;
  *)
        echo "Usage: $0 {start|stop|restart|status}"
        exit 1
esac

exit 0
