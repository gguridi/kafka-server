const { topic, brokers } = require("./settings");
const kafka = require("node-rdkafka");
const message = require("./message.json");

const producer = new kafka.Producer({
  "group.id": "group-" + Math.random() * 100,
  "metadata.broker.list": brokers,
  dr_cb: true,
});

producer.on("ready", () => {
  const text = JSON.stringify(message);
  console.log("Sending message: ", text, " to ", brokers);
  producer.produce(topic, null, Buffer.from(text));
});

producer.on("event.error", (err) => {
  console.error("Error from producer: ", err);
});

module.exports = {
  producer,
};
