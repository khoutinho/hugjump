define [], ->
  class I18n
    STRINGS =
      pt:
        play: 'Jogar'
        gameOver: 'Fim de Jogo!'
        yourScore: 'Sua pontuação: '
        highScore: 'Recorde: '
        again: 'De novo!'
        menu: 'Menu'
        highScores: 'Recordes'
        enterName: 'Digite seu nome:'
        save: 'Salvar'
        skip: 'Pular'
        rank: 'Posição: '
        back: 'Voltar'
        noScores: 'Nenhum recorde ainda'
        on: 'LIGADO'
        off: 'DESLIGADO'
        scoresToggleHint: 'Pedir o nome no fim de jogo para salvar nos recordes'
        switchLanguage: 'Switch to English'
      en:
        play: 'Play'
        gameOver: 'Game Over!'
        yourScore: 'Your score: '
        highScore: 'High score: '
        again: 'Again!'
        menu: 'Menu'
        highScores: 'High Scores'
        enterName: 'Enter your name:'
        save: 'Save'
        skip: 'Skip'
        rank: 'Rank: '
        back: 'Back'
        noScores: 'No high scores yet'
        on: 'ON'
        off: 'OFF'
        scoresToggleHint: 'Ask for a name at game over to save it in the high scores'
        switchLanguage: 'Mudar para português'

    constructor: ->
      # Portuguese by default; the choice is remembered between visits when storage works
      @lang = 'pt'
      try
        saved = localStorage['lang']
        @lang = saved if saved of STRINGS
      catch e

    t: (key) ->
      STRINGS[@lang][key]

    toggle: ->
      @lang = if @lang is 'pt' then 'en' else 'pt'
      try
        localStorage['lang'] = @lang
      catch e

  return new I18n
