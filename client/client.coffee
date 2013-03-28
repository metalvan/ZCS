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


  facingSelect: (direction) ->
    switch direction
      when 'left'
        @container.css backgroundPosition: "0px 0px"
      when 'downleft'
        @container.css backgroundPosition: "0px 128px"
      when 'down'
        @container.css backgroundPosition: "0px 256px"
      when 'downright'
        @container.css backgroundPosition: "0px 384px"
      when 'right'
        @container.css backgroundPosition: "0px 512px"
      when 'upright'
        @container.css backgroundPosition: "0px 640px" 
      when 'up'
        @container.css backgroundPosition: "0px 768px" 
      when 'upleft'
        @container.css backgroundPosition: "0px 896px" 

	  
  playAnimation: (name) ->
    clearInterval @interval
    @frame = 0
    @interval = setInterval =>
      @container.css backgroundPosition: "#{-@animations[name].frames[@frame]}px 0px"
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



h = new HeroSprite
$('#stand').click -> h.playAnimation 'stand'
$('#walk').click -> h.playAnimation 'walk'
$('#attack').click -> h.playAnimation 'attack'
$('#die').click -> h.playAnimation 'die'
$('#left').click -> h.facingSelect 'left'
$('#upleft').click -> h.facingSelect 'upleft'
$('#up').click -> h.facingSelect 'up'
$('#upright').click -> h.facingSelect 'upright'
$('#right').click -> h.facingSelect 'right'
$('#downright').click -> h.facingSelect 'downright'
$('#down').click -> h.facingSelect 'down'
$('#downleft').click -> h.facingSelect 'downleft'


z = new ZombieSprite
$('#stand').click -> z.playAnimation 'stand'
$('#walk').click -> z.playAnimation 'walk'
$('#attack').click -> z.playAnimation 'attack'
$('#die').click -> z.playAnimation 'die'
$('#crit').click -> z.playAnimation 'crit'
$('#left').click -> z.facingSelect 'left'
$('#upleft').click -> z.facingSelect 'upleft'
$('#up').click -> z.facingSelect 'up'
$('#upright').click -> z.facingSelect 'upright'
$('#right').click -> z.facingSelect 'right'
$('#downright').click -> z.facingSelect 'downright'
$('#down').click -> z.facingSelect 'down'
$('#downleft').click -> z.facingSelect 'downleft'

c = $('canvas')[0]

sprite = new Image()
sprite.src = '/sprites/map.png'
sprite.onload = ->
  Z = new Zone sprite
  Z.drawTo c
