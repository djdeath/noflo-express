noflo = require 'noflo'

class EndRequest extends noflo.Component
  icon: 'sign-out'
  description: "Ends a request"
  constructor: ->
    @inPorts =
      in: new noflo.Port 'object'
    @outPorts =
      out: new noflo.Port 'object'

    @inPorts.in.on 'data', (request) =>
      request.end()
      return unless @outPorts.out.isAttached()
      @outPorts.out.send(request)
    @inPorts.in.on 'disconnect', () =>
      return unless @outPorts.out.isConnected()
      @outPorts.out.disconnect()

exports.getComponent = -> new EndRequest
