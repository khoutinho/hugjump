define ["item"], (Item) ->
  class Coin extends Item
    SCALED = false
    COLLISION_DISTANCE = 20
    # A coin is worth a share of the height climbed so far, so it still matters high up
    HEIGHT_SHARE = 0.05
    MIN_VALUE = 50
    # Matches the length of the coin-points animation in main.scss
    POINTS_SHOW_MS = 900

    constructor: (gameScene, x, y) ->
      super gameScene, x, y

      if not SCALED
        ratio = gameScene.game.ratio
        COLLISION_DISTANCE *= ratio
        COLLISION_DISTANCE *= COLLISION_DISTANCE
        #square the collision distance so we don't need to take sqrt in collision detection
        SCALED = true

    makeElement: ->
      e = super()
      e.addClass "coin"
      return e

    @property 'center',
      get: ->
        {x:@x + @width / 2, y: @y + @height / 2}

    checkPlayerCollision: (player, oldPosition) ->
      playerCenter = {x:player.pos.x, y: player.pos.y - player.height/2}
      dist = Math.pow(Math.abs(playerCenter.x - @center.x), 2) + Math.pow(Math.abs(playerCenter.y - @center.y), 2)

      if dist < COLLISION_DISTANCE
        @collision()

    collision: ->
      super()
      scoreBoard = @gameScene.scoreBoard
      points = Math.max(MIN_VALUE, Math.round(scoreBoard.height * HEIGHT_SHARE))
      scoreBoard.addBonus points
      @showPoints points
      @gameScene.sounds.play('coin')

    # "+N" next to the coin that floats up and fades out
    showPoints: (points) ->
      label = $('<div class="coin-points"></div>').text "+#{points}"
      label.css top: "#{@y - @gameScene.camera.position}px"
      # Right of the coin, or left of it near the right edge so the text isn't cut off
      if @x > @gameScene.width * 0.7
        label.css right: "#{@gameScene.width - @x}px"
      else
        label.css left: "#{@x + @width}px"
      @gameScene.game.el.append label
      setTimeout (-> label.remove()), POINTS_SHOW_MS

  return Coin
