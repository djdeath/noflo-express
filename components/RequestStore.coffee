noflo = require 'noflo'

class RequestStore extends noflo.Component
  description: ''
  constructor: ->
    @inPorts =
      push: new noflo.Port 'object'
      pop: new noflo.Port 'bang'
    @outPorts =
      out: new noflo.Port 'object'

    @iips = {}
    @groups = []
    @groupsReq = []

    # Push
    @inPorts.push.on 'begingroup', (group) =>
      @groups.push group
    @inPorts.push.on 'data', (iip) =>
      group = @groups[@groups.length - 1]
      return unless group?
      @iips[group] = [] unless @iips[group]?
      @iips[group].push ipp
    @inPorts.push.on 'endgroup', () =>
      @groups.pop()

    # Pop
    @inPorts.pop.on 'begingroup', (group) =>
      @groupsReq.push group
      return unless @outPorts.out.isAttached()
      @outPorts.out.beginGroup(group)
    @inPorts.pop.on 'data', () =>
      group = @groupsReq[@groupsReq.length - 1]
      return unless group?
      iip = @iips[group].shift()
      return unless iip?
      return unless @outPorts.out.isAttached()
      @outPorts.out.send iip
    @inPorts.pop.on 'endgroup', () =>
      @groupsReq.pop()
      return unless @outPorts.out.isAttached()
      @outPorts.out.endGroup()
    @inPorts.pop.on 'disconnect', () =>
      return unless @outPorts.out.isConnected()
      @outPorts.out.disconnect()

  shutdown: () ->
    @iips = {}
    @groups = []
    @groupsReq = []

exports.getComponent = -> new RequestStore
