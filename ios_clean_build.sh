#!/bin/bash
set -e

echo "=== Flutter iOS ビルド用クリーン開始 ==="

DERIVED_DATA="$HOME/Library/Developer/Xcode/DerivedData"

# DerivedData の ModuleCache, Build, Session.modulevalidation を削除
echo "→ DerivedData のクリーン"
if [ -d "$DERIVED_DATA/ModuleCache.noindex" ]; then
  rm -rf "$DERIVED_DATA/ModuleCache.noindex"/*
fi
if [ -d "$DERIVED_DATA/Build" ]; then
  rm -rf "$DERIVED_DATA/Build"/*
fi
if [ -f "$DERIVED_DATA/ModuleCache.noindex/Session.modulevalidation" ]; then
  rm -f "$DERIVED_DATA/ModuleCache.noindex/Session.modulevalidation"
fi

# SDKStatCaches の削除
SDK_CACHE="$DERIVED_DATA/SDKStatCaches.noindex"
if [ -d "$SDK_CACHE" ]; then
  echo "→ SDKStatCaches のクリーン"
  rm -rf "$SDK_CACHE"/*
else
  echo "→ SDKStatCaches が存在しません。スキップ"
fi

# Pods 再インストール（必要に応じて）
if [ -d "ios/Pods" ]; then
  echo "→ Pods 再インストール"
  cd ios
  pod deintegrate
  pod install
  cd ..
else
  echo "→ ios/Pods が存在しません。スキップ"
fi

# Flutter のキャッシュクリア
echo "→ Flutter キャッシュクリア"
flutter clean
flutter pub get

# iOS ビルド（署名不要でテストビルド）
echo "→ Flutter iOS ビルド開始"
flutter build ios --no-codesign

echo "=== クリーン & ビルド完了 ==="