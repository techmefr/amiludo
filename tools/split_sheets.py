import argparse
import sys
from pathlib import Path

import numpy as np
from PIL import Image
from scipy import ndimage

CANVAS = 1024
MARGIN = 32
MAX_UPSCALE = 2.0
WHITE = 238
MERGE_GAP = 10
MIN_AREA = 400


def clear_white_background(rgba):
    if (rgba[..., 3] < 250).mean() > 0.02:
        return rgba
    near_white = (rgba[..., :3] >= WHITE).all(axis=2)
    labels, _ = ndimage.label(near_white)
    border = np.concatenate([labels[0], labels[-1], labels[:, 0], labels[:, -1]])
    background = np.isin(labels, np.unique(border[border > 0]))
    out = rgba.copy()
    out[background, 3] = 0
    return out


def find_pieces(rgba):
    solid = rgba[..., 3] > 16
    merged = ndimage.binary_dilation(solid, iterations=MERGE_GAP)
    labels, _ = ndimage.label(merged)
    pieces = []
    for index, box in enumerate(ndimage.find_objects(labels), start=1):
        mask = (labels[box] == index) & solid[box]
        if mask.sum() >= MIN_AREA:
            pieces.append((box, mask))
    band = max(1, rgba.shape[0] // 4)
    pieces.sort(key=lambda piece: (piece[0][0].start // band, piece[0][1].start))
    return pieces


def place(rgba, box, mask):
    crop = rgba[box].copy()
    crop[~mask, 3] = 0
    image = Image.fromarray(crop, "RGBA")
    limit = CANVAS - 2 * MARGIN
    scale = min(limit / image.width, limit / image.height, MAX_UPSCALE)
    size = (max(1, round(image.width * scale)), max(1, round(image.height * scale)))
    image = image.resize(size, Image.LANCZOS)
    canvas = Image.new("RGBA", (CANVAS, CANVAS), (0, 0, 0, 0))
    canvas.paste(image, ((CANVAS - size[0]) // 2, (CANVAS - size[1]) // 2))
    return canvas


def split_sheet(path, out_dir):
    cleaned = clear_white_background(np.array(Image.open(path).convert("RGBA")))
    pieces = find_pieces(cleaned)
    for number, (box, mask) in enumerate(pieces, start=1):
        place(cleaned, box, mask).save(out_dir / f"{path.stem}-{number}.png")
    return len(pieces)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("sheets", type=Path)
    parser.add_argument("out", type=Path)
    args = parser.parse_args()
    args.out.mkdir(parents=True, exist_ok=True)
    total = 0
    for path in sorted(args.sheets.glob("*.png")):
        count = split_sheet(path, args.out)
        total += count
        print(f"{path.stem}: {count}")
    print(f"total: {total}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
