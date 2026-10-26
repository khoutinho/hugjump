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
        signUp: 'Cadastro'
        name: 'Nome'
        phone: 'Telefone'
        email: 'E-mail'
        invalidName: 'Digite seu nome'
        invalidPhone: 'Telefone inválido (com DDD)'
        invalidEmail: 'E-mail inválido'
        rank: 'Posição: '
        back: 'Voltar'
        noScores: 'Nenhum recorde ainda'
        on: 'LIGADO'
        off: 'DESLIGADO'
        switchLanguage: 'Switch to English'
        volume: 'Volume'
        exported: '{n} cadastros exportados'
        exportedOne: '1 cadastro exportado'
        nothingToExport: 'Nenhum cadastro'
        privacy: 'Seus dados serão usados apenas para contato sobre a premiação.'
      en:
        play: 'Play'
        gameOver: 'Game Over!'
        yourScore: 'Your score: '
        highScore: 'High score: '
        again: 'Again!'
        menu: 'Menu'
        highScores: 'High Scores'
        signUp: 'Sign up'
        name: 'Name'
        phone: 'Phone'
        email: 'Email'
        invalidName: 'Enter your name'
        invalidPhone: 'Invalid phone (with area code)'
        invalidEmail: 'Invalid email'
        rank: 'Rank: '
        back: 'Back'
        noScores: 'No high scores yet'
        on: 'ON'
        off: 'OFF'
        switchLanguage: 'Mudar para português'
        volume: 'Volume'
        exported: '{n} players exported'
        exportedOne: '1 player exported'
        nothingToExport: 'No players yet'
        privacy: 'Your details will only be used to contact you about the prize.'

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
