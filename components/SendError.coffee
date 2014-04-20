noflo = require 'noflo'

class SendError extends noflo.Component
  icon: 'warning'
  description: 'Sends an error object as response'

  constructor: ->
    @inPorts =
      in: new noflo.Port 'object'
      error: new noflo.Port 'object'
    @outPorts =
      out: new noflo.Port 'object'

    @inPorts.error.on 'data', (error) =>
      @_error = error
      @sendError()

    @inPorts.in.on 'begingroup', (group) =>
      return unless @outPorts.out.isAttached()
      @outPorts.out.beginGroup group
    @inPorts.in.on 'data', (request) =>
      @request = request
      @sendError()
    @inPorts.in.on 'endgroup', () =>
      return unless @outPorts.out.isAttached()
      @outPorts.out.endGroup()
    @inPorts.in.on 'disconnect', () =>
      return unless @outPorts.out.isConnected()
      @outPorts.out.disconnect()

  sendError: () ->
    return unless @request? and @_error?
    @request.res.send({ error: @_error.message })
    @outPorts.out.send(@request) if @outPorts.out.isAttached()
    @request = null
    @_error = null

exports.getComponent = -> new SendError
