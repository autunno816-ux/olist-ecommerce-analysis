"""Validate portable documentation links, source archive integrity and publishable files."""
import hashlib
import json
from pathlib import Path
import re
import subprocess
from urllib.parse import unquote

ROOT = Path(__file__).resolve().parents[1]


def main():
    errors = []
    links = 0
    for path in ROOT.rglob('*.md'):
        if any(p in path.parts for p in ('.git', '.venv')):
            continue
        content = path.read_text(encoding='utf-8')
        for target in re.findall(r'\]\(([^)]+)\)', content):
            if target.startswith(('https://','http://','#','mailto:')):
                continue
            links += 1
            resolved = path.parent / unquote(target.split('#')[0])
            if not resolved.exists():
                errors.append(f'Broken link in {path.relative_to(ROOT)}: {target}')
    manifest = json.loads((ROOT / 'archive/manifest.json').read_text(encoding='utf-8'))
    for item in manifest:
        path = ROOT / 'archive' / item['file']
        if hashlib.sha256(path.read_bytes()).hexdigest() != item['sha256']:
            errors.append('Archive hash mismatch: ' + item['file'])
    if (ROOT / '.git').exists():
        tracked = subprocess.check_output(['git','ls-files','-z'],cwd=ROOT).decode().split('\0')
        for name in filter(None, tracked):
            p = Path(name)
            if name.startswith('data/raw/') and p.name != '.gitkeep':
                errors.append('Raw dataset is tracked: '+name)
            if p.name.startswith('.env') or p.suffix in ('.duckdb','.pem','.key') or '.venv' in p.parts:
                errors.append('Private/local file is tracked: '+name)
    if errors:
        raise SystemExit('\n'.join(errors))
    print(f'OK: {links} local document links; {len(manifest)} original artifact hashes; tracked-file policy.')


if __name__ == '__main__':
    main()
