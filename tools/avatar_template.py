from pathlib import Path

from PIL import Image, ImageDraw

SIZE = 1024
OUT = Path(__file__).resolve().parent.parent / "docs" / "avatar-template.png"

ANCHORS = {
    "eyes (centre of each eye)": [(0.43, 0.22), (0.57, 0.22)],
    "brows": [(0.43, 0.17), (0.57, 0.17)],
    "nose tip": [(0.50, 0.31)],
    "mouth": [(0.50, 0.37)],
    "hair line": [(0.50, 0.10)],
    "chin": [(0.50, 0.41)],
    "shoulders": [(0.38, 0.52), (0.62, 0.52)],
    "hands": [(0.28, 0.72), (0.72, 0.72)],
    "feet": [(0.44, 0.97), (0.56, 0.97)],
}


def px(v):
    return int(v * SIZE)


def main():
    img = Image.new("RGBA", (SIZE, SIZE), (255, 255, 255, 255))
    d = ImageDraw.Draw(img)
    for i in range(0, SIZE + 1, SIZE // 8):
        d.line([(i, 0), (i, SIZE)], fill=(225, 225, 225, 255))
        d.line([(0, i), (SIZE, i)], fill=(225, 225, 225, 255))
    d.ellipse([px(0.35), px(0.03), px(0.65), px(0.42)], outline=(90, 90, 90, 255), width=4)
    d.rectangle([px(0.46), px(0.38), px(0.54), px(0.50)], outline=(90, 90, 90, 255), width=4)
    d.polygon([(px(0.38), px(0.50)), (px(0.62), px(0.50)), (px(0.66), px(0.72)), (px(0.34), px(0.72))], outline=(90, 90, 90, 255))
    d.rectangle([px(0.40), px(0.72), px(0.60), px(0.97)], outline=(90, 90, 90, 255), width=4)
    d.rectangle([px(0.0), px(0.0), px(1) - 1, px(1) - 1], outline=(200, 40, 40, 255), width=4)
    for name, points in ANCHORS.items():
        for x, y in points:
            r = 9
            d.ellipse([px(x) - r, px(y) - r, px(x) + r, px(y) + r], fill=(220, 40, 40, 255))
        d.text((px(points[0][0]) + 16, px(points[0][1]) - 6), name, fill=(180, 20, 20, 255))
    img.save(OUT)


if __name__ == "__main__":
    main()
