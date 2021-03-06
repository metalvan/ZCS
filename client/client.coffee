socket = io.connect(window.location.origin)

socket.on 'connection', ->
  console.log 'connected'

socket.on 'zone', (data) ->
  for actor in data.actors
    a = Actor.getActor actor.id, actor
    a.moveTo actor.x, actor.y



class Actor
  @actors: {}

  @getActor: (id, data) ->
    return Actor.actors[id] if Actor.actors[id]
    if data.type is 'player'
      return Actor.actors[id] = new Player id
    return Actor.actors[id] = new Zombie id

  constructor: (@id) ->
    Actor.actors[@id] = @
    @x = 0
    @y = 0

  moveTo: (x, y) ->
    @sprite.container.css
      top: Math.round y
      left: Math.round x
      zIndex: Math.round y
    if x > @x and y > @y
      direction = 5
    else if x < @x - 3 and y > @y + 3
      direction = 7
    else if x > @x + 3 and y < @y - 3
      direction = 3
    else if x < @x - 3 and y < @y - 3
      direction = 1
    else if x < @x - 1
      direction = 0
    else if x > @x + 1
      direction = 4
    else if y > @y
      direction = 6
    else if y < @y
      direction = 2
    @sprite.direction = direction
    @x = x
    @y = y


class Zombie extends Actor
  constructor: ->
    super
    @sprite = new ZombieSprite
    @sprite.playAnimation 'walk'

class Player extends Actor
  constructor: ->
    super
    @sprite = new HeroSprite
    @sprite.playAnimation 'walk'



class Sprite
  constructor: (@spriteSheet, @width, @height) ->
    @animations = {}

    @container = $('<div></div>').css
      position: 'absolute'
      width: @width
      height: @height
      backgroundImage: "url(#{@spriteSheet})"
    @container.appendTo '#actors'
    @direction = 0


  defineAnimation: (name, speed, start, end, loops) ->
    arr = []
    for i in [start...end]
      arr.push i * @width

    @animations[name] = {
      speed: speed
      loops: loops
      frames: arr
    }

  playAnimation: (name) ->
    clearInterval @interval
    @frame = 0
    @interval = setInterval =>
      @container.css backgroundPosition: "#{-@animations[name].frames[@frame]}px #{-@height*@direction}px"
      @frame++
      if @frame >= @animations[name].frames.length
        if @animations[name].loops
          @frame = 0
        else
          clearInterval @interval
     , @animations[name].speed


class ZombieSprite extends Sprite
  constructor: ->
    super '/sprites/zombie.png', 128, 128
    @defineAnimation 'stand', 300, 0, 3, true
    @defineAnimation 'walk', 140, 4, 11, true
    @defineAnimation 'attack', 140, 12, 21, true
    @defineAnimation 'die', 140, 22, 27, false
    @defineAnimation 'crit', 140, 28, 35, false



class HeroSprite extends Sprite
  constructor: ->
    super '/sprites/skeleton.png', 128, 128
    @defineAnimation 'stand', 300, 0, 4, true
    @defineAnimation 'walk', 140, 5, 12, true
    @defineAnimation 'attack', 100, 13, 20, true
    @defineAnimation 'die', 140, 21, 27, false


class Zone
  constructor: (@sprite) ->
    @canvas = document.createElement 'canvas'
    @canvas.width = 900
    @canvas.height = 900
    @context = @canvas.getContext '2d'
    for x in [-1..100]
      for y in [-1..100]
        xo = Math.round Math.random() * 15
        yo = Math.round Math.random() * 1
        @context.drawImage @sprite, 64 * xo, 32 * yo, 64, 32, x*32, y*32-16*(x%2), 64, 32


  drawTo: (viewCanvas) ->
    viewCanvas.getContext('2d').drawImage(@canvas, 0, 0)


# z = new ZombieSprite
# z.direction = 'downright'
# z.playAnimation 'stand'
# 
# h = new HeroSprite
# h.direction = 'downright'
# h.playAnimation 'stand'
# 
# 
c = $('canvas')[0]
sprite = new Image()
sprite.src = '/sprites/map.png'
sprite.onload = ->
  Z = new Zone sprite
  Z.drawTo c
