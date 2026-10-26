define ["scene", "score", "i18n"], (Scene, score, i18n) ->
  class HighScoresScene extends Scene
    ENTER = 13
    ESCAPE = 27
    Y = 89
    IDLE_SECONDS = 45

    constructor: (@game) ->
      super @game, "highScoresScene"
      @trackIdle IDLE_SECONDS
      heading = $('<h2 class="heading"></h2>').text(i18n.t('highScores'))
      @addChildElement heading
      # Staff only: Shift+Y or holding the title downloads the registered players as a spreadsheet
      @onHold heading, => @exportScores()
      @exportNotice = $('<div class="notice export-notice"></div>')
      @addChildElement @exportNotice

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

      $(document).on "keydown#{@eventNs}", (e) =>
        if e.shiftKey and e.keyCode is Y
          @exportScores()
          return
        return unless e.keyCode in [ENTER, ESCAPE]
        e.preventDefault()
        # Keep the key from reaching the menu, which starts the game on any key
        e.stopPropagation()
        @game.startMenu()

    exportScores: ->
      count = score.exportCsv()
      @exportNotice.text switch count
        when 0 then i18n.t('nothingToExport')
        when 1 then i18n.t('exportedOne')
        else i18n.t('exported').replace('{n}', count)
      @showNotice @exportNotice

  return HighScoresScene
