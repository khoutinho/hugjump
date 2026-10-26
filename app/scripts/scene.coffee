define [], ->
  class Scene
    nextId = 1
    # Holding an element this long counts as a long press (used for hidden staff actions)
    HOLD_MS = 3000
    # How long a notice stays on screen
    NOTICE_MS = 2500

    constructor: (@game, @name) ->
      @el = $('<div class="' + @name + '"></div>')
      # The next scene is built before this one is cleaned up, so each needs its own event namespace
      @eventNs = ".scene#{nextId++}"

    update: (dt) ->
      # Called every frame
      if @idleLimit?
        @idleTime += dt
        if @idleTime >= @idleLimit
          @idleLimit = null
          @onIdle()

    # Calls onIdle after `seconds` without any key press, click or touch
    trackIdle: (seconds) ->
      @idleLimit = seconds
      @idleTime = 0
      events = ("#{e}#{@eventNs}" for e in ['keydown', 'mousedown', 'touchstart']).join(' ')
      $(document).on events, => @idleTime = 0

    onIdle: ->
      @game.startMenu()

    # Runs action after el is held down (mouse or touch) for HOLD_MS. A quick tap still works
    # as a normal click; wasHeld tells a click handler to ignore the release after a long press
    onHold: (el, action) ->
      el.addClass 'holdable'
      el.on 'mousedown touchstart', =>
        @cancelHold()
        @heldElement = null
        @holdTimer = setTimeout (=>
          @heldElement = el[0]
          action()
        ), HOLD_MS
      el.on 'mouseup mouseleave touchend touchcancel', => @cancelHold()
      # Android opens a menu on long press
      el.on 'contextmenu', (e) -> e.preventDefault()

    cancelHold: ->
      clearTimeout @holdTimer

    wasHeld: (el) ->
      held = @heldElement is el[0]
      @heldElement = null if held
      held

    # Shows one notice at a time (elements with the "notice" class) for NOTICE_MS
    showNotice: (notice) ->
      @el.find('.notice').removeClass 'visible'
      notice.addClass 'visible'
      clearTimeout @noticeTimer
      @noticeTimer = setTimeout (=> notice.removeClass 'visible'), NOTICE_MS

    cleanup: ->
      # Remove the element, clean up event bindings, etc.
      $(document).off @eventNs
      @cancelHold()
      clearTimeout @noticeTimer
      @el.remove()

    addChildElement: (element) ->
      @el.append(element)

  return Scene
