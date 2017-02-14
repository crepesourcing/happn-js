class Event
  constructor: (message) ->
    @meta = message.meta
    @data = message.data

  userMetadata: ->
    @data.userMetadata

  changes: ->
    @data.changes

  associations: ->
    @data.associations

  timestamp: ->
    @meta.timestamp

  id: ->
    @meta.id

  name: ->
    @meta.name

  status: ->
    @meta.status

  kind: ->
    @meta.kind

  emitter: ->
    @meta.emitter

  hasChange: (changeName) ->
    changeName of @changes()

  changeFor: (changeName) ->
    @changes()?[changeName] || null

  changeAfter: (changeName) ->
    @changeFor(changeName)?[1] || null

  changeBefore: (changeName) ->
    @changeFor(changeName)?[0] || null

  association: (associationName) ->
    @associations()?[associationName] || null

  userMetadataFor: (key) ->
    @userMetadata()?[key] || null

module.exports = Event
