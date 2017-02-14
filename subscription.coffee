class Subscription
  constructor: (@query, @projector, @handler) ->

  process: (message) ->
    @handler(message)

module.exports = Subscription
