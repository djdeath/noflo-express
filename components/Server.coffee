noflo = require 'noflo'
express = require 'express'

class Server extends noflo.Component
  description: "A basic express.js server creation component"

  constructor: ->
    @inPorts =
      listen: new noflo.Port 'number'
      close: new noflo.Port 'number'
    @outPorts =
      app: new noflo.Port 'object'
      server: new noflo.Port 'object'
      error: new noflo.Port 'object'

    @servers = {}

    @inPorts.listen.on 'data', (port) =>
      @createServer(parseInt(port))
    @inPorts.close.on 'data', (port) =>
      @closeServer(parseInt(port))

  sendError: (msg) ->
    @error new Error msg

  createServer: (port) ->
    if @servers[port]
      @sendError("Port #{port} already in use")
      return
    try
      app = express()
      server = app.listen(port)
      @servers[port] =
        app: app
        server: server
      if @outPorts.app.isAttached()
        @outPorts.app.send(app)
        @outPorts.app.disconnect()
      if @outPorts.server.isAttached()
        @outPorts.server.send(server)
        @outPorts.server.disconnect()
    catch e
      @sendError("Cannot listen to port #{port} : #{e.message}")

  closeServer: (port) ->
    unless @servers[port]
      @sendError("Port #{port} not listened to")
      return
    @servers[port].server.close()
    delete @servers[port]

  shutdown: ->
    for port, server of @servers
      server.close()
    @servers = {}

exports.getComponent = -> new Server
