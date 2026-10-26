define ["scene", "scoreBoard", "score", "i18n"], (Scene, ScoreBoard, score, i18n) ->
  class GameOverScene extends Scene
    NAME_MAX_LENGTH = 10
    ENTER = 13
    ESCAPE = 27

    constructor: (@game, @currentScore) ->
      super @game, "gameOverScene"
      @scoreBoard = new ScoreBoard(@)
      @scoreBoard.score = @currentScore
      @addChildElement(@scoreBoard.el)
      score.recordGame @currentScore

      # With high scores on, ask for a name before showing the results
      if score.enabled
        @showNameEntry()
      else
        @showResults()

    showNameEntry: ->
      @nameEntryEl = $('<div class="information nameEntry"></div>')
      @nameEntryEl.append $('<span class="heading"></span>').text(i18n.t('gameOver'))
      yourScoreEl = $('<div></div>').text i18n.t('yourScore')
      yourScoreEl.append $('<span></span>').text(@currentScore)
      @nameEntryEl.append yourScoreEl
      @nameEntryEl.append $('<div class="label"></div>').text(i18n.t('enterName'))
      @nameInputEl = $('<input type="text" class="nameInput" autocomplete="off" spellcheck="false">')
      @nameInputEl.attr 'maxlength', NAME_MAX_LENGTH
      @nameEntryEl.append @nameInputEl
      @addChildElement @nameEntryEl

      @saveButtonEl = @makeButton 'save', 'saveName', @saveName
      @skipButtonEl = @makeButton 'skip', 'skipName', @showResults

      @nameInputEl.on 'keydown', (e) =>
        if e.keyCode is ENTER
          @saveName()
        else if e.keyCode is ESCAPE
          @showResults()
      # The scene is only added to the page after the constructor, so focus on the next tick
      setTimeout (=> @nameInputEl[0].focus()), 0

    saveName: ->
      # Upper case, as shown while typing
      name = $.trim(@nameInputEl.val()).toUpperCase() or '???'
      @rank = score.addEntry name.slice(0, NAME_MAX_LENGTH), @currentScore
      @showResults()

    showResults: ->
      return if @resultsShown
      @resultsShown = true
      if @nameEntryEl?
        @nameEntryEl.remove()
        @saveButtonEl.remove()
        @skipButtonEl.remove()

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

    makeButton: (textKey, className, handler) ->
      button = $("<div class=\"button #{className}\"><a href=\"#\"></a></div>")
      button.find('a').text i18n.t(textKey)
      # Click only: touch devices also fire click, and handling both would run it twice
      button.on 'click', (e) =>
        e.preventDefault()
        handler.call @
      @addChildElement button
      button

    update: (dt) ->
      super dt

  return GameOverScene
