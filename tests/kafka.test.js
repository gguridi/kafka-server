import { randomUUID } from "node:crypto";
import {
  Admin,
  ConfigResourceTypes,
  Consumer,
  MessagesStreamModes,
  Producer,
  stringDeserializers,
  stringSerializers,
} from "@platformatic/kafka";
import { afterAll, describe, expect, it } from "vitest";

const bootstrapBrokers = [process.env.KAFKA_BROKER ?? "localhost:9092"];
const uniqueTopic = (prefix) => `${prefix}-${randomUUID()}`;

const admin = new Admin({ clientId: "kafka-server-tests", bootstrapBrokers });

afterAll(() => admin.close());

describe("admin", () => {
  it("creates a topic with the requested number of partitions", async () => {
    const topic = uniqueTopic("admin");

    await admin.createTopics({ topics: [topic], partitions: 3, replicas: 1 });
    const metadata = await admin.metadata({ topics: [topic] });

    expect(metadata.topics.get(topic).partitionsCount).toBe(3);
  });
});

describe("configuration", () => {
  it("applies KAFKA__* environment variables to the broker configuration", async () => {
    const [broker] = await admin.describeConfigs({
      resources: [
        { resourceType: ConfigResourceTypes.BROKER, resourceName: "1", configurationKeys: ["num.partitions"] },
      ],
    });

    const numPartitions = broker.configs.find((config) => config.name === "num.partitions");
    // Set by `npm run docker:run` through KAFKA__NUM_PARTITIONS; the image default is 1.
    expect(numPartitions.value).toBe("2");
  });
});

describe("producer and consumer", () => {
  it("receives a message sent to a topic through the advertised listener", async () => {
    const topic = uniqueTopic("roundtrip");
    const value = JSON.stringify({ id: randomUUID(), message: "this is a test message" });

    await admin.createTopics({ topics: [topic], partitions: 1, replicas: 1 });

    const producer = new Producer({
      clientId: "kafka-server-tests-producer",
      bootstrapBrokers,
      serializers: stringSerializers,
    });
    const consumer = new Consumer({
      clientId: "kafka-server-tests-consumer",
      groupId: uniqueTopic("group"),
      bootstrapBrokers,
      deserializers: stringDeserializers,
      maxWaitTime: 500,
    });

    try {
      await producer.send({ messages: [{ topic, value }] });

      const stream = await consumer.consume({ topics: [topic], mode: MessagesStreamModes.EARLIEST });
      let received;
      for await (const message of stream) {
        received = message.value;
        break;
      }
      await stream.close();

      expect(received).toBe(value);
    } finally {
      await Promise.all([producer.close(), consumer.close()]);
    }
  });
});
