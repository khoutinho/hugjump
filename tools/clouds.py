# Cuts the cloud tile into one image per cloud. Usage: python3 tools/clouds.py app/images
# Reads app/images/background-clouds.png and writes app/images/clouds/cloud-1.png, cloud-2.png...
# (largest first). Clouds touching the tile's edge are skipped, since they were cut where the tile
# repeated. Every cloud is saved with its puffy head on the right and its tail on the left, to
# match the wind blowing right. Prints the sizes to paste into CLOUD_SIZES in
# app/scripts/background.coffee
import os
import sys

from sprites import blank, load, save


def find_clouds(px):
    """Groups touching opaque pixels (including diagonally) into clouds."""
    h, w = len(px), len(px[0])
    seen = [[False] * w for _ in range(h)]
    clouds = []
    for y in range(h):
        for x in range(w):
            if px[y][x] is None or seen[y][x]:
                continue
            seen[y][x] = True
            stack, points = [(x, y)], []
            while stack:
                cx, cy = stack.pop()
                points.append((cx, cy))
                for nx in (cx - 1, cx, cx + 1):
                    for ny in (cy - 1, cy, cy + 1):
                        if 0 <= nx < w and 0 <= ny < h and px[ny][nx] is not None and not seen[ny][nx]:
                            seen[ny][nx] = True
                            stack.append((nx, ny))
            clouds.append(points)
    return clouds


def head_on_left(cloud):
    """The head holds most of the pixels and the tail is thin, so the mass leans to the head."""
    w = len(cloud[0])
    xs = [x for row in cloud for x, p in enumerate(row) if p is not None]
    return sum(xs) / len(xs) < (w - 1) / 2


if __name__ == '__main__':
    out = sys.argv[1]
    px = load(out + '/background-clouds.png')
    h, w = len(px), len(px[0])
    os.makedirs(out + '/clouds', exist_ok=True)
    clouds = [c for c in find_clouds(px)
              if all(0 < x < w - 1 and 0 < y < h - 1 for x, y in c)]
    clouds.sort(key=len, reverse=True)
    sizes = []
    for i, points in enumerate(clouds, start=1):
        x0, y0 = min(x for x, _ in points), min(y for _, y in points)
        cw = max(x for x, _ in points) - x0 + 1
        ch = max(y for _, y in points) - y0 + 1
        # Copy only this cloud's pixels, so parts of overlapping neighbours stay out
        cloud = blank(cw, ch)
        for x, y in points:
            cloud[y - y0][x - x0] = px[y][x]
        if head_on_left(cloud):
            cloud = [row[::-1] for row in cloud]
        save('%s/clouds/cloud-%d.png' % (out, i), cloud)
        sizes.append('[%d, %d]' % (cw, ch))
    print('CLOUD_SIZES = [%s]' % ', '.join(sizes))
