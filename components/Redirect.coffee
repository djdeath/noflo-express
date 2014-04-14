noflo = require 'noflo'

class Redirect extends noflo.Component
  description: "Redirects a client following a request"

  constructor: ->
    @inPorts =
      in: new noflo.Port 'object'
      path: new noflo.Port 'string'
    @outPorts =
      out: new noflo.Port 'object'

    @inPorts.path.on 'data', (path) =>
      @path = path
    @inPorts.in.on 'data', (request) =>
      request.res.redirect(@path)
      return unless @outPorts.out.isAttached()
      @outPorts.out.send(request)
    @inPorts.in.on 'disconnect', () =>
      return unless @outPorts.out.isConnected()
      @outPorts.out.disconnect()

exports.getComponent = -> new Redirect
