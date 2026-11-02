"""Build the public catalogue from reviewed pack files."""
import json
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
def build():
    packs=[]
    for path in sorted((ROOT/'community/packs').glob('*.json')):
        doc=json.loads(path.read_text(encoding='utf-8'))
        if doc.get('format')!='table-companion-template' or doc.get('version')!=1:
            raise ValueError(f'Invalid format: {path.name}')
        pack=doc['template']
        if not pack.get('author','').strip() or not pack.get('license','').strip():
            raise ValueError(f'Missing author or license: {path.name}')
        packs.append(pack)
    if len({p['id'] for p in packs})!=len(packs):
        raise ValueError('Duplicate pack IDs')
    payload=json.dumps({'format':'table-companion-catalog','version':1,'packs':packs},ensure_ascii=False,indent=2)+'\n'
    for name in ['prototype/community/catalog.json','app/assets/community/catalog.json']:
        dest=ROOT/name
        dest.parent.mkdir(parents=True,exist_ok=True)
        dest.write_text(payload,encoding='utf-8')
    print(f'Catalogue: {len(packs)} packs')
if __name__=='__main__':
    build()
