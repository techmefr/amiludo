#!/usr/bin/env bash
set -euo pipefail
python3 "$(dirname "$0")/build_catalog.py"
project_root="$(cd "$(dirname "$0")/.." && pwd)"
flutter_bin="${FLUTTER_BIN:-flutter}"
cd "$project_root/app"
"$flutter_bin" build web --release --no-web-resources-cdn --base-href "${APP_BASE_PATH:-/amiludo/app/}"
python3 "$project_root/scripts/make_offline_cache.py" "$project_root/app/build/web"
