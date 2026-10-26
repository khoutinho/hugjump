define ["scene", "controls", "i18n", "score", "sound"], (Scene, controls, i18n, score, sound) ->
  class MenuScene extends Scene
    R = 82
    SHIFT = 16
    CTRL = 17
    ALT = 18
    F1 = 112
    F12 = 123

    constructor: (@game) ->
      super @game, "menuScene"
      @title = $('<h1 class="title">HUG JUMP</h1>')
      @addChildElement @title
      @play = $('<div class="button play"><a href="#"></a></div>')
      @highScores = $('<div class="button highScores"><a href="#"></a></div>')
      @langToggle = $('<a href="#" class="lang-toggle"></a>')
      # The speaker opens a volume bar next to it, hidden the rest of the time
      @soundToggle = $('<a href="#" class="sound-toggle"></a>')
      @volumePanel = $('<div class="volume-panel"></div>')
      @volumeSlider = $('<input type="range" class="volume-slider" min="0" max="100" step="5">')
      @volumeValue = $('<span class="volume-value"></span>')
      @volumePanel.append @volumeSlider, @volumeValue
      # Hidden from visitors: Shift+R toggles it and it only shows for a moment
      @scoresToggle = $('<div class="scores-toggle notice"></div>')
      @addChildElement @play
      @addChildElement @highScores
      @addChildElement($('<div class="doodle"></div>'))
      @addChildElement @langToggle
      @addChildElement @soundToggle
      @addChildElement @volumePanel
      @addChildElement @scoresToggle
      @langToggle.on('click', @clickLangToggle.bind(@))
      @soundToggle.on('click', @clickSoundToggle.bind(@))
      @volumeSlider.on('input change', @changeVolume.bind(@))
      # Clicking or touching anywhere else closes the volume bar
      $(document).on "mousedown#{@eventNs} touchstart#{@eventNs}", (e) =>
        inside = $(e.target).closest('.volume-panel, .sound-toggle').length > 0
        @volumePanel.removeClass 'open' unless inside
      # Holding the title does the same as Shift+R, for touch screens
      @onHold @title, => @toggleScores()
      @highScores.on('click', @clickHighScoresButton.bind(@))
      @updateTexts()
      controls.on('keydown', @keyDown.bind(@))
      # Click only: touch devices also fire click, which would land on the next screen
      @play.on('click', @clickPlayButton.bind(@))

    clickPlayButton: (e) ->
      e.preventDefault()
      @startPlaying()

    # With high scores on, players sign up before playing
    startPlaying: ->
      if score.enabled then @game.startRegistration() else @game.startGame()

    keyDown: (e) ->
      # Arrow keys on the volume slider move it instead of starting the game
      return if e.target is @volumeSlider[0]
      if e.shiftKey and e.keyCode is R
        @toggleScores()
        return
      # Modifier and function keys (like F11 for full screen) don't start the game, and neither
      # do Shift combinations, used for staff shortcuts (Shift+Y belongs to the high scores screen)
      return if e.keyCode in [SHIFT, CTRL, ALT] or F1 <= e.keyCode <= F12
      return if e.shiftKey or e.ctrlKey or e.altKey or e.metaKey
      @startPlaying()

    clickHighScoresButton: (e) ->
      e.preventDefault()
      @game.startHighScores()

    clickLangToggle: (e) ->
      e.preventDefault()
      i18n.toggle()
      @updateTexts()

    clickSoundToggle: (e) ->
      e.preventDefault()
      @volumePanel.toggleClass 'open'

    changeVolume: ->
      sound.setVolume @volumeSlider.val()
      @updateTexts()

    toggleScores: ->
      score.toggleEnabled()
      @updateTexts()
      @showNotice @scoresToggle

    updateTexts: ->
      @play.find('a').text i18n.t('play')
      @highScores.find('a').text i18n.t('highScores')
      state = if score.enabled then 'on' else 'off'
      @scoresToggle.toggleClass('on', score.enabled).toggleClass('off', not score.enabled)
      @scoresToggle.text i18n.t(state)
      # The flag shows the current language
      @langToggle.attr('class', "lang-toggle #{i18n.lang}")
      @langToggle.attr('title', i18n.t('switchLanguage'))
      muted = sound.volume is 0
      @soundToggle.toggleClass('muted', muted)
      @soundToggle.attr('title', i18n.t('volume'))
      @volumeSlider.val sound.volume
      # Fills the track up to the thumb
      @volumeSlider.css 'background-size', "#{sound.volume}% 100%"
      @volumeValue.text sound.volume
    
    cleanup: ->
      super()
      controls.off('keydown')
      controls.off('touch')

  return MenuScene
