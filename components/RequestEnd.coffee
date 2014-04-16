noflo = require 'noflo'

class RequestEnd extends noflo.Component
  description: ""

  constructor: ->
    @inPorts =
      in: new noflo.Port 'object'
    @outPorts =
      out: new noflo.Port 'object'
      error: new noflo.Port 'object'

    @inPorts.in.on 'data', (request) =>
      request.on 'end', () =>
        @sendRequest(request)

  sendError: (error) ->
    return unless @outPorts.error.isAttached()
    @outPorts.error.send(error)
    @outPorts.error.disconnect()

  sendRequest: (request) ->
    return unless @outPorts.out.isAttached()
    @outPorts.out.send(request)
    @outPorts.out.disconnect()

exports.getComponent = -> new RequestEnd
