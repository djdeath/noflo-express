noflo = require 'noflo'
express = require 'express'

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

    @inPorts.in.on 'begingroup', (group) =>
      return unless @outPorts.out.isAttached()
      @outPorts.out.beginGroup group
    @inPorts.in.on 'data', (request) =>
      @request = request
    @inPorts.in.on 'disconnect', () =>
      return unless @request? and @_error?
      request = @request
      delete @request
      request.res.send({ error: @_error.message })
      return unless @outPorts.out.isAttached()
      @outPorts.out.send(request)
    @inPorts.in.on 'endgroup', () =>
      return unless @outPorts.out.isAttached()
      @outPorts.out.endGroup()
    @inPorts.in.on 'disconnect', () =>
      return unless @outPorts.out.isConnected()
      @outPorts.out.disconnect()

exports.getComponent = -> new SendError
