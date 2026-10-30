import json
import re
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

class PublishedCacheTest(unittest.TestCase):
    def test_cache_excludes_files_omitted_by_pages_artifact(self):
        with tempfile.TemporaryDirectory() as temp:
            root=Path(temp)
            (root/'index.html').write_text('<html>app</html>')
            (root/'main.dart.js').write_text('console.log(1)')
            (root/'.last_build_id').write_text('internal build identifier')
            (root/'main.dart.js.map').write_text('{}')
            subprocess.run([sys.executable,str(Path(__file__).with_name('make_offline_cache.py')),str(root)],check=True,capture_output=True)
            source=(root/'offline-worker.js').read_text()
            files=json.loads(re.search(r'const FILES=(\[.*?\]);',source).group(1))
            self.assertEqual(set(files),{'index.html','main.dart.js'})
            self.assertIn("cache.match('index.html')",source)
if __name__=='__main__':unittest.main()
