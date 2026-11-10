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
# FlutterFire updates the Xcode project through Ruby's xcodeproj gem.
# Prefer Homebrew Ruby on macOS; keep missing gems in the user's gem directory.
if ! ruby -e "require 'xcodeproj'" >/dev/null 2>&1; then
  if command -v brew >/dev/null; then
    firebase_ruby_bin="$(brew --prefix ruby)/bin"
    if [ -x "$firebase_ruby_bin/ruby" ]; then
      export PATH="$firebase_ruby_bin:$PATH"
    fi
  fi
  if ! ruby -e "require 'xcodeproj'" >/dev/null 2>&1; then
    gem install --user-install xcodeproj --no-document
  fi
fi
ruby -e "require 'xcodeproj'" >/dev/null || {
  echo 'Install the xcodeproj Ruby gem before configuring iOS.'
  exit 1
}
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
url_types = [entry for entry in info.get('CFBundleURLTypes', [])
             if not any(s.startswith('com.googleusercontent.apps.')
                        for s in entry.get('CFBundleURLSchemes', []))]
if google.get('REVERSED_CLIENT_ID'):
    url_types.append({'CFBundleTypeRole': 'Editor', 'CFBundleURLSchemes': [google['REVERSED_CLIENT_ID']]})
if url_types:
    info['CFBundleURLTypes'] = url_types
else:
    info.pop('CFBundleURLTypes', None)
if google.get('CLIENT_ID'):
    info['GIDClientID'] = google['CLIENT_ID']
else:
    info.pop('GIDClientID', None)
path.write_bytes(plistlib.dumps(info, sort_keys=False))
PY
echo 'Configuration generated. Follow docs/FIREBASE.md to enable Auth, database rules and App Check.'
echo 'Connected run: flutter run --dart-define=OFFLINE_MODE=false'
