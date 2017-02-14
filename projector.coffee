Query = require "./query"

class Projector
  init: (@logger, @subscriptionRepository) ->

  name: ->
    "<name not defined>"

  defineHandlers: ->

  on: (emitter, kind, name, status, handler) ->
    query = new Query(emitter, kind, name, status)
    @subscriptionRepository.register(query, @, handler)

module.exports = Projector
