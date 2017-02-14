class Query
  constructor: (@emitter, @kind, @name, @status) ->
    if @emitter?.includes(".") || @kind?.includes(".") || @name?.includes(".") || @status?.includes(".")
      throw new Error("'Dot' is not a valid character")

  toRoutingKey: ->
    "#{@_toExpression(@status)}.#{@_toExpression(@emitter)}.#{@_toExpression(@kind)}.#{@_toExpression(@name)}"

  _toExpression: (queryExpression) ->
    if queryExpression == "all"
      "*"
    else
      queryExpression

module.exports = Query
