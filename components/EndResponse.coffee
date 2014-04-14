noflo = require 'noflo'

class EndResponse extends noflo.Component
  icon: 'sign-out'
  description: "Ends a response"
  constructor: ->
    @inPorts =
      in: new noflo.Port 'object'
    @outPorts =
      out: new noflo.Port 'object'

    @inPorts.in.on 'data', (request) =>
      request.res.end()
      return unless @outPorts.out.isAttached()
      @outPorts.out.send(request)
    @inPorts.in.on 'disconnect', () =>
      return unless @outPorts.out.isConnected()
      @outPorts.out.disconnect()

exports.getComponent = -> new EndResponse
