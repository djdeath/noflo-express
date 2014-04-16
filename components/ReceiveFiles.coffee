noflo = require 'noflo'
express = require 'express'
uuid = require 'node-uuid'

class ReceiveFiles extends noflo.Component
  icon: 'files-o'
  description: "Received files from a client's request"
  constructor: ->
    @inPorts =
      in: new noflo.Port 'object'
    @outPorts =
      file: new noflo.Port 'object'
      error: new noflo.Port 'object'

    @inPorts.in.on 'begingroup', (group) =>
      return unless @outPorts.out.isAttached()
      @outPorts.out.beginGroup group
    @inPorts.in.on 'data', (request) =>
      if request.files
        @sendFiles(request)
      else
        @sendError("No files attached")
    @inPorts.in.on 'disconnect', () =>
      @outPorts.file.disconnect() if @outPorts.file.isConnected()
    @inPorts.in.on 'endgroup', () =>
      return unless @outPorts.out.isAttached()
      @outPorts.out.endGroup()
    @inPorts.in.on 'disconnect', () =>
      return unless @outPorts.out.isConnected()
      @outPorts.out.disconnect()

  sendError: (msg) ->
    @error new Error msg

  sendFiles: (request) ->
    return unless @outPorts.file.isAttached()
    for name, obj of request.files
      @outPorts.file.beginGroup uuid()
      @outPorts.file.send obj
      @outPorts.file.endGroup()

exports.getComponent = -> new ReceiveFiles
