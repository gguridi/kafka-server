const { producer } = require("./producer");
const { consumer } = require("./consumer");

beforeAll(() => {
  return Promise.all([producer.connect(), consumer.connect()]);
});

afterAll(() => {
  return Promise.all([producer.disconnect(), consumer.disconnect()]);
});

const poll = (i) => {
  return new Promise((resolve) => {
    const interval = setInterval(() => {
      if (consumer.messages.length > 0) {
        clearInterval(interval);
        resolve(JSON.parse(consumer.messages[i]));
      }
    }, 1000);
  });
};

it("should receive a message sent to the `test-topic` topic", async () => {
  const received = await poll(0);
  return expect(received.message).toEqual("this is a test message");
}, 30000);
