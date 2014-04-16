noflo = require 'noflo'

class RequestStore extends noflo.Component
  description: 'Store IIPs using their group and outputs them when'
  constructor: ->
    @inPorts =
      push: new noflo.Port 'object'
      pop: new noflo.Port 'bang'
    @outPorts =
      out: new noflo.Port 'object'
      # TODO : add loadgroup/loadiip ports

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
      return unless @iips[group]?
      if @outPorts.out.isAttached()
        while @iips[group].length > 0
          iip = @iips[group].shift()
          @outPorts.out.send iip
      delete @iips[group]
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
