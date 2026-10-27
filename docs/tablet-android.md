Rodar o Hug Jump num tablet Android
===================================

Como jogar
----------

* **Mover o panda:** segurar o lado esquerdo ou direito da tela (`app/scripts/controls.coffee`). Se
  houver dois dedos, vale o último que encostou. A inclinação do aparelho também funciona, mas só
  em HTTPS (no GitHub Pages sim, pelo IP do PC não).
* **Botões:** funcionam com toque.
* **Atalhos de staff sem teclado:**
  * segurar o título "HUG JUMP" por 3 segundos liga ou desliga os recordes (o mesmo que `Shift+R`);
  * segurar o título "Recordes" por 3 segundos baixa o CSV dos cadastros (o mesmo que `Shift+Y`).
* **Game over e recordes:** Enter, espaço e Esc não existem no tablet; use os botões.

Os recordes e cadastros ficam salvos **no navegador do próprio tablet** (localStorage). Não limpe os
dados do Chrome antes de exportar o CSV.

Com internet: GitHub Pages
--------------------------

A Action `.github/workflows/pages.yml` compila o jogo (`npm run build`) e publica a pasta `app/` a cada
push na `main`. O endereço é **https://khoutinho.github.io/hugjump**.

1. Uma vez só: no GitHub, **Settings → Pages → Source: GitHub Actions**. Depois rode a Action de novo
   em **Actions → Publish to GitHub Pages → Run workflow** (ou faça um push).
2. No tablet, abra o endereço no Chrome.
3. Menu ⋮ → **Adicionar à tela inicial** (ou **Instalar app**). Pelo ícone, o jogo abre em tela cheia,
   em pé.
4. Para ninguém sair do jogo: **Configurações → Segurança → Fixar app** (o nome muda conforme o
   aparelho) e fixe a tela do jogo.

Depois que a página carregou uma vez, ela continua funcionando enquanto não for recarregada, mas
recarregar precisa de internet.

Sem internet: servir pelo PC na rede local
------------------------------------------

Com o controle por toque, HTTP simples basta (só a inclinação não funciona). O tablet precisa
enxergar o servidor que roda dentro do WSL2:

1. Crie `C:\Users\<usuário>\.wslconfig` com:

   ```
   [wsl2]
   networkingMode=mirrored
   ```

2. No PowerShell, `wsl --shutdown`; abra o WSL de novo e rode `npm run dev`.
3. Descubra o IP do PC com `ipconfig` no Windows (o da placa Wi-Fi).
4. No tablet, no mesmo Wi-Fi, abra `http://<IP-do-PC>:8000`. Se o Windows perguntar sobre o
   firewall, permita. Se não abrir, libere a porta 8000 no Firewall do Windows (regra de entrada TCP).

Falta testar no aparelho
------------------------

* Toque, sons e desempenho.
* Teclado virtual no cadastro: o campo de telefone pede o teclado numérico; ver se o teclado cobre
  os campos.
* Download do CSV: no Chrome do Android deve ir para a pasta **Downloads**. Se o Chrome bloquear, a
  alternativa é usar o compartilhamento do Android (Web Share API) para mandar o arquivo por
  e-mail/WhatsApp/Drive.
