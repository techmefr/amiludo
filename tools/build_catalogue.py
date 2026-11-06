import json
import re
import sys
from pathlib import Path

SLOTS = {
    "base", "head", "eyes", "eyebrows", "nose", "mouth", "hair", "beard",
    "marks", "outfit", "shoes", "accessory", "implant", "equipment", "weapon",
}

PALETTES = {
    "version": 1,
    "palettes": {
        "skin": ["#F2D2B6", "#D9A57C", "#A66E47", "#5C3A26"],
        "hair": ["#1B1B1B", "#4A2F1D", "#8B5A2B", "#C9A227", "#B5482F", "#8E8E8E", "#E8E8E8", "#3E5C8A"],
        "eyes": ["#3B2A1A", "#2E6B4F", "#3D6FB0", "#7A7A7A", "#9A5B1E", "#6A3D8A", "#B58B1F", "#1F1F1F"],
        "cloth": ["#C9B38B", "#6B7F5E", "#8A3B2E", "#3B4F6B", "#6E6E6E", "#D9D1BF"],
    },
}

RULES = [
    (r"^heads-|^head-", "head", 70, "skin"),
    (r"^eyes-", "eyes", 75, "eyes"),
    (r"^eyebrows", "eyebrows", 75, "hair"),
    (r"^noses", "nose", 75, "skin"),
    (r"^lips", "mouth", 75, "skin"),
    (r"^mouths-", "mouth", 75, None),
    (r"^marks", "marks", 75, None),
    (r"^hair", "hair", 80, "hair"),
    (r"^beards", "beard", 80, "hair"),
    (r"^horns|^crests|^goggles|^face-masks", "accessory", 85, None),
    (r"^capes", "accessory", 10, "cloth"),
    (r"^hoods|^collars", "outfit", 60, "cloth"),
    (r"^backpacks", "equipment", 10, "cloth"),
    (r"^straps|^belts|^pockets", "equipment", 90, "cloth"),
    (r"^belt-items|^signal-gear", "equipment", 90, None),
    (r"^hand-tools|^tools|^sidearms", "weapon", 100, None),
    (r"-mechanical-|^mechanical-", "implant", 30, None),
    (r"^body-base|^arms-sheet|^hands-sheet|^feet-sheet", "base", 20, "skin"),
    (r"^forearms", "base", 20, "skin"),
    (r"^sleeves|^torsos|^outfit-", "outfit", 60, "cloth"),
    (r"^legwear|^calves", "outfit", 40, "cloth"),
    (r"^boots", "shoes", 40, "cloth"),
]


def rule_for(stem):
    for pattern, slot, order, tint in RULES:
        if re.search(pattern, stem):
            return slot, order, tint
    raise ValueError(f"no rule for {stem}")


def build_items(pieces_dir):
    items = []
    for path in sorted(pieces_dir.glob("*.png")):
        stem, _, number = path.stem.rpartition("-")
        slot, order, tint = rule_for(stem)
        name = stem.replace("-sheet", "")
        layer = {"order": order, "src": f"avatar/pieces/{path.stem}"}
        if tint:
            layer["tint"] = tint
        items.append({
            "id": f"{slot}.{name}-{number}",
            "slot": slot,
            "peoples": [],
            "variants": {"average": {"layers": [layer], "hideBodyParts": []}},
        })
    return items


def validate(items, palettes, assets_dir):
    ids = set()
    for item in items:
        assert item["id"] not in ids, f"duplicate {item['id']}"
        ids.add(item["id"])
        assert item["slot"] in SLOTS, item["id"]
        assert item["id"].startswith(item["slot"] + "."), item["id"]
        for variant in item["variants"].values():
            for layer in variant["layers"]:
                assert isinstance(layer["order"], int), item["id"]
                assert (assets_dir / f"{layer['src']}.png").is_file(), layer["src"]
                if "tint" in layer:
                    assert layer["tint"] in palettes["palettes"], layer["tint"]


def main():
    assets = Path(sys.argv[1])
    items = build_items(assets / "avatar" / "pieces")
    validate(items, PALETTES, assets)
    catalogue = {"version": 1, "items": items}
    for name, data in (("items.json", catalogue), ("palettes.json", PALETTES)):
        target = assets / "avatar" / name
        target.write_text(json.dumps(data, indent=1) + "\n", encoding="utf-8")
    print(f"{len(items)} items validated")
    return 0


if __name__ == "__main__":
    sys.exit(main())
