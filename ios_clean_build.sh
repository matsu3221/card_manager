#!/bin/bash
set -e

echo "🧹 Flutter clean..."
flutter clean

echo "📦 Flutter pub get..."
flutter pub get

echo "🧹 CocoaPods cleanup..."
cd ios
pod deintegrate
pod install
cd ..

echo "🗑️ Remove Xcode DerivedData..."
rm -rf ~/Library/Developer/Xcode/DerivedData

echo "🗑️ Remove Xcode ModuleCache..."
rm -rf ~/Library/Developer/Xcode/ModuleCache.noindex

echo "🚀 Build iOS (release)..."
flutter build ios --release

echo "✅ Done!"
