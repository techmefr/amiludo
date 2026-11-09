"""Regenerate amiLudo artwork from the filled-path SVG master.

Install scripts/requirements-brand.txt, then run python3 scripts/build_brand.py.
"""
from copy import deepcopy
from pathlib import Path
import json
import xml.etree.ElementTree as ET

import cairosvg
from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.pens.transformPen import TransformPen
from fontTools.ttLib import TTFont
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
LOGO = ROOT / 'design/logo'
PURPLE = '#6644D6'
YELLOW = '#F6C445'
INK = '#2A1F44'
WHITE = '#FFFFFF'
SVG = 'http://www.w3.org/2000/svg'
ET.register_namespace('', SVG)


def document(body, width=256, height=256, title='amiLudo'):
    return (f'<svg xmlns="{SVG}" width="{width}" height="{height}" '
            f'viewBox="0 0 {width} {height}" role="img" aria-labelledby="title">\n'
            f'  <title id="title">{title}</title>\n{body}\n</svg>\n')


def master_body(primary=PURPLE, secondary=YELLOW, small=False):
    tree = ET.parse(LOGO / 'amiludo-mark.svg').getroot()
    groups = []
    for element in tree:
        if element.tag.endswith('title'):
            continue
        element = deepcopy(element)
        for node in element.iter():
            if node.get('fill') == PURPLE:
                node.set('fill', primary)
            elif node.get('fill') == YELLOW:
                node.set('fill', secondary)
        if small:
            for parent in list(element.iter()):
                for node in list(parent):
                    if node.get('d', '').startswith('M216'):
                        parent.remove(node)
        groups.append(ET.tostring(element, encoding='unicode'))
    return '\n'.join(groups)


def wordmark(color):
    font = TTFont(ROOT / 'app/assets/fonts/BricolageGrotesque-Bold.ttf')
    glyphs = font.getGlyphSet()
    scale = 112 / font['head'].unitsPerEm
    cmap = font.getBestCmap()
    pen = SVGPathPen(glyphs, ntos=lambda value: f"{value:.2f}".rstrip("0").rstrip("."))
    x = 264.0
    for character in 'amiLudo':
        name = cmap[ord(character)]
        glyphs[name].draw(TransformPen(pen, (scale, 0, 0, -scale, x, 166)))
        x += font['hmtx'][name][0] * scale
    font.close()
    return f'<path fill="{color}" d="{pen.getCommands()}"/>', round(x + 24)


def render(source, target, size):
    cairosvg.svg2png(url=str(source), write_to=str(target),
                    output_width=size, output_height=size)


def generate():
    variants = {
        'amiludo-mark-mono.svg': master_body(INK, INK),
        'amiludo-mark-white.svg': master_body(WHITE, WHITE),
        'amiludo-mark-small.svg': master_body(small=True),
    }
    for filename, body in variants.items():
        (LOGO / filename).write_text(document(body), encoding='utf-8')
    for filename, scale, shift_x, shift_y in [
        ('amiludo-app-icon.svg', .88, 15.36, 11.36),
        ('amiludo-app-icon-maskable.svg', .64, 46.08, 42.08),
    ]:
        body = (f'<rect width="256" height="256" fill="{PURPLE}"/>\n'
                f'<g transform="translate({shift_x} {shift_y}) scale({scale})">'
                f'{master_body(WHITE, YELLOW)}</g>')
        (LOGO / filename).write_text(document(body), encoding='utf-8')
    for suffix, main, secondary, text in [
        ('', PURPLE, YELLOW, INK),
        ('-dark', WHITE, YELLOW, WHITE),
        ('-mono', INK, INK, INK),
    ]:
        lettering, width = wordmark(text)
        stem = 'amiludo-logo-horizontal' + suffix
        (LOGO / (stem + '.svg')).write_text(
            document(master_body(main, secondary) + lettering, width, 256),
            encoding='utf-8')
        cairosvg.svg2png(url=str(LOGO / (stem + '.svg')),
                        write_to=str(LOGO / (stem + '.png')),
                        output_width=width * 2, output_height=512)
    for filename in ['amiludo-mark', 'amiludo-mark-mono', 'amiludo-mark-white',
                     'amiludo-app-icon', 'amiludo-app-icon-maskable']:
        render(LOGO / (filename + '.svg'), LOGO / (filename + '.png'), 1024)
    render(LOGO / 'amiludo-mark.svg', ROOT / 'app/assets/brand/amiludo-mark.png', 512)
    favicon = LOGO / 'amiludo-favicon.svg'
    favicon.write_bytes((LOGO / 'amiludo-app-icon.svg').read_bytes())
    render(favicon, ROOT / 'app/web/favicon.png', 32)
    for size in [192, 512]:
        render(LOGO / 'amiludo-app-icon.svg',
               ROOT / f'app/web/icons/Icon-{size}.png', size)
        render(LOGO / 'amiludo-app-icon-maskable.svg',
               ROOT / f'app/web/icons/Icon-maskable-{size}.png', size)
    for density, size in [('mdpi', 48), ('hdpi', 72), ('xhdpi', 96),
                          ('xxhdpi', 144), ('xxxhdpi', 192)]:
        render(LOGO / 'amiludo-app-icon.svg',
               ROOT / f'app/android/app/src/main/res/mipmap-{density}/ic_launcher.png', size)
    folder = ROOT / 'app/ios/Runner/Assets.xcassets/AppIcon.appiconset'
    for entry in json.loads((folder / 'Contents.json').read_text())['images']:
        if 'filename' in entry:
            size = round(float(entry['size'].split('x')[0]) *
                         float(entry['scale'].rstrip('x')))
            render(LOGO / 'amiludo-app-icon.svg', folder / entry['filename'], size)
    print('Generated vector variants, outlined wordmarks and native/web PNG icons.')


if __name__ == '__main__':
    generate()
