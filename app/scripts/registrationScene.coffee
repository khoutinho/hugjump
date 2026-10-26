define ["scene", "i18n"], (Scene, i18n) ->
  # Asks for name, phone and email before playing when high scores are on. There is no skip:
  # the game only starts with valid details, and Back returns to the menu
  class RegistrationScene extends Scene
    ENTER = 13
    ESCAPE = 27
    IDLE_SECONDS = 45
    NAME_MAX_LENGTH = 10
    # Area code plus number, optionally with the country code
    PHONE_MIN_DIGITS = 10
    PHONE_MAX_DIGITS = 13
    EMAIL_PATTERN = /^[^\s@]+@[^\s@]+\.[^\s@]+$/

    constructor: (@game) ->
      super @game, "registrationScene"
      @trackIdle IDLE_SECONDS

      form = $('<div class="form"></div>')
      form.append $('<span class="heading"></span>').text(i18n.t('signUp'))
      @fields =
        name: @makeField form, 'name', 'text', NAME_MAX_LENGTH
        phone: @makeField form, 'phone', 'tel', 20
        email: @makeField form, 'email', 'email', 60
      @errorEl = $('<div class="formError"></div>')
      form.append @errorEl
      form.append $('<div class="privacy"></div>').text(i18n.t('privacy'))
      @addChildElement form

      @makeButton 'play', 'start', @submit
      @makeButton 'back', 'back', -> @game.startMenu()

      # Enter moves to the next field and plays from the last one; Esc goes back to the menu
      order = [@fields.name, @fields.phone, @fields.email]
      for input, i in order
        do (input, i) =>
          input.on 'keydown', (e) =>
            if e.keyCode is ENTER
              e.preventDefault()
              if i < order.length - 1 then order[i + 1][0].focus() else @submit()
      $(document).on "keydown#{@eventNs}", (e) =>
        return unless e.keyCode is ESCAPE
        # Keep the key from reaching the menu, which starts on any key
        e.stopPropagation()
        @game.startMenu()
      # The scene is only added to the page after the constructor, so focus on the next tick
      setTimeout (=> @fields.name[0].focus()), 0

    makeField: (form, key, type, maxLength) ->
      form.append $('<label class="label"></label>').text(i18n.t(key))
      input = $("<input type=\"#{type}\" class=\"field #{key}\" autocomplete=\"off\" spellcheck=\"false\">")
      input.attr 'maxlength', maxLength
      input.on 'input', -> input.removeClass 'invalid'
      form.append input
      input

    makeButton: (textKey, className, handler) ->
      button = $("<div class=\"button #{className}\"><a href=\"#\"></a></div>")
      button.find('a').text i18n.t(textKey)
      # Click only: touch devices also fire click, and handling both would run it twice
      button.on 'click', (e) =>
        e.preventDefault()
        handler.call @
      @addChildElement button

    submit: ->
      player =
        name: $.trim(@fields.name.val()).toUpperCase().slice(0, NAME_MAX_LENGTH)
        phone: $.trim @fields.phone.val()
        email: $.trim(@fields.email.val()).toLowerCase()
      digits = player.phone.replace(/\D/g, '').length

      if not player.name
        return @showError 'name', 'invalidName'
      if digits < PHONE_MIN_DIGITS or digits > PHONE_MAX_DIGITS or /[^\d\s()+\-.]/.test(player.phone)
        return @showError 'phone', 'invalidPhone'
      if not EMAIL_PATTERN.test player.email
        return @showError 'email', 'invalidEmail'
      @game.startGame player

    showError: (field, messageKey) ->
      @fields[field].addClass('invalid')[0].focus()
      @errorEl.text i18n.t(messageKey)

  return RegistrationScene
