noflo = require 'noflo'
uuid = require 'node-uuid'

class Request extends noflo.Component
  description: ""

  constructor: ->
    @inPorts =
      app: new noflo.Port 'number'
      method: new noflo.Port 'string'
      path: new noflo.Port 'string'
    @outPorts =
      request: new noflo.Port 'object'
      error: new noflo.Port 'object'

    @requestHandler = (req) =>
      unless @outPorts.request.isAttached()
        req.abort()
        return
      @outPorts.request.beginGroup uuid()
      @outPorts.request.send req
      @outPorts.request.endGroup()
      @outPorts.request.disconnect()

    @verb = 'get'
    @path = '/'

    @inPorts.app.on 'data', (app) =>
      @removeRoute()
      @app = app
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
    @error new Error msg

  createRoute: () ->
    return unless @app and @verb and @path
    unless @app[@verb]
      @sendError("Invalid method #{@verb}")
      return
    @app[@verb](@path, @requestHandler)

  removeRoute: ->
    return unless @app and @verb and @path
    return unless @app.routes
    routes = @app.routes[@verb]
    return unless routes
    for route, i in routes
      if route.path == @path and route.method == @verb
        routes.slice(i, -1)

  shutdown: ->
    @removeRoute()

exports.getComponent = -> new Request
