HappnConfiguration     = require "./happn_configuration"
EventConsumer          = require "./event_consumer"
SubscriptionRepository = require "./subscription_repository"

class Happn
  constructor: (logger) ->
    @configuration          = new HappnConfiguration(logger)
    @logger                 = @configuration.logger
    @subscriptionRepository = new SubscriptionRepository(@logger)

  init: (projectors) ->
    @logger.info("#{projectors.length} projectors are going to be registered...")
    self = @
    projectors.forEach (projector) ->
      self._register(self, projector)
    @eventConsumer = new EventConsumer(@logger, @configuration, @subscriptionRepository)

  start: ->
    @eventConsumer.connect().then (consumer) ->
      consumer.start()

  _register: (happn, projector) ->
    projector.init(happn.logger, happn.subscriptionRepository)
    projector.defineHandlers()
    @logger.info("Projector '#{projector.name()}' registered")

module.exports = Happn
