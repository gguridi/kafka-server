const { brokers } = require("./settings");
const kafka = require("node-rdkafka");

const admin = kafka.AdminClient.create({
  "client.id": "kafka-test",
  "metadata.broker.list": brokers,
});

it("should create a `new-topic` topic", async (done) => {
  admin.createTopic(
    { topic: "new-topic", num_partitions: 1, replication_factor: 1 },
    (err) => {
      expect(err).toBeUndefined();
      done();
    },
  );
}, 30000);
