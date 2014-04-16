noflo = require 'noflo'
express = require 'express'

class Send extends noflo.Component
  icon: 'sign-out'
  description: 'Sends an object (string/number/object) as response'

  constructor: ->
    @inPorts =
      in: new noflo.Port 'object'
      data: new noflo.Port 'all'
    @outPorts =
      out: new noflo.Port 'object'

    @inPorts.data.on 'data', (data) =>
      @data = data

    @inPorts.in.on 'begingroup', (group) =>
      return unless @outPorts.out.isAttached()
      @outPorts.out.beginGroup group
    @inPorts.in.on 'data', (request) =>
      @request = request
    @inPorts.in.on 'disconnect', () =>
      return unless @request? and @data?
      request = @request
      delete @request
      request.res.send(@data)
      return unless @outPorts.out.isAttached()
      @outPorts.out.send(request)
    @inPorts.in.on 'endgroup', () =>
      return unless @outPorts.out.isAttached()
      @outPorts.out.endGroup()
    @inPorts.in.on 'disconnect', () =>
      return unless @outPorts.out.isConnected()
      @outPorts.out.disconnect()

exports.getComponent = -> new Send
