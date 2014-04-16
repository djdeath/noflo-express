noflo = require 'noflo'
express = require 'express'

class ReceiveFiles extends noflo.Component
  icon: 'files-o'
  description: "Received files from a client's request"
  constructor: ->
    @inPorts =
      in: new noflo.Port 'object'
    @outPorts =
      file: new noflo.Port 'object'
      error: new noflo.Port 'object'

    @inPorts.in.on 'data', (request) =>
      if request.files
        @sendFiles(request)
      else
        @sendError("No files attached")
    @inPorts.in.on 'disconnect', () =>
      @outPorts.file.disconnect() if @outPorts.file.isConnected()

  sendError: (msg) ->
    @error new Error msg

  sendFiles: (request) ->
    return unless @outPorts.file.isAttached()
    for name, obj of request.files
      @outPorts.file.send(obj)

exports.getComponent = -> new ReceiveFiles
