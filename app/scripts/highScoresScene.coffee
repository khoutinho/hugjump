define ["scene", "score", "i18n"], (Scene, score, i18n) ->
  class HighScoresScene extends Scene
    constructor: (@game) ->
      super @game, "highScoresScene"
      @addChildElement $('<h2 class="heading"></h2>').text(i18n.t('highScores'))

      list = $('<ol class="scoreList"></ol>')
      entries = score.topScores()
      if entries.length is 0
        list.append $('<li class="empty"></li>').text(i18n.t('noScores'))
      for entry, i in entries
        row = $('<li></li>')
        row.append $('<span class="position"></span>').text("#{i + 1}.")
        row.append $('<span class="name"></span>').text(entry.name)
        row.append $('<span class="points"></span>').text(entry.score)
        list.append row
      @addChildElement list

      back = $('<div class="button back"><a href="#"></a></div>')
      back.find('a').text i18n.t('back')
      back.on 'click', (e) =>
        e.preventDefault()
        @game.startMenu()
      @addChildElement back

  return HighScoresScene
