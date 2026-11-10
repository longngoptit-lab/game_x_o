#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
command -v flutter >/dev/null || { echo 'Install Flutter stable first: https://docs.flutter.dev/install'; exit 1; }
flutter pub get
flutter doctor
echo 'Ready: flutter run (offline mode; no Firebase account needed).'
