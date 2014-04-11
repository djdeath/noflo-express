noflo = require 'noflo'

class Redirect extends noflo.Component
  description: "Redirects a client following a request"

  constructor: ->
    @inPorts =
      in: new noflo.Port 'object'
      path: new noflo.Port 'string'

    @inPorts.path.on 'data', (path) =>
      @path = path
    @inPorts.in.on 'data', (request) =>
      request.res.redirect(@path)

exports.getComponent = -> new Redirect
