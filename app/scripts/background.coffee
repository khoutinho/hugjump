define [], ->
  class Background
    # Height (same unit as the score) at which the forest has slid fully off the screen
    FOREST_END = 5000
    FOREST_RATIO = 384 / 344
    # Height at which the first clouds start coming down from the top of the screen
    CLOUD_START = 0

    # Clouds scroll slower than the platforms to give some depth
    CLOUD_PARALLAX = 0.3
    # Separate clouds cut from the old cloud tile by tools/clouds.py, in its pixels (width, height).
    # That tile is as wide as the forest image, so drawing it as wide as the screen too gives the
    # clouds the same pixel size as the forest at any resolution
    CLOUD_SIZES = [[175, 69], [97, 53], [82, 47], [84, 40], [43, 24], [51, 21], [40, 17], [32, 16]]
    CLOUD_TILE_WIDTH = 344
    # The sky is split into bands this tall (tile pixels); each band gets its own random clouds
    CLOUD_BAND_HEIGHT = 192
    # Average clouds per band. More means a busier sky
    CLOUDS_PER_BAND = 4
    # Minimum gap between clouds (tile pixels) and placement tries before giving up on one
    CLOUD_GAP = 14
    CLOUD_TRIES = 12
    # Wind speed to the right (tile pixels per second). All clouds drift together, so the gaps
    # between them never change
    CLOUD_DRIFT = 1.5
    # The sky loops sideways: a cloud leaving on the right comes back from the left, starting fully
    # off screen. The loop is the screen plus room for the widest cloud
    CLOUD_WRAP_MARGIN = 175 + CLOUD_GAP
    CLOUD_LOOP = CLOUD_TILE_WIDTH + CLOUD_WRAP_MARGIN

    constructor: (@container) ->
      # Back to front: sky, clouds, forest
      @sky = $('<div class="bg-layer bg-sky"></div>')
      @clouds = $('<div class="bg-layer bg-clouds"></div>')
      @forest = $('<div class="bg-layer bg-forest"></div>')
      @layers = $([@sky[0], @clouds[0], @forest[0]])
      @container.prepend @layers
      # Band index -> clouds in it, each {el, size, x, y (inside the band)}, in tile pixels.
      # x is where the cloud was before the wind moved it, somewhere along the loop
      @cloudBands = {}
      @windStart = Date.now()

    # Without a camera, keeps the last one; the game over screen uses that to keep the wind blowing
    update: (camera = @camera) ->
      @camera = camera
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
      scale = @container.width() / CLOUD_TILE_WIDTH
      bandHeight = CLOUD_BAND_HEIGHT * scale

      # Band k starts k bands above the top of the screen, so no clouds show before CLOUD_START.
      # Clouds stay inside their band, so a band is shown exactly while it is on screen
      first = Math.max(0, Math.floor((scroll - viewHeight) / bandHeight))
      last = Math.ceil(scroll / bandHeight) - 1

      for k, clouds of @cloudBands when k < first or k > last
        cloud.el.remove() for cloud in clouds
        delete @cloudBands[k]

      return if last < first
      wind = @windOffset()
      for k in [first..last]
        @cloudBands[k] ?= @makeCloudBand k
        for cloud in @cloudBands[k]
          [w, h] = cloud.size
          # Where the wind has taken it along the loop, from fully off the left to the right edge.
          # Whole screen pixels, so the pixel art doesn't shimmer while drifting
          loopX = ((cloud.x + wind) % CLOUD_LOOP + CLOUD_LOOP) % CLOUD_LOOP - CLOUD_WRAP_MARGIN
          x = Math.round(loopX * scale)
          y = scroll - (k + 1) * bandHeight + cloud.y * scale
          cloud.el.css
            width: w * scale + 'px'
            height: h * scale + 'px'
            transform: "translate3d(#{x}px, #{y}px, 0)"

    # Scatters clouds along a band's loop, keeping them apart from each other and from the clouds
    # of the band below, also across the point where the loop wraps
    makeCloudBand: (k) ->
      # The loop is wider than the screen, so it gets proportionally more clouds
      expected = CLOUDS_PER_BAND * CLOUD_LOOP / CLOUD_TILE_WIDTH
      count = Math.floor(expected) + (if Math.random() < expected % 1 then 1 else 0)
      # Higher bands are further up, so the band below sits one band lower in this band's terms
      below = for cloud in (@cloudBands[k - 1] ? []) then @cloudBox cloud, CLOUD_BAND_HEIGHT
      clouds = []
      for i in [0...count]
        n = Math.floor(Math.random() * CLOUD_SIZES.length)
        [w, h] = CLOUD_SIZES[n]
        for attempt in [0...CLOUD_TRIES]
          cloud =
            size: [w, h]
            x: Math.random() * CLOUD_LOOP
            y: Math.random() * (CLOUD_BAND_HEIGHT - h)
          box = @cloudBox cloud, 0
          others = below.concat(@cloudBox(c, 0) for c in clouds)
          continue if others.some (o) => @overlapsOnLoop box, o
          cloud.el = $('<div class="bg-cloud"></div>')
          cloud.el.css 'background-image', "url(images/clouds/cloud-#{n + 1}.png)"
          @clouds.append cloud.el
          clouds.push cloud
          break
      clouds

    # How far the wind has moved the clouds so far, in tile pixels
    windOffset: ->
      (Date.now() - @windStart) / 1000 * CLOUD_DRIFT

    # A cloud's area with the gap around it, in tile pixels; offsetY moves it to another band
    cloudBox: (cloud, offsetY) ->
      [w, h] = cloud.size
      y = cloud.y + offsetY
      {left: cloud.x - CLOUD_GAP, right: cloud.x + w + CLOUD_GAP, top: y - CLOUD_GAP, bottom: y + h + CLOUD_GAP}

    # Whether two boxes overlap, also when one of them is seen one loop to the left or right
    overlapsOnLoop: (a, b) ->
      for shift in [-CLOUD_LOOP, 0, CLOUD_LOOP]
        return true if a.left < b.right + shift and b.left + shift < a.right and
          a.top < b.bottom and b.top < a.bottom
      false

    remove: ->
      @layers.remove()

  return Background
