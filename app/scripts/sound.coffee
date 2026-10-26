define [], ->
  # Remembers the game volume (0 to 100) and applies it to every sound through Howler
  class Sound
    VOLUME_KEY = 'hugJumpVolume'
    MAX = 100

    constructor: ->
      @volume = MAX
      try
        saved = parseInt localStorage[VOLUME_KEY], 10
        @volume = saved if 0 <= saved <= MAX
      catch e
      @apply()

    setVolume: (volume) ->
      @volume = Math.max 0, Math.min(MAX, Math.round volume)
      @apply()
      try
        localStorage[VOLUME_KEY] = @volume
      catch e

    apply: ->
      Howler.volume @volume / MAX

  return new Sound
