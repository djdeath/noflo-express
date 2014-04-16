noflo = require 'noflo'
express = require 'express'

class SendFile extends noflo.Component
  icon: 'sign-out'
  description: "Sends a file as a response"

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
      return unless @request? and @path?
      request = @request
      delete @request
      request.res.sendfile @path, {}, (err) =>
        if err then @error err else @done request

  done: (request) ->
    return unless @outPorts.out.isAttached()
    @outPorts.out.send(request)
    @outPorts.out.disconnect()

exports.getComponent = -> new SendFile
