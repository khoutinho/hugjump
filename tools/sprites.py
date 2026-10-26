# Draws the pixel-art platform sprites. Usage: python3 tools/sprites.py app/images
import struct
import sys
import zlib

W = 32
BAMBOO_W, BAMBOO_H = 28, 8


def hexc(h):
    return tuple(int(h[i:i + 2], 16) for i in (1, 3, 5)) + (255,)


def blank(w, h):
    return [[None] * w for _ in range(h)]


def save(path, px):
    h, w = len(px), len(px[0])
    raw = b''.join(b'\x00' + b''.join(bytes(p or (0, 0, 0, 0)) for p in row) for row in px)

    def chunk(t, d):
        return struct.pack('>I', len(d)) + t + d + struct.pack('>I', zlib.crc32(t + d) & 0xffffffff)

    with open(path, 'wb') as f:
        f.write(b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 6, 0, 0, 0))
                + chunk(b'IDAT', zlib.compress(raw, 9)) + chunk(b'IEND', b''))


# Palettes sampled from the reference photo: warm yellow-green stalk, straw-coloured nodes and cut.
# Shades go from the top of the stalk (lit) to the bottom (shadow)
GREEN = {
    'shades': ['#b9cc52', '#94b230', '#73921f', '#4f6a12'],
    'fiber_light': '#a9c240', 'fiber_dark': '#5f7e18',
    'node': ['#e1c69a', '#bd985c', '#866a3b'],
    'cut': ['#e1c69a', '#9c7a4c'],
}
DRY = {
    'shades': ['#f2dfa2', '#dcbc76', '#bb9550', '#8f6d36'],
    'fiber_light': '#ecd391', 'fiber_dark': '#a07e40',
    'node': ['#a07a44', '#7a5a2e', '#4e3818'],
    'cut': ['#f2e2b4', '#8e6c3c'],
}
OUTLINE = '#0d0f06'
NODES = (9, 19)


def detailed_stalk(pal, h=BAMBOO_H):
    """A horizontal bamboo stalk with a black outline, cylindrical shading, fibers, raised
    nodes and a hollow cut on the right end. The stalk spans rows 1..6; nodes bulge to 0 and 7."""
    w = BAMBOO_W
    px = blank(w, h)
    c = {k: (hexc(v) if isinstance(v, str) else [hexc(x) for x in v]) for k, v in pal.items()}
    black = hexc(OUTLINE)
    top, bottom = 1, 6
    for x in range(w):
        px[top][x] = black
        px[bottom][x] = black
    for y in range(top + 1, bottom):
        for x in range(w):
            px[y][x] = c['shades'][y - top - 1]
        px[y][0] = black
        px[y][w - 1] = black
    # A few fibers: short streaks of a lighter or darker tone, placed deterministically
    for x0, y, length in [(2, 3, 3), (12, 2, 2), (22, 3, 2), (4, 4, 2), (14, 4, 3), (24, 4, 2)]:
        tone = c['fiber_light'] if y < 4 else c['fiber_dark']
        for x in range(x0, x0 + length):
            px[y][x] = tone
    # Nodes: a straw-coloured ring with a dark line, slightly wider than the stalk
    light, mid, dark = c['node']
    for nx in NODES:
        for y in range(top + 1, bottom):
            px[y][nx] = light if y < 4 else mid
            px[y][nx + 1] = dark
        for x in (nx - 1, nx, nx + 1, nx + 2):
            px[0][x] = black
            px[7][x] = black
    # Hollow cut on the right end: pale rim around a darker inside
    rim, deep = c['cut']
    for y in range(top + 1, bottom):
        px[y][w - 2] = deep if y in (3, 4) else rim
    return px


def bamboo():
    return detailed_stalk(GREEN)


def dry_bamboo():
    # Extra transparent rows at the bottom give the broken pieces room to fall
    px = detailed_stalk(DRY, h=BAMBOO_H + 3)
    crack = hexc('#2a1a0a')
    for x, y in [(5, 2), (6, 3), (15, 4), (16, 5), (23, 3), (24, 4)]:
        px[y][x] = crack
    return px


def split(px, gap, drop, tilt):
    """Snaps the stalk in the middle: a gap opens and both halves sag into a V."""
    h, w = len(px), len(px[0])
    out = blank(w, h)
    mid = w // 2
    for y in range(h):
        for x in range(w):
            c = px[y][x]
            if c is None or mid - gap <= x < mid + gap:
                continue
            # Distance from the outer end, 0 at the tips and 1 at the break
            t = x / (mid - 1) if x < mid else (w - 1 - x) / (mid - 1)
            ny = y + drop + round(tilt * t)
            if ny < h:
                out[ny][x] = c
    return out


def dry_bamboo_sheet():
    base = dry_bamboo()
    w = len(base[0])
    cracked = [row[:] for row in base]
    crack = hexc('#2a1a0a')
    for y in range(2, 6):
        cracked[y][w // 2 - 1 + (y % 2)] = crack
    frames = [base, cracked, split(base, 1, 0, 1), split(base, 2, 1, 2)]
    sheet = blank(w * len(frames), len(base))
    for i, f in enumerate(frames):
        for y, row in enumerate(f):
            for x, c in enumerate(row):
                sheet[y][i * w + x] = c
    return sheet


def torii_beam():
    """The red crossbeam of a torii gate, with its dark curved top cap."""
    px = blank(W, 8)
    cap, cap_light = hexc('#2b1d0e'), hexc('#4a3622')
    reds = [hexc('#ec5a46'), hexc('#cf2f26'), hexc('#b0231d'), hexc('#8e1a16')]
    edge = hexc('#5a0f0f')
    gold = hexc('#e0b030')
    # Cap wider than the beam, with upturned tips
    for x in (0, 1, W - 2, W - 1):
        px[0][x] = cap
    for x in range(0, W):
        px[1][x] = cap
    for x in range(1, W - 1):
        px[2][x] = cap
    for x in range(3, W - 3):
        px[1][x] = cap_light
    # Red beam under the cap
    for y, c in enumerate(reds):
        for x in range(2, W - 2):
            px[3 + y][x] = c
    for x in range(2, W - 2):
        px[7][x] = edge
    for y in range(3, 8):
        px[y][2] = edge
        px[y][W - 3] = edge
    # Central plaque and gold studs
    for y in range(3, 7):
        px[y][15] = cap
        px[y][16] = cap
    for x in (6, 25):
        px[4][x] = gold
    return px


if __name__ == '__main__':
    out = sys.argv[1]
    save(out + '/platform-bamboo.png', bamboo())
    save(out + '/platform-bamboo-dry.png', dry_bamboo_sheet())
    save(out + '/obstacle-torii.png', torii_beam())
