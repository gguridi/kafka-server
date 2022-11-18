# Kafka server

[![Build Status](https://travis-ci.org/gguridi/kafka-server.svg?branch=master)](https://travis-ci.org/gguridi/kafka-server)
![CI](https://github.com/gguridi/kafka-server/workflows/CI/badge.svg?branch=master)

This repository contains the code to generate testing docker images with Kafka to
be used in testing/development environment for easily check integrations.

These docker images are not intended to be used in production environments or
scenarios where you need more control over the instance settings. This alpine-based
images are intended to be as small as possible but they haven't been tuned in
terms of performance.

## Build

To build the image we need to pass two arguments:

- `SCALA_VERSION` is used to specify the scala version to use.
- `KAFKA_VERSION` is used to specify the kafka version to use.

If no arguments are passed, the latest scala and kafka versions will be used to
build the latest image.

Using these arguments we can generate as many images as we need without having
to rewrite the helper scripts.

```bash
docker build -t {name:tag} --build-arg SCALA_VERSION=2.11 --build-arg KAFKA_VERSION=1.1.0 .
```

See `hooks/pre_build` for further information about how the tags are automatically
generated in the [docker repository](https://hub.docker.com/r/gguridi/kafka/tags/).

## Usage

You can build your own image or use one of the images available at
[docker repository](https://hub.docker.com/r/gguridi/kafka/tags/).

To run a basic instance that will accept connections as `localhost`:

```bash
docker run -d -p 9092:9092 gguridi/kafka:latest
```

You can also specify any of the prebuilt images the automatic builds make available for you:

```bash
docker run -d -p 9092:9092 gguridi/kafka:2.11-2.0.0
```

Where the first part of the tag specifies the scala version, and the second one
the kafka version. Check the [tag list](https://hub.docker.com/r/gguridi/kafka/tags/)
to see which versions are available.

## Configuration

The image is fully configurable through environment variables. We can override
any default property of kafka/zookeeper using them.

The format accepted is the following:

- KAFKA\_\_PROPERTY_NAME=value for server.properties (kafka) configuration.
- ZOOKEEPER\_\_PROPERTY_NAME=value for zookeeper.properties (zookeeper) configuration.

The "\_" of the property name will be replaced by dots, so as examples:

1. This will set the property `advertised.host.name` of kafka to `my-docker-image`.

```bash
-e KAFKA__ADVERTISED_HOST_NAME=my-docker-image
```

Note: From kafka 3.x this property has changed to `advertised.listeners`.

```bash
KAFKA__ADVERTISED_LISTENERS=PLAINTEXT://my-docker-image
```

2. This will override the `listener` property to use several ports.

```bash
-e KAFKA__LISTENERS=PLAINTEXT://0.0.0.0:9092,SSL://0.0.0.0:9093
```

2. This would override the `log.dir` property to use the folder `/var/kafka/log`.

```bash
-e KAFKA__LOG_DIR=/var/kafka/log
```
