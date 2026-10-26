define [], ->
  class Score
    # How many entries the high scores screen shows. All entries are kept, since they hold the
    # players' contact details
    MAX_SHOWN = 100
    # New keys so old test scores saved under "Sveinn" don't show up in the ranking
    SCORES_KEY = 'hugJumpScores'
    BEST_KEY = 'hugJumpBest'
    ENABLED_KEY = 'hugJumpHighscoresEnabled'

    constructor: ->
      @entries = @_load SCORES_KEY, []
      @best = @_load BEST_KEY, 0
      # Whether the game over screen asks for a name to save in the ranking
      @enabled = @_load ENABLED_KEY, false

    topScores: ->
      @entries.slice 0, MAX_SHOWN

    bestScore: ->
      top = if @entries.length > 0 then @entries[0].score else 0
      Math.max @best, top

    # Called after every game, whether or not the player saves a name
    recordGame: (score) ->
      if score > @best
        @best = score
        @_save BEST_KEY, @best

    # Saves a game by a registered player ({name, phone, email}) and returns the player's position.
    # Each email has one entry with its best score, so nobody fills the ranking alone
    addEntry: (player, score) ->
      entry = null
      for e in @entries when e.email is player.email
        entry = e
      if entry?
        entry.score = Math.max entry.score, score
        # Keep the latest name and phone in case they were corrected
        entry.name = player.name
        entry.phone = player.phone
      else
        entry = {name: player.name, phone: player.phone, email: player.email, score: score}
        @entries.push entry
      @entries.sort (a, b) -> b.score - a.score
      @_save SCORES_KEY, @entries
      @entries.indexOf(entry) + 1

    # Downloads every registered player as a spreadsheet and returns how many there were.
    # Semicolons and a BOM so Excel in Portuguese opens it in columns with the accents right
    exportCsv: ->
      players = (e for e in @entries when e.email?)
      return 0 if players.length is 0
      rows = [['Nome', 'Telefone', 'E-mail', 'Pontuação']]
      rows.push [e.name, e.phone, e.email, e.score] for e in players
      csv = (((@_csvCell value) for value in row).join(';') for row in rows).join('\r\n')
      blob = new Blob ['\ufeff' + csv], {type: 'text/csv;charset=utf-8'}
      now = new Date()
      pad = (n) -> ('0' + n).slice(-2)
      stamp = "#{now.getFullYear()}-#{pad(now.getMonth() + 1)}-#{pad(now.getDate())}-#{pad(now.getHours())}#{pad(now.getMinutes())}"
      link = document.createElement 'a'
      link.href = URL.createObjectURL blob
      link.download = "hug-jump-cadastros-#{stamp}.csv"
      document.body.appendChild link
      link.click()
      document.body.removeChild link
      setTimeout (-> URL.revokeObjectURL link.href), 1000
      players.length

    _csvCell: (value) ->
      text = String(value ? '')
      # A leading = + - @ would make spreadsheets run the cell as a formula
      text = "'" + text if /^[=+\-@]/.test text
      '"' + text.replace(/"/g, '""') + '"'

    toggleEnabled: ->
      @enabled = not @enabled
      @_save ENABLED_KEY, @enabled

    _load: (key, fallback) ->
      try
        value = localStorage[key]
        return JSON.parse(value) if value?
      catch e
      fallback

    _save: (key, value) ->
      try
        localStorage[key] = JSON.stringify value
      catch e

  return new Score
