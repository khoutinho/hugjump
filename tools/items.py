# Draws the pixel-art item sprites. Usage: python3 tools/items.py app/images
# Outputs item-coin.png, item-drum.png (trampoline) and item-jetpack.png
import sys

from sprites import blank, hexc, save

K = hexc('#0d0f06')


def outline(px):
    """Adds a 1px black outline around (and inside holes of) everything drawn."""
    h, w = len(px), len(px[0])
    edge = []
    for y in range(h):
        for x in range(w):
            if px[y][x] is not None:
                continue
            for nx, ny in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)):
                if 0 <= nx < w and 0 <= ny < h and px[ny][nx] not in (None, K):
                    edge.append((x, y))
                    break
    for x, y in edge:
        px[y][x] = K
    return px


def coin():
    """A Chinese gold coin with a square hole."""
    size = 12
    px = blank(size, size)
    rim, face, light, shine = hexc('#b07a12'), hexc('#f2c23a'), hexc('#ffe27a'), hexc('#fff6c8')
    c = (size - 1) / 2
    for y in range(size):
        for x in range(size):
            d = ((x - c) ** 2 + (y - c) ** 2) ** 0.5
            if d <= 4.6:
                # Darker rim, thicker on the lower right where the light does not reach
                px[y][x] = rim if d > 3.6 or (d > 2.6 and x + y > 13) else face
    for x, y in [(3, 4), (4, 3), (3, 5), (5, 3)]:
        px[y][x] = light
    px[3][3] = shine
    px[4][4] = shine
    # Square hole in the middle, outlined by the outline pass
    for x, y in [(5, 5), (6, 5), (5, 6), (6, 6)]:
        px[y][x] = None
    return outline(px)


def drum():
    """A red taiko drum with a pale drumhead, used as the trampoline."""
    w, h = 24, 11
    px = blank(w, h)
    skin, skin_dark = hexc('#f3e0b5'), hexc('#d9bf8a')
    reds = [hexc('#e8463a'), hexc('#c62828'), hexc('#a51f1f'), hexc('#7e1717')]
    hoop, stud, wood = hexc('#2b1d0e'), hexc('#e0b030'), hexc('#6b4a26')
    # Drumhead seen slightly from above
    for y, (x0, x1) in enumerate([(4, 19), (2, 21), (3, 20)], start=1):
        for x in range(x0, x1 + 1):
            px[y][x] = skin if y < 3 else skin_dark
    # Barrel with a dark hoop at the top and bottom and gold studs
    for y in range(4, 9):
        for x in range(2, 22):
            px[y][x] = reds[min(3, (y - 4) * 4 // 5)]
        px[y][2] = reds[3]
    for x in range(2, 22):
        px[4][x] = hoop
        px[8][x] = hoop
    for x in range(4, 21, 4):
        px[5][x] = stud
    # Short wooden stand
    for x in (5, 6, 17, 18):
        px[9][x] = wood
    return outline(px)


def jetpack():
    """Two tanks joined by a bracket, like the original sprite, in the panda's tank colours."""
    w, h = 13, 17
    px = blank(w, h)
    metal, shadow, light, dark = hexc('#9aa4ad'), hexc('#6b7680'), hexc('#d9e0e6'), hexc('#454c54')
    for x0 in (1, 8):
        # Rounded top, shaded body (lit from the left) and a nozzle at the bottom
        px[1][x0 + 1] = light
        px[1][x0 + 2] = metal
        for y in range(2, 14):
            px[y][x0] = light
            px[y][x0 + 1] = metal
            px[y][x0 + 2] = metal
            px[y][x0 + 3] = shadow
        px[14][x0 + 1] = dark
        px[14][x0 + 2] = dark
        px[15][x0 + 1] = dark
        px[15][x0 + 2] = dark
    # Bracket joining the two tanks
    for y in (7, 8):
        for x in (5, 6, 7):
            px[y][x] = dark
    return outline(px)


def trophy():
    """Small gold trophy for the high scores toggle in the menu."""
    w, h = 12, 11
    px = blank(w, h)
    gold, dark, light = hexc('#f2c23a'), hexc('#b07a12'), hexc('#ffe27a')
    rows = {1: (3, 8), 2: (3, 8), 3: (3, 8), 4: (4, 7), 5: (5, 6), 6: (5, 6), 7: (4, 7), 8: (3, 8)}
    for y, (x0, x1) in rows.items():
        for x in range(x0, x1 + 1):
            px[y][x] = dark if y >= 7 or x == x1 else gold
    for y in (1, 2, 3):
        px[y][4] = light
    # Handles
    for x, y in [(2, 1), (1, 2), (2, 3), (9, 1), (10, 2), (9, 3)]:
        px[y][x] = gold
    return outline(px)


def speaker(on):
    """Speaker icon for the menu volume button: sound waves when on, a red X when off."""
    w, h = 14, 11
    px = blank(w, h)
    body, light = hexc('#4a463c'), hexc('#7a7466')
    # Box and cone
    for y in range(4, 7):
        for x in (1, 2):
            px[y][x] = body
    for x, (y0, y1) in zip(range(3, 7), [(3, 7), (2, 8), (1, 9), (1, 9)]):
        for y in range(y0, y1 + 1):
            px[y][x] = body
    px[4][1] = light
    if on:
        wave = hexc('#2b1d0e')
        for x, y in [(8, 4), (8, 5), (8, 6), (10, 2), (11, 3), (11, 4), (11, 5), (11, 6), (11, 7), (10, 8)]:
            px[y][x] = wave
        return px
    red = hexc('#d62828')
    for i in range(5):
        px[3 + i][8 + i] = red
        px[7 - i][8 + i] = red
    return px


if __name__ == '__main__':
    out = sys.argv[1]
    save(out + '/item-coin.png', coin())
    save(out + '/item-drum.png', drum())
    save(out + '/item-jetpack.png', jetpack())
    save(out + '/icon-trophy.png', trophy())
    save(out + '/icon-sound-on.png', speaker(True))
    save(out + '/icon-sound-off.png', speaker(False))
