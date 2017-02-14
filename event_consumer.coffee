amqp  = require "amqplib"
Event = require "./event"
Q     = require "q"

class EventConsumer
  constructor: (@logger, @configuration, @subscriptionRepository) ->

  connect: ->
    channel = null
    @_createConnectionWithRetry().then((connection) =>
      connection.createChannel()
    ).then((_channel) =>
      channel = _channel
      @_connectQueue(channel)
    ).then((queue) =>
      @_bindQueueToExchange(channel, queue)
      @channel = channel
      @queue   = queue
      @logger.info("Ready to consume messages.")
      @
    ).catch (err) =>
      @logger.warn "Error when creating a connection to the queue"
      throw new Error(err)

  start: ->
    @channel.consume(@queue.queue, (message) =>
      @_handleMessage(message, @)
    , {noAck: false})

  _createConnectionWithRetry: ->
    url = @configuration.rabbitMqUrl()
    amqp.connect(url).catch (err) =>
      @logger.warn "Can't connect to #{url}, try again in 1 second."
      Q.delay(1000).then =>
        @_createConnectionWithRetry()


  _connectQueue: (channel) ->
    exchange     = @configuration.rabbitMq.exchangeName
    queueName    = @configuration.rabbitMq.queueName
    queueDurable = @configuration.rabbitMq.queueDurable
    qos          = @configuration.rabbitMq.prefetchSize
    channel.assertExchange(exchange,
                           "topic",
                           {durable: queueDurable}).then (ok) ->
      channel.prefetch(qos)
      channel.assertQueue(queueName, {exclusive: false})

  _bindQueueToExchange: (channel, queue) ->
    self = @
    exchange    = @configuration.rabbitMq.exchangeName
    routingKeys = @subscriptionRepository.findAll().map (subscription) -> subscription.query.toRoutingKey()
    routingKeys = @_uniqueValues(routingKeys)
    routingKeys.forEach (routingKey) ->
      self.logger.info("Binding queue '#{queue.queue}' to exchange '#{exchange}' with routing key: #{routingKey}")
      channel.bindQueue(queue.queue, exchange, routingKey)
    @_unbindUselessKeys(queue, exchange, routingKeys)


  _handleMessage: (message, self) ->
    event         = new Event(JSON.parse(message.content))
    subscriptions = self.subscriptionRepository.findSubscriptionsFor(event)
    self.logger.info("Executing #{subscriptions.length} handlers for event '#{event.name()}' with id: #{event.id()}.")

    subscriptions.forEach (subscription) ->
      subscription.process(event)
    self.channel.ack(message)

  _unbindUselessKeys: (queue, exchange, routingKeys) ->
    ## TODO

  _uniqueValues: (array) ->
    array.filter (item, position) ->
      array.indexOf(item) == position

module.exports = EventConsumer
