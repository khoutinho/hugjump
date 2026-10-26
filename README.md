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
* No fim de jogo, **Enter** ou **espaço** joga de novo e **Esc** volta ao menu.
* Se ninguém mexer por 45 segundos no fim de jogo ou nos recordes, o jogo volta sozinho ao menu.
* **Moeda:** bônus de 5% da altura já subida (mínimo 50 pontos). **Tambor:** super pulo. **Jetpack:** voa por um segundo.
* Bambus secos quebram quando você pisa. Vigas de torii vermelhas são sólidas por baixo.

Funcionalidades
---------------

* **Português e inglês:** botão de bandeira no canto do menu. A escolha fica salva no navegador.
* **Volume:** o alto-falante ao lado da bandeira abre uma barra de 0 a 100, para música e efeitos.
  Clicar fora dela (ou no alto-falante de novo) fecha. Em 0, o ícone mostra um X vermelho.
* **Recordes:** o atalho secreto **Shift+R** no menu, ou **segurar o título "HUG JUMP" por 3
  segundos** (para telas de toque), liga ou desliga os recordes. O estado aparece por 2 segundos no
  canto da tela. Ligado, **Jogar** abre um cadastro obrigatório (nome, telefone com DDD e e-mail)
  antes da partida, e cada partida é salva sozinha no fim de jogo. **De novo** joga com o mesmo
  cadastro; **Menu** volta para um cadastro novo. Cada e-mail aparece uma vez no ranking, com a
  melhor pontuação. O botão **Recordes** do menu mostra as 100 melhores (só nome e pontos).
* **Exportar cadastros:** na tela de **Recordes**, **Shift+Y** ou **segurar o título "Recordes" por 3
  segundos** (telas de toque) baixa uma planilha CSV com nome, telefone, e-mail e melhor pontuação de todos os
  cadastrados (`hug-jump-cadastros-AAAA-MM-DD-HHMM.csv`, abre direto no Excel). O cadastro avisa que
  os dados serão usados só para contato sobre a premiação.
* **Fundo:** ao perder, o fundo continua na altura em que o panda caiu e só volta ao início em
  **De novo** ou **Menu**.
* **Fundo que muda com a altura:** a floresta desce conforme o panda sobe, até sobrar só o céu com
  nuvens geradas infinitamente.

Os recordes, o idioma, o volume e o estado dos recordes ficam salvos no navegador (`localStorage`).
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
| `docs/tablet-android.md` | O que falta para rodar num tablet Android |
| `tools/` | Scripts que desenham os sprites em pixel art e o substituto do Compass para o SCSS |

Ajustes rápidos
---------------

* **Ritmo do fundo:** constantes no topo de `app/scripts/background.coffee`. `FOREST_END` é a altura
  em que a floresta sai da tela e `CLOUD_START` é quando as nuvens começam a aparecer.
* **Quantidade de nuvens:** `CLOUDS_PER_BAND` em `app/scripts/background.coffee` (mais = céu mais
  cheio) e `CLOUD_GAP` para o espaço mínimo entre elas.
* **Vento nas nuvens:** `CLOUD_DRIFT` no mesmo arquivo (pixels do desenho por segundo, sempre para a
  direita; 0 para nuvens paradas). As nuvens dão a volta: a que sai pela direita volta pela esquerda.
* **Transparência das nuvens:** `opacity` em `.bg-clouds`, no `app/styles/main.scss`.
* **Altura do panda no menu:** `$menu-panda-ground` no `app/styles/main.scss`.

Sprites
-------

Os sprites em pixel art são gerados por scripts Python, sem dependências. Para mudar cores ou formas,
edite o script e rode de novo:

```bash
python3 tools/sprites.py app/images   # bambus e torii
python3 tools/panda.py app/images     # panda e panda com jetpack (com "v1", o panda antigo, mais detalhado)
python3 tools/items.py app/images     # moeda, tambor, jetpack, troféu e alto-falante
python3 tools/flags.py app/images     # bandeiras do Brasil e do Reino Unido
python3 tools/clouds.py app/images    # recorta background-clouds.png em nuvens soltas (app/images/clouds/)
```

Créditos
--------

* Jogo original: Doodle Monster, de Heiðar Þórðarson e Sveinn Fannar Kristjánsson.
* Fonte: [Press Start 2P](https://fonts.google.com/specimen/Press+Start+2P), de CodeMan38 (SIL Open Font License).
* Música: "Popcorn", de Hot Butter.
