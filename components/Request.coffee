noflo = require 'noflo'

class Request extends noflo.Component
  description: ""

  constructor: ->
    @inPorts =
      server: new noflo.Port 'number'
      method: new noflo.Port 'string'
      path: new noflo.Port 'string'
    @outPorts =
      request: new noflo.Port 'object'
      error: new noflo.Port 'object'

    @requestHandler = (req) =>
      unless @outPorts.request.isAttached()
        req.abort()
        return
      @outPorts.request.send(req)
      @outPorts.request.disconnect()

    @verb = 'get'
    @path = '/'

    @inPorts.server.on 'data', (server) =>
      @removeRoute()
      @server = server
      @createRoute()
    @inPorts.path.on 'data', (path) =>
      @removeRoute()
      @path = path
      @createRoute()
    @inPorts.method.on 'data', (verb) =>
      @removeRoute()
      @verb = verb
      @createRoute()

  sendError: (msg) ->
    return unless @outPorts.error.isAttached()
    @outPorts.error.send(new Error(msg))
    @outPorts.error.disconnect()

  createRoute: () ->
    return unless @server and @verb and @path
    unless @server[@verb]
      @sendError("Invalid method #{@verb}")
      return
    @server[@verb](@path, @requestHandler)

  removeRoute: ->
    return unless @server and @verb and @path
    routes = @server.routes[@verb]
    return unless routes
    for route, i in routes
      if route.path == @path and route.method == @verb
        routes.slice(i, -1)

  shutdown: ->
    @removeRoute()

exports.getComponent = -> new Request
