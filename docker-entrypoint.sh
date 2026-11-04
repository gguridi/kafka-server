#!/usr/bin/env bash
set -euo pipefail

DEFAULT_CONFIG=/etc/kafka/server.properties
CONFIG="$KAFKA_HOME/config/server.properties"

# Replaces any existing line for the key, so overrides never produce duplicates.
set_property() {
  local key=$1 value=$2 tmp
  tmp="$(mktemp)"
  awk -v key="$key" 'index($0, key "=") != 1' "$CONFIG" > "$tmp"
  printf '%s=%s\n' "$key" "$value" >> "$tmp"
  cat "$tmp" > "$CONFIG"
  rm -f "$tmp"
}

# KAFKA__ADVERTISED_LISTENERS=x becomes advertised.listeners=x
apply_environment() {
  local name key
  while IFS= read -r name; do
    key="${name#KAFKA__}"
    key="${key,,}"
    key="${key//_/.}"
    set_property "$key" "${!name}"
  done < <(compgen -e | grep '^KAFKA__' || true)
}

# Any command other than the default runs as-is, e.g. `docker run gguridi/kafka kafka-topics.sh --version`.
if [ "$#" -gt 0 ]; then
  exec "$@"
fi

# Rebuilt on every start so changed environment variables take effect after a restart.
cp "$DEFAULT_CONFIG" "$CONFIG"
apply_environment

# Formatting starts its own JVM, so it is skipped when the storage is already formatted.
log_dir="$(awk -F= '$1 == "log.dirs" { split($2, dirs, ","); print dirs[1] }' "$CONFIG")"
if [ ! -f "$log_dir/meta.properties" ]; then
  kafka-storage.sh format --ignore-formatted --cluster-id "$KAFKA_CLUSTER_ID" --config "$CONFIG"
fi

exec kafka-server-start.sh "$CONFIG"
