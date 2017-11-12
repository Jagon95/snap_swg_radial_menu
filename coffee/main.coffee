iconPath = '../img/icons.svg'

humane.timeout = 800

polarToCartesian = (cx, cy, r, angle) ->
  angle = (-angle - 90) * Math.PI / 180
  x: cx + r * Math.cos angle
  y: cy + r * Math.sin angle

describeArc = (cx, cy, r, startAngle, endAngle, continueLine) ->
  start = polarToCartesian(cx, cy, r, startAngle %= 360)
  end = polarToCartesian(cx, cy, r, endAngle %= 360)
  large = Math.abs(startAngle - endAngle) > 180
  "#{if continueLine then 'L' else 'M'}#{start.x},#{start.y}
  A#{r},#{r},0,#{+large},#{+(startAngle > endAngle)},
  #{end.x},#{end.y}"

describeSector = (cx, cy, r1, r2, startAngle, endAngle) ->
  "#{describeArc cx, cy, r1, startAngle, endAngle}
  #{describeArc cx, cy, r2, endAngle, startAngle, true}Z"

animate = (obj, index, start, end, duration, easing, fn, cb) ->
  if (obj.animation ?= [])[index]
    obj.animation[index].stop()
    start = obj._animate_state
  obj.animation[index] = Snap.animate start, end, (val) ->
    fn val
    obj._animate_state = val
  , duration, easing, ->
    cb?cb()
    obj.animation[index] = null
    obj._animate_state = null

rand = (min, max) -> Math.random() * (max - min) + min
###*
* Creates circle with buttons
* @class
###
class GUI
  constructor: (buttons) ->
    @paper = Snap window.innerWidth, window.innerHeight
    Snap.load iconPath, (icons) =>
        @nav = new RadialNav @paper, buttons, icons
        do @_bindEvents

  ###*
    * @private
  ###
  _bindEvents: ->
    window.addEventListener 'resize', =>
      @paper.attr
        width: window.innerWidth
        height: window.innerHeight
    @paper.node.addEventListener 'mousedown', @nav.show.bind @nav
    @paper.node.addEventListener 'mouseup', @nav.hide.bind @nav




class RadialNav
  constructor: (paper, buttons, icons) ->
    @area = paper
      .svg 0, 0, @size = 500, @size
      .addClass 'radialNav'
    @c = @size / 2
    @or = @size * .25
    @ir = @or * .35
    @angle = 360 / buttons.length
    @animDuration = 300

    @container = do @area.g
    @container.transform "S0"

    @updateButtons buttons, icons

  ###*
  * @private
  ###

  _animateContainer: (start, end, duration, easing) ->
    animate @, 0, start, end, duration, easing, (val) =>
      @container.transform "r#{90 - 90 * val},#{@c},#{@c}s#{val},#{val},#{@c},#{@c}"

  _animateButtons: (start, end, min, max, easing) ->
    anim = (i, el) =>
      animate el, 0, start, end, rand(min, max), easing, (val) =>
        el.transform "S#{val},#{val},#{@c},#{@c}R#{@angle * i},#{@c},#{@c}"
    anim i, el for i, el of @container.children()

  _animateButtonHover: (button, start, end, duration, easing, cb) ->
    animate button, 1, start, end, duration, easing, ((val) =>
      button.select('.radialnav-sector').attr d: describeSector @c, @c, @ir, @or - val * 10, 0, @angle
      button.select('.radialnav-hint').transform "s#{size = 1.1 - val * .1},#{size},#{@c},#{@c}"
    ), cb

  _sector: ->
    @area
      .path describeSector @c, @c, @ir, @or, 0, @angle
      .addClass 'radialnav-sector'

  _icon: (button, icons) ->
    icon = icons
      .select "##{button.icon}"
      .addClass 'radialnav-icon'
    bbox = icon.getBBox()
    icon.transform "T#{@c - bbox.cx + (@ir + @or) / 2},#{@c - bbox.cy}
    R90 R#{-@angle / 2 - 90},#{@c},#{@c}"
