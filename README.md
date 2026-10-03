# Library for happn

Happn connects a RabbitMQ exchange and listens for CREPE events (possibly generated using `flu-rails`) sequentially.
Happn helps developers to create _"Projectors"_ that define how to match and consume events.

This gem connects a single RabbitMQ queue and bind it automatically to its exchange. These bindings are defined by developers through "matchers" when loading projectors.

## Requirements

* Node.js >= 24
* Tested with RabbitMQ 3.5.8

## Installation

Using npm:
```shell
$ npm install --save @crepesourcing/happn
```

## About queues

* `Happn` consumes a single queue through the RabbitMQ's [Topic Exchange Model](https://www.rabbitmq.com/tutorials/amqp-concepts.html#exchange-topic).
* If the queue does not exist when `happn` starts, it is created automatically.
* When connecting a queue, please be careful that each connection parameter must match the existing queue's parameters. For instance, the value of `x-queue-mode` must match to avoid a `PRECONDITION FAILED` error.
* All bindings between queues and their exchange are reset when starting `Happn`. Based on all the projectors that have been registered, `Happn` detects which events must be consumed and binds its queue to the exchange depending on these event matchers.

## About projectors

A projector:
* defines one or multiple matchers to detect which events must be consumed. Matchers can be declared using 4 event properties
  * `emitter`: _e.g._ `"Facebook"` or `"MyInternalApi"` (`"all"` means "all emitters")
  * `kind`: _e.g._ `"entity_change"` or `"kind"` (`"all"` means "all kinds")
  * `name`: _e.g._ `"create country"` or `"request to destroy bunnies"` (`"all"` means "all names")
  * `status`: _e.g._ `"new"` or `"replayed"` (`"all"` means "all statuses")
* defines how to consume these events.

When a projector throws an Exception, `Happn` stops.

## Usage

### Start Up

```js
Happn = require("@crepesourcing/happn").Happn
var happn = new Happn(logger)
var projectors = [...]; // the projector you've created
happn.init(projectors);
happn.start().then(function() {
  logger.info("Happn started.");
});
```

### Define a Projector

A projector is an object that defines how to consume one or multiple types of events. This class must:

* "extend" module `Projector`.
* use its `on` method to declare _which_ events to match and _how_ to consume them. This must be done in a `defineHandlers` method.

```js
const { Projector } = require("@crepesourcing/happn");

class LoggerProjector extends Projector {
  name() {
    return "LoggerProjector";
  }

  defineHandlers() {
    this.on("MyApplication", "all", "create country", "new", (event) => {
      console.log("A country has been created and generated an event with id " + event.id());
    });

    this.on("Api", "request", "all", "new", (event) => {
      console.log("This is a new request to the controller " + event.data["controller_name"]);
    });
  }
}
```

The same projector written in Coffeescript:
```coffeescript
Projector = require("@crepesourcing/happn").Projector

class LoggerProjector extends Projector
  name: ->
    "LoggerProjector"

  defineHandlers: ->
    @on "MyApplication", "all", "create country", "new", (event) =>
      console.log("A country has been created and generated an event with id #{event.id()}")

    @on "Api", "request", "all", "new", (event) =>
      console.log("This is a new request to the controller #{event.data["controller_name"]}")
```

## Overall configuration options

All options have a default value. However, all options can be overridden by setting up environment variables.

| Option | Default Value | Type | Required? | Description  | Example |
| ---- | ----- | ------ | ----- | ------ | ----- |
| `RABBITMQ_SCHEME` | `"amqp"` | String | Required | Scheme to contact RabbitMQ's host. | `"amqps"` |
| `RABBITMQ_HOST` | `"localhost"` | String | Required | RabbitMQ exchange's host. | `"192.168.42.42"` |
| `RABBITMQ_PORT` | `5672` | Integer | Required | RabbitMQ exchange's port. | `1234` |
| `RABBITMQ_USER` | `""` | String | Required | RabbitMQ exchange's username. | `"root"` |
| `RABBITMQ_PASSWORD` | `""` | String | Required | RabbitMQ exchange's password. | `"pouet"` |
| `RABBITMQ_EXCHANGE_NAME` | `"events"` | String | Required | RabbitMQ exchange's name. | `"myproject"` |
| `RABBITMQ_QUEUE_NAME` | `"happn-queue"` | String | Required | The RabbitMQ queue to create, bind and consume. If the queue does not exist, it will be created at startup. | `"my-queue"` |
| `RABBITMQ_QUEUE_DURABLE` | `true` | Boolean | Optional | Make the RabbitMQ's exchange durable or not. From RabbitMQ's [documentation](https://www.rabbitmq.com/tutorials/amqp-concepts.html#exchanges): _"Durable exchanges survive broker restart whereas transient exchanges do not (they have to be redeclared when broker comes back online)."_ | `false` |

