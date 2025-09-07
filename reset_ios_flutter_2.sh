#!/bin/bash

set -e

echo "🧹 Step 1: Flutter Clean & DerivedData 削除"
flutter clean

DERIVED_DATA_DIR=~/Library/Developer/Xcode/DerivedData
if [ -d "$DERIVED_DATA_DIR" ]; then
  rm -rf "$DERIVED_DATA_DIR"
  echo "🗑️ Xcode DerivedData 削除済み"
else
  echo "✅ Xcode DerivedData はすでに存在しません"
fi

echo "📦 Step 2: Flutter パッケージを取得（flutter pub get）"
flutter pub get

echo "🛠️ Step 3: CocoaPods 再インストール"
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..

echo "✅ 完了しました！"
