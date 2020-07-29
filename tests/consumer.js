const { topic, brokers } = require("./settings");
const kafka = require("node-rdkafka");

const consumer = new kafka.KafkaConsumer(
  {
    debug: "all",
    "group.id": "test-group",
    "metadata.broker.list": brokers,
    "topic.metadata.refresh.interval.ms": 1000,
  },
  {
    "auto.offset.reset": "beginning",
  },
);
consumer.messages = [];

consumer.on("ready", () => {
  console.log("Connecting to topic: ", topic);
  consumer.subscribe([topic]);
  consumer.consume();
});

consumer.on("error", (err) => {
  console.error("Error from consumer: ", err);
});

consumer.on("data", (data) => {
  const value = data.value.toString();
  console.log("Message received: ", value);
  consumer.messages.push(value);
});

module.exports = {
  consumer,
};
