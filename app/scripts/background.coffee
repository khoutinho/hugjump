define [], ->
  class Background
    # Height (same unit as the score) at which the forest has slid fully off the screen
    FOREST_END = 5000
    FOREST_RATIO = 384 / 344
    # Height at which the first clouds start coming down from the top of the screen
    CLOUD_START = 100

    # Clouds scroll slower than the platforms to give some depth
    CLOUD_PARALLAX = 0.3
    # How far (fraction of the tile width) each cloud tile may shift left or right
    CLOUD_MAX_SHIFT = 0.3
    CLOUD_RATIO = 192 / 344

    constructor: (@container, @gameEl) ->
      # Back to front: sky, clouds, forest
      @sky = $('<div class="bg-layer bg-sky"></div>')
      @clouds = $('<div class="bg-layer bg-clouds"></div>')
      @forest = $('<div class="bg-layer bg-forest"></div>')
      @layers = $([@sky[0], @clouds[0], @forest[0]])
      @container.prepend @layers
      @cloudTiles = {}
      @cloudShifts = {}

    update: (camera) ->
      height = Math.max(0, -camera.position)
      viewHeight = @container.height()
      # The forest is as wide as the screen and taller than it. It starts with its bottom on the
      # ground and slides down as the player climbs, revealing its top until it is gone
      forestHeight = @container.width() * FOREST_RATIO
      @forest.css
        top: (viewHeight - forestHeight) + 'px'
        height: forestHeight + 'px'
      @slide @forest, height / FOREST_END * forestHeight, forestHeight
      @updateClouds Math.max(0, height - CLOUD_START) * CLOUD_PARALLAX, viewHeight

    slide: (layer, offset, layerHeight) ->
      if offset > layerHeight
        layer.hide()
      else
        layer.show()
        layer.css 'transform', "translate3d(0, #{offset}px, 0)"

    updateClouds: (scroll, viewHeight) ->
      tileWidth = @gameEl.width()
      tileHeight = tileWidth * CLOUD_RATIO

      # Tile k starts k tiles above the top of the screen, so no clouds show before CLOUD_START
      first = Math.max(0, Math.floor((scroll - viewHeight) / tileHeight))
      last = Math.ceil(scroll / tileHeight) - 1

      for k, tile of @cloudTiles
        if k < first or k > last
          tile.remove()
          delete @cloudTiles[k]

      return if last < first
      for k in [first..last]
        # Each new tile gets its own random sideways shift
        @cloudShifts[k] ?= (Math.random() * 2 - 1) * CLOUD_MAX_SHIFT * tileWidth
        tile = @cloudTiles[k]
        if not tile?
          tile = $('<div class="bg-cloud-tile"></div>')
          @clouds.append tile
          @cloudTiles[k] = tile
        tile.css
          height: tileHeight + 'px'
          'background-size': "#{tileWidth}px #{tileHeight}px"
          'background-position': "calc(50% + #{@cloudShifts[k]}px) 0"
          transform: "translate3d(0, #{scroll - (k + 1) * tileHeight}px, 0)"

    remove: ->
      @layers.remove()

  return Background
