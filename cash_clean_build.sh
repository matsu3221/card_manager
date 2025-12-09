#!/bin/bash
set -e

echo "=== Flutter & Xcode 完全クリーン & iOSビルド開始 ==="

# 1. Xcodeを終了
echo "→ Xcodeを終了してください（手動で）"

# 2. DerivedData の完全削除
echo "→ DerivedData を削除"
DERIVED_DATA="$HOME/Library/Developer/Xcode/DerivedData"
if [ -d "$DERIVED_DATA" ]; then
    rm -rf "$DERIVED_DATA"
    echo "Deleted DerivedData"
else
    echo "DerivedData は存在しません"
fi

# 3. Flutter キャッシュ削除
echo "→ Flutter キャッシュ削除"
flutter clean
flutter pub get

# 4. Pods の完全削除と再インストール
if [ -d "ios" ]; then
    echo "→ Pods を再構築"
    cd ios
    if [ -f "Podfile.lock" ]; then
        pod deintegrate
        rm -rf Pods Podfile.lock
        echo "Pods & Podfile.lock を削除"
    fi
    pod install
    cd ..
else
    echo "ios ディレクトリが存在しません"
fi

# 5. iOSビルド（署名不要テスト用）
echo "→ Flutter iOS ビルド開始（--no-codesign）"
flutter build ios --no-codesign

echo "=== 完全クリーン & ビルド完了 ==="