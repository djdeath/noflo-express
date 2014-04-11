noflo = require 'noflo'

class Next extends noflo.Component
  description: "Passes a request to the next route handler"

  constructor: ->
    @inPorts =
      in: new noflo.Port 'object'

    @inPorts.in.on 'data', (request) =>
      request.next()

exports.getComponent = -> new Next
