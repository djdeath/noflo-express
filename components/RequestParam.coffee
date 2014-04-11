noflo = require 'noflo'
express = require 'express'

class RequestParam extends noflo.Component
  icon: 'sign-out'
  description: "Sends a file to a client's request"

  constructor: ->
    @inPorts =
      in: new noflo.Port 'object'
      parameter: new noflo.Port 'string'
    @outPorts =
      out: new noflo.Port 'string'

    @inPorts.parameter.on 'data', (param) =>
      @param = param

    @inPorts.in.on 'data', (request) =>
      return unless @param
      return unless @outPorts.out.isAttached()
      @outPorts.out.send(request.params[@param])
    @inPorts.in.on 'disconnect', () =>
      @outPorts.out.disconnect() if @outPorts.out.isConnected()

exports.getComponent = -> new RequestParam
