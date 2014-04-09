noflo = require 'noflo'
express = require 'express'
Request = require '../components/Request'

describe 'Request component', ->
  c = null
  server = null
  vmethod = null
  vpath = null
  vserver = null
  vrequest = null
  verror = null
  beforeEach ->
    c = Request.getComponent()
    server  = express()
    vmethod = noflo.internalSocket.createSocket()
    vpath = noflo.internalSocket.createSocket()
    vserver = noflo.internalSocket.createSocket()
    vrequest = noflo.internalSocket.createSocket()
    verror = noflo.internalSocket.createSocket()
    c.inPorts.method.attach vmethod
    c.inPorts.path.attach vpath
    c.inPorts.server.attach vserver
    c.outPorts.request.attach vrequest
    c.outPorts.error.attach verror

  describe 'when instantiated', ->
    it 'should add a route to the server', (done) ->
      vmethod.send 'get'
      vmethod.disconnect()
      vpath.send '/plop.html'
      vpath.disconnect()
      vserver.send server
      vserver.disconnect()
      done()
    it 'should remove a route from the server and add a new one', (done) ->
      vmethod.send 'get'
      vmethod.disconnect()
      vpath.send '/coin.html'
      vpath.disconnect()
      vserver.send server
      vserver.disconnect()
      done()

  describe 'when instantiated', ->
    it 'should not crash with incorrect method', (done) ->
      verror.once 'data', (error) ->
        done()
      vmethod.send 'get'
      vmethod.disconnect()
      vpath.send '/plop.html'
      vpath.disconnect()
      vserver.send server
      vserver.disconnect()
      vmethod.send 'greoieronierh'
      vmethod.disconnect()
