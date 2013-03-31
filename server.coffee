express = require('express')
app = express()
app.use(express["static"](__dirname + "/client"))

http = require('http').createServer(app)
http.listen 3000
io = require('socket.io').listen(http)



class TickManager
  constructor: ->
    setInterval @nextTick, 100
    @events = []

  nextTick: =>
    event() for event in @events

  addEvent: (fn) ->
    @events.push fn
tickManager = new TickManager()

##################################################

class Zone
  constructor: ->
    @actors = []

  addActor: (actor) ->
    @actors.push actor
    actor.zone = @

  update: ->
    updateObj =
      actors: []

    for actor in @actors
      updateObj.actors.push actor.toJson()

    for actor in @actors
      actor.connection?.socket.emit 'zone', updateObj


##################################################

class Actor extends Object
  @maxId: 0

  constructor: ->
    @id = ++Actor.maxId
    @x = 0
    @y = 0

  moveTo: (@x, @y) ->
    @zone?.update()

  toJson: ->
    return {
      id: @id
      type: @type
      x: @x
      y: @y
    }

##################################################


class Zombie extends Actor
  type: 'zombie'
  constructor: ->
    super
    @i = 0
    tickManager.addEvent =>
      @i += 0.08
      @moveTo @x+5, 200+100*Math.cos(@i)

##################################################

class Player extends Actor
  type: 'player'
  constructor: (@connection) ->
    super


##################################################

class Connection
  constructor: (@socket) ->
    zone.addActor new Player @

##################################################

zone = new Zone
zone.addActor new Zombie



io.sockets.on 'connection', (socket) -> new Connection socket
