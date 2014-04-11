noflo = require 'noflo'
express = require 'express'

class SendFile extends noflo.Component
  icon: 'sign-out'
  description: "Sends a file to a client's request"

  constructor: ->
    @inPorts =
      in: new noflo.Port 'object'
      path: new noflo.Port 'string'
    @outPorts =
      out: new noflo.Port 'object'
      error: new noflo.Port 'object'

    @inPorts.path.on 'data', (path) =>
      @path = path

    @inPorts.in.on 'data', (request) =>
      @request = request
    @inPorts.in.on 'disconnect', () =>
      return unless @request
      request = @request
      @request.res.sendfile(@path, {}, (err) =>
        if err then @sendError(err) else @done(request))
      delete @request
      delete @path

  sendError: (err) ->
    return unless @outPorts.error.isAttached()
    @outPorts.error.send(err)
    @outPorts.error.disconnect()

  done: (request) ->
    return unless @outPorts.out.isAttached()
    @outPorts.out.send(request)
    @outPorts.out.disconnect()

exports.getComponent = -> new SendFile
