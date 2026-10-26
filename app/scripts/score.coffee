define [], ->
  class Score
    MAX_ENTRIES = 100
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
      @entries.slice 0, MAX_ENTRIES

    bestScore: ->
      top = if @entries.length > 0 then @entries[0].score else 0
      Math.max @best, top

    # Called after every game, whether or not the player saves a name
    recordGame: (score) ->
      if score > @best
        @best = score
        @_save BEST_KEY, @best

    # Adds a named score to the ranking and returns its position (0 if it didn't make the top)
    addEntry: (name, score) ->
      entry = {name: name, score: score}
      @entries.push entry
      @entries.sort (a, b) -> b.score - a.score
      @entries.splice MAX_ENTRIES
      @_save SCORES_KEY, @entries
      @entries.indexOf(entry) + 1

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
