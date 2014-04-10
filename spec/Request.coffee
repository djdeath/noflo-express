noflo = require 'noflo'
express = require 'express'
Request = require '../components/Request'

describe 'Request component', ->
  c = null
  app = null
  vmethod = null
  vpath = null
  vapp = null
  vrequest = null
  verror = null
  beforeEach ->
    c = Request.getComponent()
    app  = express()
    vmethod = noflo.internalSocket.createSocket()
    vpath = noflo.internalSocket.createSocket()
    vapp = noflo.internalSocket.createSocket()
    vrequest = noflo.internalSocket.createSocket()
    verror = noflo.internalSocket.createSocket()
    c.inPorts.method.attach vmethod
    c.inPorts.path.attach vpath
    c.inPorts.app.attach vapp
    c.outPorts.request.attach vrequest
    c.outPorts.error.attach verror

  describe 'when instantiated', ->
    it 'should add a route to the app', (done) ->
      vmethod.send 'get'
      vmethod.disconnect()
      vpath.send '/plop.html'
      vpath.disconnect()
      vapp.send app
      vapp.disconnect()
      done()
    it 'should remove a route from the app and add a new one', (done) ->
      vmethod.send 'get'
      vmethod.disconnect()
      vpath.send '/coin.html'
      vpath.disconnect()
      vapp.send app
      vapp.disconnect()
      done()

  describe 'when instantiated', ->
    it 'should not crash with incorrect method', (done) ->
      verror.once 'data', (error) ->
        done()
      vmethod.send 'get'
      vmethod.disconnect()
      vpath.send '/plop.html'
      vpath.disconnect()
      vapp.send app
      vapp.disconnect()
      vmethod.send 'greoieronierh'
      vmethod.disconnect()
