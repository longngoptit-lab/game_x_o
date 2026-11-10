#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
firebase_project_id="$(python3 -c "import json; print(json.load(open('android/app/google-services.json'))['project_info']['project_id'])")"
firebase_android_app_id="$(python3 -c "import json; d=json.load(open('android/app/google-services.json')); print(next(c['client_info']['mobilesdk_app_id'] for c in d['client'] if c['client_info']['android_client_info']['package_name']=='com.longngoptit.gamexo'))")"
if [[ "$firebase_project_id" == demo-* ]]; then
  echo 'Configure your Firebase project before distributing the app.'
  exit 1
fi
flutter build apk --debug --dart-define=OFFLINE_MODE=true
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-debug.apk \
  --project "$firebase_project_id" \
  --app "$firebase_android_app_id" \
  --release-notes-file docs/RELEASE_NOTES.md
