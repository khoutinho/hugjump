HUG JUMP
========

Jogo de pulo infinito em pixel art: um panda sobe por uma floresta de bambu até o céu, pulando em
bambus, desviando de vigas de torii e coletando moedas, tambores e jetpacks.

Baseado no [Doodle Monster](https://github.com/sveinnfannar/Doodle-Jump-HTML5), de Heiðar Þórðarson e
Sveinn Fannar Kristjánsson.

Como rodar
----------

Requisitos: [Node.js](https://nodejs.org/) 18 ou mais novo e Python 3.

```bash
npm install
npm run dev
```

Depois abra **http://localhost:8000** no navegador.

O `npm run dev` compila o jogo, fica observando as alterações e sobe o servidor local. Ao salvar um
`.coffee` ou `.scss`, ele recompila sozinho; é só recarregar a página. Para parar, `Ctrl+C`.

Para só compilar, sem servidor:

```bash
npm run build
```

> O jogo precisa ser aberto por um servidor (como o do `npm run dev`); abrir o `app/index.html`
> direto do disco não funciona, porque os scripts são carregados com RequireJS.

Como jogar
----------

* **Setas ← →** movem o panda. Em celular ou tablet, incline o aparelho.
* No menu, qualquer tecla também começa o jogo.
* **Moeda:** +10 pontos. **Tambor:** super pulo. **Jetpack:** voa por um segundo.
* Bambus secos quebram quando você pisa. Vigas de torii vermelhas são sólidas por baixo.

Funcionalidades
---------------

* **Português e inglês:** botão de bandeira no canto do menu. A escolha fica salva no navegador.
* **Recordes:** o botão com troféu no menu liga ou desliga o pedido de nome no fim de jogo. Ligado,
  o jogador pode digitar o nome (até 10 caracteres) ou pular. O botão **Recordes** do menu mostra as
  100 melhores pontuações.
* **Fundo que muda com a altura:** a floresta desce conforme o panda sobe, até sobrar só o céu com
  nuvens geradas infinitamente.

Os recordes, o idioma e o estado do botão de recordes ficam salvos no navegador (`localStorage`).
Eles são específicos de cada navegador e computador e somem se os dados do site forem apagados.

Estrutura
---------

| Pasta / arquivo | O que tem |
| --- | --- |
| `app/scripts/*.coffee` | Código do jogo (CoffeeScript, compilado para `.js`) |
| `app/scripts/background.coffee` | Camadas do fundo e geração das nuvens |
| `app/scripts/i18n.coffee` | Todos os textos, em português e inglês |
| `app/scripts/score.coffee` | Recordes e melhor pontuação |
| `app/styles/main.scss` | Estilos (SCSS, compilado para `main.css`) |
| `app/images/` | Sprites e fundos (versões antigas em `app/images/backup/`) |
| `app/fonts/` | Fonte Press Start 2P (licença SIL OFL) |
| `tools/` | Scripts que desenham os sprites em pixel art e o substituto do Compass para o SCSS |

Ajustes rápidos
---------------

* **Ritmo do fundo:** constantes no topo de `app/scripts/background.coffee`. `FOREST_END` é a altura
  em que a floresta sai da tela e `CLOUD_START` é quando as nuvens começam a aparecer.
* **Transparência das nuvens:** `opacity` em `.bg-clouds`, no `app/styles/main.scss`.
* **Altura do panda no menu:** `$menu-panda-ground` no `app/styles/main.scss`.

Sprites
-------

Os sprites em pixel art são gerados por scripts Python, sem dependências. Para mudar cores ou formas,
edite o script e rode de novo:

```bash
python3 tools/sprites.py app/images   # bambus e torii
python3 tools/panda.py app/images     # panda e panda com jetpack
python3 tools/items.py app/images     # moeda, tambor, jetpack e troféu
python3 tools/flags.py app/images     # bandeiras do Brasil e do Reino Unido
```

Créditos
--------

* Jogo original: Doodle Monster, de Heiðar Þórðarson e Sveinn Fannar Kristjánsson.
* Fonte: [Press Start 2P](https://fonts.google.com/specimen/Press+Start+2P), de CodeMan38 (SIL Open Font License).
* Música: "Popcorn", de Hot Butter.
