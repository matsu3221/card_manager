#!/bin/bash
# ========================================================
# Flutter + iOS (Xcode) キャッシュ完全クリア & ビルドスクリプト
# ========================================================

set -e  # エラーで停止

echo "🚀 Starting clean & build process..."

# 1️⃣ Xcode DerivedData を丸ごと削除
echo "🧹 Cleaning Xcode DerivedData..."
rm -rf ~/Library/Developer/Xcode/DerivedData/*
rm -rf ~/Library/Developer/Xcode/DerivedData/ModuleCache.noindex/*
rm -f ~/Library/Developer/Xcode/DerivedData/Session.modulevalidation
rm -rf ~/Library/Developer/Xcode/DerivedData/SDKStatCaches.noindex/*

# 2️⃣ Flutter clean
echo "🧹 Running flutter clean..."
flutter clean

# 3️⃣ Flutter pub get
echo "📦 Fetching Flutter dependencies..."
flutter pub get

# 4️⃣ CocoaPods 再インストール
echo "📀 Reinstalling iOS pods..."
cd ios
pod deintegrate
pod install
cd ..

# 5️⃣ Flutter build iOS
echo "⚡ Building iOS app..."
flutter build ios --no-codesign

echo "✅ Cleanup & Build Complete!"