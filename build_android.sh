#! /bin/bash
cd "$(dirname "$0")"
flutter build apk --no-version-check --suppress-analytics
