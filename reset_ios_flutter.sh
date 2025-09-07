#!/bin/bash

set -e  # エラーが出たら即終了

echo "🧹 XcodeのDerivedDataを削除中..."
rm -rf ~/Library/Developer/Xcode/DerivedData

echo "🧼 Flutterプロジェクトのクリーンアップ..."
flutter clean

echo "📦 パッケージの再取得中..."
flutter pub get

echo "📁 iOSディレクトリへ移動..."
cd ios

echo "🗑️ PodsとPodfile.lockを削除中..."
rm -rf Pods Podfile.lock

echo "📦 CocoaPodsのインストール中..."
pod install

echo "✅ 完了しました！"
