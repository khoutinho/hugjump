# Draws the pixel-art panda player. Usage: python3 tools/panda.py app/images [v1]
# Outputs panda.png (facing right) and panda-jetpack.png (2 frames side by side, flickering flame)
# By default draws the low-res 26x25 panda from LOWRES below. With "v1" it draws the first, more
# detailed 36x35 version from shapes (backed up in app/images/backup/panda-v1.png)
import sys

from sprites import blank, hexc, save

W, H = 36, 35

C = {
    'K': hexc('#0d0f06'),  # outline
    'W': hexc('#efe6d2'),  # cream fur
    'w': hexc('#cbbd9f'),  # cream fur in shadow
    'B': hexc('#2a2a30'),  # black fur
    'b': hexc('#4a4a55'),  # black fur highlight
    'P': hexc('#f29aa6'),  # pink cheek / inner ear
    'E': hexc('#ffffff'),  # eye shine
    'G': hexc('#9aa4ad'),  # jetpack metal
    'g': hexc('#6b7680'),  # jetpack metal shadow
    'L': hexc('#d9e0e6'),  # jetpack metal highlight
    'N': hexc('#454c54'),  # jetpack nozzle
    'O': hexc('#ff8a1f'),  # flame
    'Y': hexc('#ffd84a'),  # flame core
}


def ellipse(px, cx, cy, rx, ry, color, shade=None):
    """Fills an ellipse; with a shade colour the lower-left part is darker (light from top-right)."""
    for y in range(H):
        for x in range(W):
            dx, dy = (x - cx) / rx, (y - cy) / ry
            if dx * dx + dy * dy <= 1:
                px[y][x] = shade if shade and dy - dx * 0.4 > 0.8 else color


def outline(px):
    """Adds a 1px black outline around everything drawn."""
    edge = []
    for y in range(H):
        for x in range(W):
            if px[y][x] is not None:
                continue
            for nx, ny in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)):
                if 0 <= nx < W and 0 <= ny < H and px[ny][nx] not in (None, C['K']):
                    edge.append((x, y))
                    break
    for x, y in edge:
        px[y][x] = C['K']


def put(px, points, color):
    for x, y in points:
        if 0 <= x < W and 0 <= y < H:
            px[y][x] = color


def panda(jetpack_frame=None):
    px = blank(W, H)
    K, Wf, w, B, b = C['K'], C['W'], C['w'], C['B'], C['b']

    if jetpack_frame is not None:
        # Tank on the panda's back (left side, since it faces right)
        for y in range(14, 27):
            for x in range(2, 8):
                px[y][x] = C['L'] if x == 3 else C['g'] if x >= 6 else C['G']
        put(px, [(x, 14) for x in range(3, 7)], C['L'])
        put(px, [(x, 27) for x in range(3, 7)], C['N'])
        # Flame under the nozzle, two frames so it flickers
        if jetpack_frame == 0:
            flame = [(3, 28), (4, 28), (5, 28), (6, 28), (3, 29), (4, 29), (5, 29), (6, 29), (4, 30), (5, 30), (4, 31)]
            core = [(4, 28), (5, 28), (4, 29), (5, 29)]
        else:
            flame = [(3, 28), (4, 28), (5, 28), (6, 28), (4, 29), (5, 29), (6, 29), (5, 30), (5, 31), (5, 32)]
            core = [(4, 28), (5, 28), (5, 29)]
        put(px, flame, C['O'])
        put(px, core, C['Y'])

    # Profile facing right, like the reference photos: one eye, long muzzle, ears at the back
    # Ears behind the head
    ellipse(px, 14.5, 5.5, 2.8, 2.8, B)
    ellipse(px, 21.0, 3.6, 2.5, 2.5, B)
    put(px, [(14, 4), (15, 4), (21, 2)], b)

    # Hind legs and back paw under the body
    ellipse(px, 13.5, 30.5, 4.2, 3.4, B)
    ellipse(px, 21, 32, 3.2, 2.3, B)
    # Body: cream rear, black band over the shoulders
    ellipse(px, 15.5, 23.5, 9.0, 7.5, Wf, w)
    ellipse(px, 19.0, 20.5, 5.6, 4.2, B)
    put(px, [(17, 17), (18, 17), (16, 18)], b)
    # Front arms reaching forward, the near one raised with its paw up
    ellipse(px, 23.5, 25.0, 3.8, 1.8, B)
    ellipse(px, 25.5, 21.5, 4.4, 2.0, B)
    ellipse(px, 29.5, 20.2, 1.6, 1.9, B)
    put(px, [(26, 20), (27, 20), (29, 19)], b)

    # Head and long muzzle
    ellipse(px, 21, 10.5, 8.0, 7.0, Wf)
    ellipse(px, 28.5, 12.8, 3.9, 3.7, Wf)
    put(px, [(15, 15), (16, 16), (17, 16), (18, 17), (19, 17)], w)
    # One eye patch, a slanted teardrop, with the eye shining inside
    ellipse(px, 24.2, 9.5, 2.0, 2.8, B)
    ellipse(px, 25.4, 11.4, 1.4, 1.4, B)
    put(px, [(25, 9)], C['E'])
    # Nose at the tip of the muzzle and the mouth line
    put(px, [(31, 11), (32, 11), (31, 12), (32, 12)], K)
    put(px, [(29, 14), (30, 14)], K)
    # Cheek
    put(px, [(27, 15)], C['P'])

    outline(px)
    return px


