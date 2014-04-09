noflo = require 'noflo'
express = require 'express'

class Server extends noflo.Component
  description: ""

  constructor: ->
    @inPorts =
      listen: new noflo.Port 'number'
      close: new noflo.Port 'number'
    @outPorts =
      server: new noflo.Port 'object'
      error: new noflo.Port 'object'

    @servers = {}

    @inPorts.listen.on 'data', (port) =>
      @createServer(port)
    @inPorts.close.on 'data', (port) =>
      @closeServer(port)

  sendError: (msg) ->
    return unless @outPorts.error.isAttached()
    @outPorts.send(new Error(msg))
    @outPorts.disconnect()

  createServer: (port) ->
    if @servers[port]
      @sendError("Port #{port} already in use")
      return
    server = express()
    server.listen(port)
    @servers[port] = server
    if @outPorts.server.isAttached()
      @outPorts.server.send(server)
      @outPorts.disconnect()

  closeServer: (port) ->
    unless @server[port]
      @sendError("Port #{port} not listened to")
      return
    @servers[port].close()
    delete @servers[port]

  shutdown: ->
    for port, server of @servers
      server.close()
    @servers = {}

exports.getComponent = -> new Server
