#!/bin/bash
set -e

echo "=== Flutter iOS ビルド用クリーン開始 ==="

# DerivedData の ModuleCache, Build, Session.modulevalidation を削除
echo "→ DerivedData のクリーン"
DERIVED_DATA="$HOME/Library/Developer/Xcode/DerivedData"
rm -rf "$DERIVED_DATA"/ModuleCache.noindex/*
rm -rf "$DERIVED_DATA"/Build/*
rm -f "$DERIVED_DATA"/ModuleCache.noindex/Session.modulevalidation

# SDKStatCaches を削除
echo "→ SDKStatCaches のクリーン"
rm -rf "$DERIVED_DATA"/SDKStatCaches.noindex/*

# Pods 再インストール（必要に応じて）
if [ -d "ios/Pods" ]; then
  echo "→ Pods 再インストール"
  cd ios
  pod deintegrate
  pod install
  cd ..
fi

# Flutter のキャッシュクリア
echo "→ Flutter キャッシュクリア"
flutter clean
flutter pub get

# iOS ビルド（署名不要でテストビルド）
echo "→ Flutter iOS ビルド開始"
flutter build ios --no-codesign

echo "=== クリーン & ビルド完了 ==="