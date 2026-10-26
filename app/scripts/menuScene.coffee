define ["scene", "controls", "i18n", "score"], (Scene, controls, i18n, score) ->
  class MenuScene extends Scene
    constructor: (@game) ->
      super @game, "menuScene"
      @addChildElement($('<h1 class="title">HUG JUMP</h1>'))
      @play = $('<div class="button play"><a href="#"></a></div>')
      @highScores = $('<div class="button highScores"><a href="#"></a></div>')
      @langToggle = $('<a href="#" class="lang-toggle"></a>')
      @scoresToggle = $('<a href="#" class="scores-toggle"></a>')
      @addChildElement @play
      @addChildElement @highScores
      @addChildElement($('<div class="doodle"></div>'))
      @addChildElement @langToggle
      @addChildElement @scoresToggle
      @langToggle.on('click', @clickLangToggle.bind(@))
      @scoresToggle.on('click', @clickScoresToggle.bind(@))
      @highScores.on('click', @clickHighScoresButton.bind(@))
      @updateTexts()
      controls.on('keydown', @clickPlayButton.bind(@))
      @play.on('touchstart', @clickPlayButton.bind(@))
           .on('click', @clickPlayButton.bind(@))

    clickPlayButton: (e) ->
      @game.startGame()

    clickHighScoresButton: (e) ->
      e.preventDefault()
      @game.startHighScores()

    clickLangToggle: (e) ->
      e.preventDefault()
      i18n.toggle()
      @updateTexts()

    clickScoresToggle: (e) ->
      e.preventDefault()
      score.toggleEnabled()
      @updateTexts()

    updateTexts: ->
      @play.find('a').text i18n.t('play')
      @highScores.find('a').text i18n.t('highScores')
      state = if score.enabled then 'on' else 'off'
      @scoresToggle.attr('class', "scores-toggle #{state}")
      @scoresToggle.text i18n.t(state)
      @scoresToggle.attr('title', i18n.t('scoresToggleHint'))
      # The flag shows the current language
      @langToggle.attr('class', "lang-toggle #{i18n.lang}")
      @langToggle.attr('title', i18n.t('switchLanguage'))
    
    cleanup: ->
      super()
      controls.off('keydown')
      controls.off('touch')

  return MenuScene
