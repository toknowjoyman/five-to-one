#!/bin/bash
# Script to enable Flutter web support for the project

set -e

echo "Enabling Flutter web support..."

cd five_to_one_mobile

# Enable web support
flutter config --enable-web

# Create web platform files
flutter create --platforms=web .

echo "✓ Flutter web support enabled"
echo ""
echo "To test locally, run:"
echo "  cd five_to_one_mobile"
echo "  flutter run -d chrome"
echo ""
echo "To build for production:"
echo "  cd five_to_one_mobile"
echo "  flutter build web --release"