# Low-res panda, hand-edited from the v1 shapes at 72% (the previous take is in
# app/images/backup/panda-v2.png). Letters are the colours in C, '.' is empty
LOWRES = [
    '..............KKK.........',
    '.........KKK.KBbBK........',
    '........KBbBKKBBBKK.......',
    '........KBBBWWWWWWWKK.....',
    '........KBBWWWWWWWWWWK....',
    '.........KWWWWWWWBBWWWK...',
    '.........KWWWWWWBBEBWWWK..',
    '.........KWWWWWWBBBBWWWWK.',
    '.........KWWWWWWWBBBWWWBB.',
    '.........KWWWWWWWWWWWWWWK.',
    '..........KWWWWWWWWPWBWKK.',
    '.........KKwWWWWWWWWWWKK..',
    '.......KKWWWwwwWWWKKKK....',
    '......KWWWWBbBBBBK...KK...',
    '.....KWWWWBBBBBBBBK.KBBK..',
    '.....KWWWWBBBBBBBBBKBBBK..',
    '....KWWWWWWBBBBBBBBBBBK...',
    '....KWWWWWWWWWBBBBBBBK....',
    '....KWWWWWWWWWWWWBBBK.....',
    '...KBBWWWWWWWWWWWWKK......',
    '..KBBBwwWWWWWWWWWK........',
    '..KBBKKwwwwWWWWWK.........',
    '...KK.KBBwwwwwBBBK........',
    '......KBBBBBBBBBBBK.......',
    '.......KKBBBKKBBBK........',
]


def lowres_panda(jetpack_frame=None):
    global W, H
    W, H = len(LOWRES[0]), len(LOWRES)
    px = blank(W, H)
    if jetpack_frame is not None:
        # Tank on the back above the hind paw, mostly hidden behind the body, then the nozzle
        # and a flickering flame
        for y in range(11, 17):
            for x in range(1, 6):
                px[y][x] = C['L'] if x == 2 else C['g'] if x == 5 else C['G']
        put(px, [(x, 17) for x in range(2, 4)], C['N'])
        if jetpack_frame == 0:
            flame = [(1, 18), (2, 18), (3, 18), (1, 19), (2, 19), (1, 20)]
            core = [(2, 18), (2, 19)]
        else:
            flame = [(1, 18), (2, 18), (3, 18), (1, 19), (2, 19), (1, 20), (1, 21)]
            core = [(2, 18), (1, 19)]
        put(px, flame, C['O'])
        put(px, core, C['Y'])
    # The panda (already outlined) goes in front of the tank
    for y, row in enumerate(LOWRES):
        for x, c in enumerate(row):
            if c != '.':
                px[y][x] = C[c]
    outline(px)
    return px


if __name__ == '__main__':
    out = sys.argv[1]
    draw = panda if len(sys.argv) > 2 and sys.argv[2] == 'v1' else lowres_panda
    save(out + '/panda.png', draw())
    frames = [draw(0), draw(1)]
    save(out + '/panda-jetpack.png', [frames[0][y] + frames[1][y] for y in range(H)])