#    icon

  _hint: (button) ->
    hint = @area
      .text 0, 0, button.icon
      .addClass 'radialnav-hint hide'
      .attr
        textpath: describeArc @c, @c, @or, @angle, 0
    hint.select('*').attr startOffset: '50%'
    hint

  _button: (button, sector, icon, hint) ->
    @area
      .g sector, icon, hint
      .hover -> el.addClass 'active' for el in @children(),
      -> el.removeClass 'active' for el in @children()
      .hover (@_button_over @), (@_button_out @)
      .data 'cb', button.action
      .mouseup -> @data('cb')?()

  _button_over: (nav) -> ->
    @.select('.radialnav-hint').removeClass 'hide'
    nav._animateButtonHover @, 0, 1, 200, mina.easeout

  _button_out: (nav) -> ->
    nav._animateButtonHover @, 1, 0, 800, mina.elastic, =>
      @.select('.radialnav-hint').addClass 'hide'
  ###*
  * @public
  ###
  updateButtons: (buttons, icons) ->
    do @container.clear
    for btn, i in buttons
      button = @_button btn, @_sector(), @_icon(btn, icons), @_hint btn
      @container.add button

  show: (e) ->
    @area.attr x: e.clientX - @c, y: e.clientY - @c
    @_animateContainer 0, 1, @animDuration * 8, mina.elastic
    @_animateButtons 0, 1, @animDuration * 5, @animDuration * 8, mina.elastic
    document.body.classList.add 'context'

  hide: (e) ->
    @_animateContainer 1, 0, @animDuration, mina.easeinout
    @_animateButtons 1, 0, @animDuration, @animDuration, mina.easeinout
    document.body.classList.remove 'context'


gui = new GUI [
  {
    icon: 'upload'
    action: -> humane.log 'Uploading...'
  },
  {
    icon: 'message'
    action: -> humane.log 'Messaging...'
  },
  {
    icon: 'target'
    action: -> humane.log 'Targeting...'
  },
  {
    icon: 'print'
    action: -> humane.log 'Printing...'
  },
  {
    icon: 'search'
    action: -> humane.log 'Searching...'
  },
  {
    icon: 'like'
    action: -> humane.log 'Like...'
  }
]


#gui.paper
#  .path describeSector 300, 200, 50, 130, 90, 270
#  .attr
#    fill: 'transparent'
#    stroke: '#fff'
#    strokeWidth: 4



#-------------moving dots-----------------
#paper = Snap 800, 400
#
#style =
#  fill: '#387'
#  stroke: '#fff'
#  strokeWidth: 5
#
#path = paper
#  .path ""
#  .attr
#    stroke: '#387'
#    fill: 'transparent'
#    strokeWidth: 3
#
#lastId = 0
#
#updatePath = ->
#  first = pathArray[0]
#  pathString = "M#{first.x},#{first.y}"
#  for node in pathArray.slice(1)
#    pathString += "L#{node.x},#{node.y}"
#  path.attr d:pathString
#
#pathArray = []
#
#paper.click (e) ->
#  if e.target.tagName != 'circle'
#    paper
#      .circle e.layerX, e.layerY, 30
#      .data 'i', lastId++
#      .animate {r: 15}, 300, mina.easeinout
#      .mouseover ->
#        @stop().animate {r: 25}, 1000, mina.elastic
#      .mouseout ->
#        @stop().animate {r: 15}, 300, mina.easeinout
#      .attr style
#      .drag ((dx, dy, x, y) ->
#        @attr
#          cx: x
#          cy: y
#        pathArray[@data 'i'] = {x, y}
#        do updatePath),
#      -> path.stop().animate {opacity: .2}, 200, mina.easeout(),
#      -> path.stop().animate {opacity: 1}, 1000, mina.easeout()
#    pathArray.push
#      x: e.layerX
#      y: e.layerY
#    do updatePath