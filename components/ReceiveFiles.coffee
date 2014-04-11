noflo = require 'noflo'
express = require 'express'

class ReceiveFiles extends noflo.Component
  icon: 'sign-in'
  description: "Received files from a client's request"

  constructor: ->
    @inPorts =
      in: new noflo.Port 'object'
    @outPorts =
      out: new noflo.Port 'object'
      error: new noflo.Port 'object'

    @inPorts.in.on 'data', (request) =>
      if request.files
        @sendFiles(request)
      else
        @sendError("No file number #{@num}")
    @inPorts.in.on 'disconnect', () =>
      @outPorts.out.disconnect() if @outPorts.out.isConnected()

  sendError: (err) ->
    return unless @outPorts.error.isAttached()
    @outPorts.error.send(new Error(err))
    @outPorts.error.disconnect()

  sendFiles: (request) ->
    return unless @outPorts.out.isAttached()
    for name, obj of request.files
      @outPorts.out.send(obj)

exports.getComponent = -> new ReceiveFiles
