# Kafka server

![CI](https://github.com/gguridi/kafka-server/actions/workflows/ci.yml/badge.svg?branch=master)

Single-node Apache Kafka images (KRaft, combined broker and controller) for development and testing
environments. They are small and start fast, but are not tuned or secured for production.

Images are published for `linux/amd64` and `linux/arm64` to
[Docker Hub](https://hub.docker.com/r/gguridi/kafka/tags) and `ghcr.io/gguridi/kafka`.

## Usage

```bash
docker run -d -p 9092:9092 gguridi/kafka
```

Clients on the host connect to `localhost:9092`.

### Tags

| Tag          | Example      | Meaning                                       |
| ------------ | ------------ | --------------------------------------------- |
| `latest`     | `latest`     | Newest Kafka version built by this repository |
| `X.Y`        | `4.4`        | Newest patch release of a Kafka minor version |
| `X.Y.Z`      | `4.4.0`      | Exact Kafka version                           |
| `2.13-X.Y.Z` | `2.13-4.4.0` | Exact Kafka version and its Scala version     |

The Kafka versions built are listed in [`kafka-versions.json`](./kafka-versions.json).

### docker compose

When clients run in other containers, advertise the service name instead of `localhost`:

```yaml
services:
  kafka:
    image: gguridi/kafka:4.4
    environment:
      KAFKA__ADVERTISED_LISTENERS: PLAINTEXT://kafka:9092
```

## Configuration

Any `server.properties` key can be set with an environment variable named `KAFKA__` followed by the
property name in upper case, with dots replaced by underscores. Variables are applied on every start.

```bash
docker run -d -p 9092:9092 \
  -e KAFKA__NUM_PARTITIONS=3 \
  -e KAFKA__LOG_RETENTION_HOURS=1 \
  gguridi/kafka
```

The defaults are in [`config/server.properties`](./config/server.properties). Other variables:

| Variable           | Default                  | Purpose                                 |
| ------------------ | ------------------------ | --------------------------------------- |
| `KAFKA_HEAP_OPTS`  | `-Xms512m -Xmx512m`      | JVM heap of the broker                  |
| `KAFKA_CLUSTER_ID` | `5L6g3nShT-eMCtK--X86sw` | Cluster id used to format empty storage |

Data is stored in the `/var/lib/kafka/data` volume. The broker runs as user `kafka` (uid 1000).

Passing a command runs it instead of the broker, for example:

```bash
docker run --rm gguridi/kafka kafka-topics.sh --version
```

## Build

```bash
docker build -t kafka-test --build-arg KAFKA_VERSION=4.4.0 .
```

`SCALA_VERSION` (default `2.13`) is also accepted as a build argument.

## Run tests

Prerequisites: Node 24 and Docker.

```bash
npm ci
KAFKA_VERSION=4.4.0 npm run docker:build
npm run docker:run && npm run docker:wait
npm test
npm run docker:stop
```

## Release

Every push and pull request builds and tests all Kafka versions. Publishing a GitHub release builds the
multi-arch images, pushes them to Docker Hub and GHCR, and syncs this README to Docker Hub. It uses the
`DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` repository secrets.
