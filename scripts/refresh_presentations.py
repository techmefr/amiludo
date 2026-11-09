"""Refresh existing player presentations with the shared amiLudo brand assets."""
from pathlib import Path
import pymupdf as fitz
from reportlab.graphics import renderSVG
from reportlab.graphics.barcode.qr import QrCodeWidget
from reportlab.graphics.shapes import Drawing

ROOT = Path(__file__).resolve().parents[1]
FOLDER = ROOT / 'docs/presentation'
LOGO = ROOT / 'design/logo'
APP_URL = 'https://techmefr.github.io/amiludo/app/'
REPO_URL = 'https://github.com/techmefr/amiludo'
PAPER = (1, 249 / 255, 239 / 255)
INK = (42 / 255, 31 / 255, 68 / 255)
PURPLE = (102 / 255, 68 / 255, 214 / 255)
MUTED = (109 / 255, 101 / 255, 128 / 255)


def vector(page, rect, source):
    data = source.read_bytes() if isinstance(source, Path) else source
    with fitz.open(stream=data, filetype='svg') as svg:
        with fitz.open(stream=svg.convert_to_pdf(), filetype='pdf') as pdf:
            page.show_pdf_page(fitz.Rect(rect), pdf, 0)


def fonts(page):
    for name, filename in [('AmiBody', 'LilGrotesk-Regular.ttf'),
                           ('AmiBold', 'BricolageGrotesque-Bold.ttf')]:
        page.insert_font(fontname=name,
                         fontfile=str(ROOT / 'app/assets/fonts' / filename))


def text(page, rect, value, size=12, font='AmiBody', color=INK):
    result = page.insert_textbox(fitz.Rect(rect), value, fontsize=size,
                                 fontname=font, color=color, lineheight=1.22)
    if result < 0:
        raise ValueError(f'Text does not fit: {value!r}')


def qr_svg():
    code = QrCodeWidget(APP_URL, barLevel='M')
    x, y, width, height = code.getBounds()
    drawing = Drawing(width, height)
    drawing.add(code)
    return renderSVG.drawToString(drawing).encode('utf-8')


def cover(doc):
    doc.delete_page(0)
    page = doc.new_page(pno=0, width=595.2756, height=841.8898)
    fonts(page)
    page.draw_rect(page.rect, color=None, fill=PAPER)
    vector(page, (38, 29, 322, 125), LOGO / 'amiludo-logo-horizontal.svg')
    text(page, (44, 146, 550, 166), 'LE COMPAGNON DE VOS SOIRÉES JEUX',
         size=10, color=PURPLE)
    text(page, (44, 182, 552, 304), 'Tous les outils.\nAutour de la table.',
         size=42, font='AmiBold')
    text(page, (44, 312, 545, 372),
         'Scores, dés, temps, équipes et personnages.\n'
         'On choisit les outils utiles à son jeu, puis on joue.', size=14, color=MUTED)
    vector(page, (44, 410, 224, 590), LOGO / 'amiludo-app-icon.svg')
    text(page, (257, 414, 550, 453), 'Un outil tout de suite', size=19, font='AmiBold')
    text(page, (257, 452, 549, 495),
         'Lancer les dés, compter les points\nou choisir qui commence.', size=12, color=MUTED)
    text(page, (257, 514, 550, 551), 'Un compagnon par jeu', size=19, font='AmiBold')
    text(page, (257, 552, 549, 600),
         'Préparer ses réglages et retrouver\nsa table à la prochaine partie.', size=12, color=MUTED)
    text(page, (44, 630, 550, 660), 'Simple à ouvrir. Amusant à personnaliser.',
         size=17, font='AmiBold')
    text(page, (44, 664, 540, 704),
         'Présentation pour les joueurs : des exemples, le catalogue cible\n'
         'et une invitation à donner un avis franc.', size=11, color=MUTED)
    page.draw_rect(fitz.Rect(44, 727, 279, 770), color=None, fill=PURPLE)
    text(page, (62, 738, 269, 766), 'Essayer amiLudo', size=15,
         font='AmiBold', color=(1, 1, 1))
    page.insert_link({'kind': fitz.LINK_URI, 'from': fitz.Rect(44, 727, 279, 770), 'uri': APP_URL})
    vector(page, (459, 711, 551, 803), qr_svg())
    text(page, (44, 791, 447, 818), 'Projet open source · Présentation joueurs · Novembre 2026',
         size=9, color=MUTED)


def refresh(path):
    doc = fitz.open(path)
    expected_pages = len(doc)
    original_text = [page.get_text() for page in doc]
    cover(doc)
    for index in range(1, len(doc)):
        page = doc[index]
        sample = page.get_pixmap(clip=fitz.Rect(19, 299, 20, 300), alpha=False)
        background = tuple(channel / 255 for channel in sample.samples[:3])
        page.add_redact_annot(fitz.Rect(40, 787, 451, 826), fill=background)
        replacements = []
        for block in page.get_text('dict')['blocks']:
            for line in block.get('lines', []):
                for span in line['spans']:
                    value = span['text']
                    if 'techmefr.github.io/ludoply' in value or 'github.com/techmefr/ludoply' in value:
                        rect = fitz.Rect(span['bbox'])
                        replacements.append((rect, value.replace('/ludoply', '/amiludo')))
                        page.add_redact_annot(rect, fill=PAPER)
        page.apply_redactions(images=0, graphics=1)
        fonts(page)
        vector(page, (40, 788, 148, 825), LOGO / 'amiludo-logo-horizontal.svg')
        text(page, (164, 800, 445, 817), 'DOCUMENT DE DISCUSSION · 07.11.2026',
             size=8, color=MUTED)
        for rect, value in replacements:
            text(page, (rect.x0, rect.y0, 551, rect.y1 + 5), value,
                 size=10.5, color=INK)
        for link in page.get_links():
            if 'uri' in link and '/ludoply' in link['uri']:
                link['uri'] = link['uri'].replace('/ludoply', '/amiludo')
                page.update_link(link)
    for page in doc:
        present = {link.get('uri') for link in page.get_links()}
        for value, uri in [('techmefr.github.io/amiludo/app/', APP_URL),
                           ('github.com/techmefr/amiludo', REPO_URL)]:
            if uri not in present:
                for rect in page.search_for(value):
                    page.insert_link({'kind': fitz.LINK_URI, 'from': rect, 'uri': uri})
    doc.set_metadata({**doc.metadata, 'title': 'amiLudo - Présentation pour les joueurs',
                      'subject': 'Outils de table, compagnons par jeu et catalogue cible'})
    if len(doc) != expected_pages:
        raise ValueError('Unexpected page count')
    for index in range(1, len(doc)):
        actual = doc[index].get_text()
        for line in original_text[index].splitlines():
            if not line.strip() or 'DOCUMENT DE DISCUSSION' in line or '/ludoply' in line:
                continue
            if line.strip() not in actual:
                raise ValueError(f'Lost content on page {index+1}: {line!r}')
    output = doc.tobytes(garbage=4, deflate=True)
    doc.close()
    path.write_bytes(output)
    print(f'Updated {path.name}: {expected_pages} pages, vector cover/footer and current links.')


if __name__ == '__main__':
    for presentation in sorted(FOLDER.glob('*.pdf')):
        refresh(presentation)
