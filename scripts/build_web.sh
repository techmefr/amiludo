#!/usr/bin/env bash
set -euo pipefail
python3 "$(dirname "$0")/build_catalog.py"
project_root="$(cd "$(dirname "$0")/.." && pwd)"
flutter_bin="${FLUTTER_BIN:-flutter}"
cd "$project_root/app"
"$flutter_bin" build web --release --no-web-resources-cdn --base-href "${APP_BASE_PATH:-/amiludo/app/}" \
  --dart-define=SUPABASE_URL="${SUPABASE_URL:-}" \
  --dart-define=SUPABASE_PUBLISHABLE_KEY="${SUPABASE_PUBLISHABLE_KEY:-}" \
  --dart-define=AMILUDO_LINK_BASE="${AMILUDO_LINK_BASE:-}"
python3 "$project_root/scripts/make_offline_cache.py" "$project_root/app/build/web"
