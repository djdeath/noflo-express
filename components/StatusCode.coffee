noflo = require 'noflo'

class StatusCode extends noflo.Component
  icon: 'warning'
  description: 'Sets the status code on a response'
  constructor: ->
    @inPorts =
      in: new noflo.Port 'object'
      code: new noflo.Port 'number'
    @outPorts =
      out: new noflo.Port 'object'

    @code = 200
    @inPorts.code.on 'data', (code) =>
      @code = code

    @inPorts.in.on 'begingroup', (group) =>
      return unless @outPorts.out.isAttached()
      @outPorts.out.beginGroup group
    @inPorts.in.on 'data', (request) =>
      request.res.status @code
      return unless @outPorts.out.isAttached()
      @outPorts.out.send request
    @inPorts.in.on 'endgroup', () =>
      return unless @outPorts.out.isAttached()
      @outPorts.out.endGroup()
    @inPorts.in.on 'disconnect', () =>
      return unless @outPorts.out.isConnected()
      @outPorts.out.disconnect()

exports.getComponent = -> new StatusCode
