Subscription = require "./subscription"

class SubscriptionRepository
  constructor: (@logger) ->
    @subscriptions = {}

  register: (query, projector, handler) ->
    subscription = new Subscription(query, projector, handler)
    emitter      = query.emitter
    kind         = query.kind
    name         = query.name
    status       = query.status

    @subscriptions[status]                      ?= {}
    @subscriptions[status][emitter]             ?= {}
    @subscriptions[status][emitter][kind]       ?= {}
    @subscriptions[status][emitter][kind][name] ?= []
    @subscriptions[status][emitter][kind][name].push(subscription)
    @logger.info("Subscribe projector '#{projector.name()}' to query : [#{status}][#{emitter}][#{kind}][#{name}]")

  findSubscriptionsFor: (event) ->
    possibleEventStatuses = ["all", event.status()]
    possibleEventEmitters = ["all", event.emitter()]
    possibleEventNames    = ["all", event.name()]
    possibleEventKinds    = ["all", event.kind()]
    result                = []

    self = @
    possibleEventStatuses.forEach (status) ->
      possibleEventEmitters.forEach (emitter) ->
        possibleEventKinds.forEach (kind) ->
          possibleEventNames.forEach (name) ->
            valid_subscriptions = self.subscriptions?[status]?[emitter]?[kind]?[name]
            if valid_subscriptions?
              valid_subscriptions.forEach (subscription) ->
                result.push(subscription)
    result

  findAll: ->
    @_flatten(@, @subscriptions)

  _flatten: (self, item) ->
    if item instanceof Array
      item
    else
      result = []
      Object.keys(item).forEach (key) ->
        result = result.concat(self._flatten(self, item[key]))
      result

module.exports = SubscriptionRepository
