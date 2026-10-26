# Draws the 15x10 pixel-art flags from letter grids
import zlib, struct, sys

COLORS = {
    'G': '#009c3b', 'Y': '#ffdf00', 'B': '#002776', 'W': '#ffffff',
    'N': '#012169', 'R': '#c8102e',
}

BR = """
GGGGGGGYGGGGGGG
GGGGGYYYYYGGGGG
GGGYYYBBBYYYGGG
GYYYYBBBBBYYYYG
YYYYBWWWWWBYYYY
YYYYBBBBBBBYYYY
GYYYYBBBBBYYYYG
GGGYYYBBBYYYGGG
GGGGGYYYYYGGGGG
GGGGGGGYGGGGGGG
"""

UK = """
RWNNNNWRWNNNNWR
WRWNNNWRWNNNWRW
NWRWNNWRWNNWRWN
WWWWWWWRWWWWWWW
RRRRRRRRRRRRRRR
RRRRRRRRRRRRRRR
WWWWWWWRWWWWWWW
NWRWNNWRWNNWRWN
WRWNNNWRWNNNWRW
RWNNNNWRWNNNNWR
"""

def png(path, grid):
    rows = grid.split()
    w, h = len(rows[0]), len(rows)
    assert all(len(r) == w for r in rows), path
    rgb = lambda c: bytes(int(COLORS[c][i:i+2], 16) for i in (1, 3, 5))
    raw = b''.join(b'\x00' + b''.join(rgb(c) for c in r) for r in rows)
    chunk = lambda t, d: struct.pack('>I', len(d)) + t + d + struct.pack('>I', zlib.crc32(t + d) & 0xffffffff)
    with open(path, 'wb') as f:
        f.write(b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 2, 0, 0, 0))
                + chunk(b'IDAT', zlib.compress(raw, 9)) + chunk(b'IEND', b''))

png(sys.argv[1] + '/flag-br.png', BR)
png(sys.argv[1] + '/flag-uk.png', UK)
