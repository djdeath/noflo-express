noflo = require 'noflo'

class Request extends noflo.Component
  description: ""

  constructor: ->
    @inPorts =
      server: new noflo.Port 'number'
      verb: new noflo.Port 'string'
      path: new noflo.Port 'string'
    @outPorts =
      request: new noflo.Port 'object'

    @requestHandler = (req) =>
      @handleRequest(req)

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
    @inPorts.verb.on 'data', (verb) =>
      @removeRoute()
      @verb = verb
      @createRoute()

  updateRoute: () ->
    return unless @server and @verb and @path
    @server[@verb](@path, @requestHandler)

  removeRoute: ->
    return unless @server and @verb and @path
    routes = @server.routes[@verb]
    for route in routes
      if route.path == @path
        route.slice()

  shutdown: ->
    @removeRoute()

exports.getComponent = -> new Server
