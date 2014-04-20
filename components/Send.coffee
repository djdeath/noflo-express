noflo = require 'noflo'

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
      @sendData()

    @inPorts.in.on 'begingroup', (group) =>
      return unless @outPorts.out.isAttached()
      @outPorts.out.beginGroup group
    @inPorts.in.on 'data', (request) =>
      @request = request
      @sendData()
    @inPorts.in.on 'endgroup', () =>
      return unless @outPorts.out.isAttached()
      @outPorts.out.endGroup()
    @inPorts.in.on 'disconnect', () =>
      return unless @outPorts.out.isConnected()
      @outPorts.out.disconnect()

  sendData: () ->
    return unless @request? and @data?
    @request.res.send(@data)
    @outPorts.out.send(@request) if @outPorts.out.isAttached()
    @request = null
    @data = null

exports.getComponent = -> new Send
