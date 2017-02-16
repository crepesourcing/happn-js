class HappnConfiguration
  constructor: (@logger) ->
    @rabbitMq      =
      host:         process.env.RABBITMQ_HOST          || "localhost"
      port:         process.env.RABBITMQ_PORT          || 5672
      user:         process.env.RABBITMQ_USER          || ""
      password:     process.env.RABBITMQ_PASSWORD      || ""
      queueName:    process.env.RABBITMQ_QUEUE_NAME    || "happn-queue"
      queueDurable: process.env.RABBITMQ_QUEUE_DURABLE || true
      exchangeName: process.env.RABBITMQ_EXCHANGE_NAME || "events"
      prefetchSize: 10

  rabbitMqUrl: ->
    "amqp://#{@rabbitMq.user}:#{@rabbitMq.password}@#{@rabbitMq.host}:#{@rabbitMq.port}"

module.exports = HappnConfiguration
