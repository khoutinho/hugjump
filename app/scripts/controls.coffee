define [], ->
  class Controls
    KEYS: {
      32: 'space',
      37: 'left',
      39: 'right',
    }

    FULL_ANGLE = 20
    asEvented.call(Controls.prototype)

    constructor: ->
      @keys = {}
      @tilt = 0
      # Fingers on the screen, oldest first, with side -1 on the left half and 1 on the right
      @touches = []
      @clickObservers = []
      @inputVector =
        x: 0
        y: 0
      $(window)
        .on('keydown', @onKeyDown.bind(@))
        .on('keyup', @onKeyUp.bind(@))
        .on('deviceorientation', @onOrientation.bind(@))
        .on('touchstart', @onTouch.bind(@))
        .on('touchstart touchmove', @onTouchMove.bind(@))
        .on('touchend touchcancel', @onTouchEnd.bind(@))
        .on('click', @onTouch.bind(@))

    onKeyDown: (e) ->
      if e.keyCode of @KEYS
        @keys[@KEYS[e.keyCode]] = true
      this.trigger('keydown', e)

    onKeyUp: (e) ->
      if e.keyCode of @KEYS
        @keys[@KEYS[e.keyCode]] = false
      this.trigger('keyup', e)

    update: (dt) ->
      if @keys.right
        @inputVector.x = 1
      else if @keys.left
        @inputVector.x = -1
      else
        @inputVector.x = 0

      # Holding a side of the screen comes next, the latest finger wins
      if @inputVector.x == 0
        @inputVector.x = @touchDirection()

      if @inputVector.x == 0
        @inputVector.x = @tilt

    touchDirection: ->
      if @touches.length then @touches[@touches.length - 1].side else 0

    onTouch: (e) ->
      this.trigger('touch', e)

    onTouchMove: (e) ->
      for touch in e.changedTouches
        side = if touch.clientX < window.innerWidth / 2 then -1 else 1
        existing = (t for t in @touches when t.id is touch.identifier)[0]
        if existing
          existing.side = side
        else
          @touches.push id: touch.identifier, side: side

    onTouchEnd: (e) ->
      ended = (touch.identifier for touch in e.changedTouches)
      @touches = (t for t in @touches when t.id not in ended)

    onOrientation: (e) ->
      degree = e.gamma
      if window.orientation
        direction = window.orientation / 90
        degree = direction * e.beta
      speed = degree / FULL_ANGLE
      if speed > 1
        speed = 1
      else if speed < -1
        speed = -1
      else if Math.abs(speed) < 0.3
        speed = 0
      @tilt = speed

  return new Controls
