#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
project_id="${1:?Usage: bash scripts/configure_firebase.sh YOUR_FIREBASE_PROJECT_ID}"
command -v firebase >/dev/null || npm install --global firebase-tools
dart pub global activate flutterfire_cli
if ! firebase projects:list --json >/dev/null 2>&1; then
  firebase login
  echo 'Finish the browser login (and firebase login AUTHORIZATION_CODE if requested), then rerun this script.'
  exit 1
fi
dart pub global run flutterfire_cli:flutterfire configure \
  --project="$project_id" \
  --platforms=android,ios \
  --android-package-name=com.longngoptit.gamexo \
  --ios-bundle-id=com.longngoptit.gamexo \
  --out=lib/firebase_options.dart --yes
python3 - "$project_id" <<'PY'
import json, plistlib, sys
from pathlib import Path
Path('.firebaserc').write_text(json.dumps({'projects': {'default': sys.argv[1]}}, indent=2) + '\n')
google = plistlib.loads(Path('ios/Runner/GoogleService-Info.plist').read_bytes())
path = Path('ios/Runner/Info.plist')
info = plistlib.loads(path.read_bytes())
if google.get('REVERSED_CLIENT_ID'):
    info['CFBundleURLTypes'] = [{'CFBundleTypeRole': 'Editor', 'CFBundleURLSchemes': [google['REVERSED_CLIENT_ID']]}]
if google.get('CLIENT_ID'):
    info['GIDClientID'] = google['CLIENT_ID']
path.write_bytes(plistlib.dumps(info, sort_keys=False))
PY
echo 'Configuration generated. Follow docs/FIREBASE.md to enable Auth, database rules and App Check.'
echo 'Connected run: flutter run --dart-define=OFFLINE_MODE=false'
