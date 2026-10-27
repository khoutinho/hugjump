# Draws the home screen icons from the panda. Usage: python3 tools/icon.py app/images
# Outputs icon-192.png and icon-512.png: the panda centred on the sky colour, scaled up pixel by pixel
import sys

from sprites import blank, load, save

SIZE = 32


def icon(panda, sky, scale):
    h, w = len(panda), len(panda[0])
    x0, y0 = (SIZE - w) // 2, (SIZE - h) // 2
    small = blank(SIZE, SIZE)
    for y in range(SIZE):
        for x in range(SIZE):
            p = panda[y - y0][x - x0] if 0 <= y - y0 < h and 0 <= x - x0 < w else None
            small[y][x] = p or sky
    return [[small[y // scale][x // scale] for x in range(SIZE * scale)] for y in range(SIZE * scale)]


if __name__ == '__main__':
    out = sys.argv[1]
    panda = load(out + '/panda.png')
    # The top of the sky behind the menu
    sky = load(out + '/background-sky.png')[0][0]
    save(out + '/icon-192.png', icon(panda, sky, 6))
    save(out + '/icon-512.png', icon(panda, sky, 16))
