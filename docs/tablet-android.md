Rodar o Hug Jump num tablet Android
===================================

Anotações para quando formos colocar o jogo num tablet **Android**. Nada disto foi feito ainda e o
jogo ainda não foi testado em tablet.

O que já funciona
-----------------

* O jogo foi feito originalmente para celular: o panda já se move inclinando o aparelho
  (`deviceorientation`, em `app/scripts/controls.coffee`).
* Os botões funcionam com toque, porque o toque também gera clique.

O que impede hoje
-----------------

1. **A inclinação só funciona em HTTPS.** O Chrome do Android só envia os dados do sensor para sites
   `https://` (ou `localhost`). Abrindo o jogo pelo IP do PC (`http://192.168.x.x:8000`), ele carrega,
   mas o panda não se mexe.
2. **O tablet não enxerga o servidor do WSL.** O `npm run dev` roda dentro do WSL2, que por padrão
   não fica acessível para outros aparelhos da rede.
3. **Sem teclado físico.** Atalhos de teclado (como o atalho secreto dos recordes) não existem no
   tablet; cada um precisa de um equivalente por toque.
4. **Cadastro (nome, telefone, e-mail):** o teclado virtual deve abrir nos campos (o de telefone já
   pede o teclado numérico), mas não foi testado. Ele pode cobrir parte da tela.

Plano
-----

1. **Controle por toque:** segurar o lado esquerdo ou direito da tela move o panda. É mais confiável
   que a inclinação num stand (não depende de como a pessoa segura o tablet nem de HTTPS). Manter a
   inclinação funcionando junto.
2. **Como servir o jogo**, conforme houver internet no stand:
   * **Com internet: GitHub Pages** (`https://khoutinho.github.io/hugjump`). Grátis e já com HTTPS.
     Precisa de:
     * uma GitHub Action que rode `npm run build` e publique a pasta `app/`, porque os `.js` e o
       `main.css` gerados não vão para o git;
     * trocar os caminhos absolutos dos sons (`/sound/...` em `app/scripts/gameScene.coffee`) por
       relativos (`sound/...`), porque no Pages o jogo fica em `/hugjump/`.
   * **Sem internet:** servir pelo PC na rede local. Para a inclinação funcionar, precisa de HTTPS
     local (certificado próprio) e liberar a porta do WSL2 para a rede (port proxy do Windows ou
     modo de rede espelhado do WSL). Com o controle por toque, HTTP simples já basta.
3. **Tela:** testar em pé e deitado, colocar em tela cheia (botão ou primeiro toque) e, se possível,
   fixar o tablet em modo quiosque (fixar tela do Android) para ninguém sair do navegador.
4. **Testar no aparelho:** toque, inclinação, sons, teclado virtual no cadastro e desempenho.

Pendências específicas do tablet
--------------------------------

* **Recordes ligados/desligados:** já resolvido. Além do `Shift+R`, segurar o título "HUG JUMP" por
  3 segundos liga ou desliga. Funciona com toque (testado com toque simulado, falta testar no
  aparelho).
* **Exportar cadastros:** na tela de recordes, além do `Shift+Y`, segurar o título "Recordes" por 3
  segundos baixa o CSV.
  No Chrome do Android o arquivo deve ir para a pasta **Downloads** (aparece uma notificação de
  download). Falta testar no aparelho; se o Chrome bloquear, a alternativa é usar o compartilhamento
  do Android (Web Share API) para mandar o arquivo por e-mail/WhatsApp/Drive.
* **Game over e recordes:** Enter, espaço e Esc não existem no tablet, mas os botões continuam
  funcionando por toque.
