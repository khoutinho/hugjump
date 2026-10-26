define ["scene", "score", "i18n"], (Scene, score, i18n) ->
  class GameOverScene extends Scene
    ENTER = 13
    ESCAPE = 27
    SPACE = 32
    # Back to the menu if the player walks away from the stand
    IDLE_SECONDS = 45
    # Ignore keys right after the results show up, so keys still held from playing
    # don't skip the screen
    KEY_DELAY = 0.5

    constructor: (@game, @currentScore, @background) ->
      super @game, "gameOverScene"
      score.recordGame @currentScore
      @trackIdle IDLE_SECONDS
      # Players sign up before playing when high scores are on, so the game is saved right away
      if score.enabled and @game.player?
        @rank = score.addEntry @game.player, @currentScore
      @showResults()

    showResults: ->
      @informationEl = $('<div class="information"></div>')
      @informationEl.append $('<span class="heading"></span>').text(i18n.t('gameOver'))
      yourScoreEl = $('<div></div>').text i18n.t('yourScore')
      yourScoreEl.append $('<span class="yourScore"></span>').text(@currentScore)
      highScoreEl = $('<div></div>').text i18n.t('highScore')
      highScoreEl.append $('<span class="highScore"></span>').text(score.bestScore())
      @informationEl.append yourScoreEl
      @informationEl.append highScoreEl
      if @rank
        rankEl = $('<div></div>').text i18n.t('rank')
        rankEl.append $('<span class="rank"></span>').text("##{@rank}")
        @informationEl.append rankEl
      @addChildElement @informationEl

      @makeButton 'again', 'playAgain', -> @game.startGame()
      @makeButton 'menu', 'backToMenu', -> @game.startMenu()

      # Enter or space plays again, Esc goes to the menu
      @resultsTime = 0
      $(document).on "keydown#{@eventNs}", (e) =>
        return if @resultsTime < KEY_DELAY
        if e.keyCode in [ENTER, SPACE]
          action = => @game.startGame()
        else if e.keyCode is ESCAPE
          action = => @game.startMenu()
        return unless action?
        e.preventDefault()
        # Keep the key from reaching the menu, which starts the game on any key
        e.stopPropagation()
        action()

    makeButton: (textKey, className, handler) ->
      button = $("<div class=\"button #{className}\"><a href=\"#\"></a></div>")
      button.find('a').text i18n.t(textKey)
      # Click only: touch devices also fire click, and handling both would run it twice
      button.on 'click', (e) =>
        e.preventDefault()
        handler.call @
      @addChildElement button
      button

    cleanup: ->
      super()
      # The game's background stays behind the results until leaving this screen
      @background?.remove()

    update: (dt) ->
      super dt
      @resultsTime += dt if @resultsTime?
      # Clouds keep drifting behind the results
      @background?.update()

  return GameOverScene
