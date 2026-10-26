#global define, $ 
Function::property = (prop, desc) ->
  Object.defineProperty @prototype, prop, desc
define ["camera", "gameScene", "controls", "menuScene", "gameOverScene", "highScoresScene", "registrationScene"],
(Camera, GameScene, controls, MenuScene, GameOverScene, HighScoresScene, RegistrationScene) ->
  class Game
    constructor: (el) ->
      console.log "GAME!!"
      @el = el
      @height = el.height()
      @DESIGN_SIZE = {x: 550, y: 768}
      @ratio = window.screen.height / @DESIGN_SIZE.y
      @update = @update.bind(this)
      @active = false
      @currentScene = null
      $('body').css('font-size', @ratio * 10 + 'px')
      @width = el.width()
      # Browsers keep Web Audio suspended until the page gets a key press, click or touch
      $(document).on 'keydown mousedown touchstart', ->
        Howler.ctx?.resume?() if Howler.ctx?.state is 'suspended'
      return

    switchScene: (scene) ->
      @active = false
      @el.empty()
      #(@el.append obj for obj in scene.buildScene())
      @el.append(scene.el)
      if @currentScene?
        @currentScene.cleanup()
      @currentScene = scene
      @active = true
    
    update: ->
      if @active
        now = +new Date() / 1000
        delta = now - @lastFrame
        controls.update delta
        @lastFrame = now
        @currentScene.update delta
      
      # Request next frame.
      requestAnimFrame @update.bind(@)
    
    scheduleUpdate: ->
      @lastFrame = +new Date() / 1000
      requestAnimFrame @update

    startMenu: ->
      # A new visitor signs up again from the menu
      @player = null
      @switchScene(new MenuScene(this))

    # Without a player, keeps the last one, so "again" plays with the same details
    startGame: (player) ->
      @player = player if player?
      @switchScene(new GameScene(this))

    startRegistration: ->
      @switchScene(new RegistrationScene(this))

    gameOver: (score, background) ->
      @switchScene(new GameOverScene(this, score, background))

    startHighScores: ->
      @switchScene(new HighScoresScene(this))
    
    requestAnimFrame = (callback) ->
      if window.requestAnimationFrame or
          window.webkitRequestAnimationFrame or
          window.mozRequestAnimationFrame or
          window.oRequestAnimationFrame or
          window.msRequestAnimationFrame or
          (callback)
        window.setTimeout callback, 1000 / 60
    
  return Game
