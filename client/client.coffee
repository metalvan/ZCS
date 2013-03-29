socket = io.connect(window.location.origin)



class Zombie
  constructor: ->



class Sprite
  constructor: (@spriteSheet, @width, @height) ->
    @animations = {}

    @container = $('<div></div>').css
      width: @width
      height: @height
      backgroundImage: "url(#{@spriteSheet})"
    @container.appendTo 'body'


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
      @container.css backgroundPosition: "#{-@animations[name].frames[@frame]}px #{@evaluateFacing(@direction)}px"
      @frame++
      if @frame >= @animations[name].frames.length
        if @animations[name].loops
          @frame = 0
        else
          clearInterval @interval
     , @animations[name].speed

  evaluateFacing: (direction) ->
    switch direction
      when 'left'
        return 0
      when 'downleft'
        return 128
      when 'down'
        return 256
      when 'downright'
        return 384
      when 'right'
        return 512
      when 'upright'
        return 640
      when 'up'
        return 768
      when 'upleft'
        return 896


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


z = new ZombieSprite
z.direction = 'downright'
z.playAnimation 'stand'
$('#stand').click -> z.playAnimation 'stand'
$('#walk').click -> z.playAnimation 'walk'
$('#attack').click -> z.playAnimation 'attack'
$('#die').click -> z.playAnimation 'die'
$('#crit').click -> z.playAnimation 'crit'
$('#left').click -> z.direction = 'left'
$('#upleft').click -> z.direction = 'upleft'
$('#up').click -> z.direction = 'up'
$('#upright').click -> z.direction = 'upright'
$('#right').click -> z.direction = 'right'
$('#downright').click -> z.direction = 'downright'
$('#down').click -> z.direction = 'down'
$('#downleft').click -> z.direction = 'downleft'


c = $('canvas')[0]

sprite = new Image()
sprite.src = '/sprites/map.png'
sprite.onload = ->
  Z = new Zone sprite
  Z.drawTo c