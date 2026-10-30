from pathlib import Path
import hashlib,json,sys
root=Path(sys.argv[1]).resolve()
files=sorted(p for p in root.rglob('*') if p.is_file() and p.name!='offline-worker.js' and p.suffix!='.map')
version=hashlib.sha256(b''.join(p.read_bytes() for p in files)).hexdigest()[:16]
paths=[p.relative_to(root).as_posix() for p in files]
worker="""const CACHE='companion-VERSION';
const FILES=FILES_JSON;
self.addEventListener('install',event=>event.waitUntil(caches.open(CACHE).then(cache=>cache.addAll(FILES)).then(()=>self.skipWaiting())));
self.addEventListener('activate',event=>event.waitUntil(caches.keys().then(keys=>Promise.all(keys.filter(key=>key.startsWith('companion-')&&key!==CACHE).map(key=>caches.delete(key)))).then(()=>self.clients.claim())));
self.addEventListener('fetch',event=>{const request=event.request;if(request.method!=='GET'||new URL(request.url).origin!==self.location.origin)return;event.respondWith(caches.open(CACHE).then(async cache=>{const match=await cache.match(request,{ignoreSearch:true});if(match)return match;try{return await fetch(request);}catch(error){if(request.mode==='navigate')return await cache.match('index.html');throw error;}}));});
""".replace('VERSION',version).replace('FILES_JSON',json.dumps(paths))
(root/'offline-worker.js').write_text(worker)
print(f'Offline cache: {len(paths)} files, version {version}')
