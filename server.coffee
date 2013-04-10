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
    zone.update()

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
    return actor

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
    # @zone?.update()

  toJson: ->
    return {
      id: @id
      type: @type
      x: @x
      y: @y
    }


  findNearestActor: (type) ->
    nearestActor = null
    nearestActorDistance = Infinity
    for actor in @zone.actors
      continue unless actor.type is type
      actorDistance = Math.pow(@x - actor.x, 2) + Math.pow(@y - actor.y, 2)

      if actorDistance < nearestActorDistance
        nearestActor = actor
        nearestActorDistance = actorDistance
    nearestActor


  directionTo: (actor) ->
    Math.atan2 @y - actor.y, actor.x - @x

##################################################


class Zombie extends Actor
  type: 'zombie'
  constructor: (auto=true) ->
    super
    @speed = Math.random() * 4.5 + .5
    @moveTo 700 * Math.random(), 500 * Math.random()
    if auto
      tickManager.addEvent =>
        player = @findNearestActor 'player'
        return unless player
        dir = @directionTo player
        @moveTo @x + @speed * Math.cos(dir), @y - @speed * Math.sin(dir)

##################################################

class Player extends Actor
  type: 'player'
  constructor: (@connection) ->
    super
    @moveTo 400, 300
    @speed = 5
    tickManager.addEvent =>
      zombie = @findNearestActor 'zombie'
      return unless zombie
      dir = Math.PI + @directionTo zombie
      @moveTo @x + @speed * Math.cos(dir), @y - @speed * Math.sin(dir)
      @x = 700 if @x > 700
      @x = 0 if @x < 0
      @y = 500 if @y > 500
      @y = 0 if @y < 0


##################################################

class Connection
  constructor: (@socket) ->
    zone.addActor new Player @

##################################################

zone = new Zone
zombies = 0

z = zone.addActor new Zombie false
z.x = 0
z.y = 0
z = zone.addActor new Zombie false
z.x = 700
z.y = 0
z = zone.addActor new Zombie false
z.x = 0
z.y = 500
z = zone.addActor new Zombie false
z.x = 700
z.y = 500

setInterval ->
  return if zombies > 17
  zone.addActor new Zombie
  zombies++
, 2000



io.sockets.on 'connection', (socket) -> new Connection socket
