"""Check that every exported logo and app icon matches the SVG masters."""
from pathlib import Path
import io
import json
import math
import re
import unittest
import xml.etree.ElementTree as ET

import cairosvg
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
LOGO = ROOT / 'design/logo'


class BrandAssetsTest(unittest.TestCase):
    def assert_export(self, source, target, width, height=None):
        height = width if height is None else height
        data = cairosvg.svg2png(url=str(source), output_width=width, output_height=height)
        expected = Image.open(io.BytesIO(data)).convert('RGBA')
        with Image.open(target) as image:
            self.assertEqual(image.size, (width, height), str(target))
            self.assertTrue(image.convert('RGBA').tobytes() == expected.tobytes(), str(target))

    def test_svg_masters_have_portable_filled_geometry(self):
        for path in LOGO.glob('*.svg'):
            with self.subTest(file=path.name):
                root = ET.parse(path).getroot()
                self.assertIsNotNone(root.get('viewBox'))
                for element in root.iter():
                    tag = element.tag.split('}')[-1]
                    self.assertNotIn(tag, ['mask', 'clipPath', 'filter', 'image', 'text', 'use'])
                    self.assertNotIn('stroke', element.attrib)
                self.assertTrue(any(node.tag.endswith('title') for node in root))
        self.assertNotIn('M216', (LOGO / 'amiludo-mark-small.svg').read_text())

    def test_shared_symbol_and_wordmarks(self):
        self.assert_export(LOGO / 'amiludo-mark.svg', ROOT / 'app/assets/brand/amiludo-mark.png', 512)
        for stem in ['amiludo-mark', 'amiludo-mark-mono', 'amiludo-mark-white',
                     'amiludo-app-icon', 'amiludo-app-icon-maskable']:
            self.assert_export(LOGO / (stem + '.svg'), LOGO / (stem + '.png'), 1024)
        for suffix in ['', '-dark', '-mono']:
            stem = 'amiludo-logo-horizontal' + suffix
            tree = ET.parse(LOGO / (stem + '.svg')).getroot()
            width = int(tree.get('width')) * 2
            self.assert_export(LOGO / (stem + '.svg'), LOGO / (stem + '.png'), width, 512)

    def test_native_and_web_icons(self):
        icon = LOGO / 'amiludo-app-icon.svg'
        self.assertEqual((LOGO / 'amiludo-favicon.svg').read_bytes(), icon.read_bytes())
        self.assert_export(icon, ROOT / 'app/web/favicon.png', 32)
        for size in [192, 512]:
            self.assert_export(icon, ROOT / f'app/web/icons/Icon-{size}.png', size)
            self.assert_export(LOGO / 'amiludo-app-icon-maskable.svg',
                               ROOT / f'app/web/icons/Icon-maskable-{size}.png', size)
        for density, size in [('mdpi', 48), ('hdpi', 72), ('xhdpi', 96),
                              ('xxhdpi', 144), ('xxxhdpi', 192)]:
            self.assert_export(icon,
                ROOT / f'app/android/app/src/main/res/mipmap-{density}/ic_launcher.png', size)
        folder = ROOT / 'app/ios/Runner/Assets.xcassets/AppIcon.appiconset'
        for entry in json.loads((folder / 'Contents.json').read_text())['images']:
            if 'filename' in entry:
                size = round(float(entry['size'].split('x')[0]) *
                             float(entry['scale'].rstrip('x')))
                self.assert_export(icon, folder / entry['filename'], size)
                with Image.open(folder / entry['filename']) as image:
                    self.assertNotIn('A', image.getbands(), 'iOS icon must have no alpha channel')

    def test_maskable_artwork_stays_in_the_safe_circle(self):
        with Image.open(ROOT / 'app/web/icons/Icon-maskable-512.png') as image:
            image = image.convert('RGB')
            background = image.getpixel((0, 0))
            for y in range(image.height):
                for x in range(image.width):
                    if image.getpixel((x, y)) != background:
                        self.assertLessEqual(math.hypot(x + .5 - 256, y + .5 - 256), 204.8)

    def test_documentation_logo_paths_resolve(self):
        documents = [ROOT / 'README.md', ROOT / 'app/README.md',
                     *ROOT.glob('docs/**/*.md'), LOGO / 'README.md']
        for path in documents:
            text = path.read_text()
            for name in re.findall(r'(?:src|srcset)="([^"]+)"', text):
                if 'amiludo-' in name and not name.startswith('http'):
                    self.assertTrue((path.parent / name).is_file(), f'{path}: {name}')


if __name__ == '__main__':
    unittest.main(verbosity=2)
