define ['score', 'i18n'], (score, i18n) ->
  class ScoreBoard

    constructor: (@gameScene) ->
      @el = $('<div class="scoreboard"></div>')
      @currentEl = $('<span class="current">0</span>')
      @el.append @currentEl
      # Nothing to show before the first game
      if score.bestScore() > 0
        @el.append $('<span class="best"></span>').text(i18n.t('highScore') + score.bestScore())
      # Score is the highest point reached plus bonuses (coins). They are kept apart so
      # climbing doesn't swallow the bonuses
      @height = 0
      @bonus = 0
      return

    update: (camera) ->
      height = Math.floor(-(@gameScene.player.pos.y - @gameScene.height))
      if height > @height
        @height = height
        @render()

    addBonus: (points) ->
      @bonus += points
      @render()

    render: ->
      @currentEl.text @score

    @property 'score',
      get: -> @height + @bonus
      set: (score) ->
        @bonus = score - @height
        @render()

  return ScoreBoard
