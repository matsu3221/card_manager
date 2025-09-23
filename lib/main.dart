import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'models/card_model.dart';
import 'models/allowance_model.dart';
import 'models/spend_model.dart';
import 'screens/card_list_screen.dart';
import 'screens/spend_history_screen.dart';
import 'screens/trade_card_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('🟡 main() に入ったよ');

  // Hive 初期化
  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);

  // Adapter登録
  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(CardModelAdapter());
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(AllowanceAdapter());
  if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(SpendAdapter());

  // Box 開封（try-catch で安全に）
  Box<CardModel> cardBox;
  try {
    cardBox = await Hive.openBox<CardModel>('cards');
  } catch (_) {
    await Hive.deleteBoxFromDisk('cards');
    cardBox = await Hive.openBox<CardModel>('cards');
  }

  try {
    await Hive.openBox<Allowance>('allowances');
  } catch (_) {
    await Hive.deleteBoxFromDisk('allowances');
    await Hive.openBox<Allowance>('allowances');
  }

  try {
    await Hive.openBox<Spend>('spends');
  } catch (_) {
    await Hive.deleteBoxFromDisk('spends');
    await Hive.openBox<Spend>('spends');
  }

  // 旧データマイグレーション
  await migrateOldCardData();

  runApp(MyApp()); // Box 完全開封後に実行
}

// ======================
// 旧データマイグレーション関数
// ======================
Future<void> migrateOldCardData() async {
  final box = Hive.box<CardModel>('cards');
  final dir = await getApplicationDocumentsDirectory();
  final imagesDir = Directory(path.join(dir.path, 'images'));
  if (!await imagesDir.exists()) await imagesDir.create(recursive: true);

  for (var card in box.values.toList()) {
    // 旧仕様の imagePath がフルパスでない場合のみ
    if (card.imagePath != null && !card.imagePath!.startsWith('/')) {
      final oldFile = File(path.join(dir.path, card.imagePath!));
      if (await oldFile.exists()) {
        final newPath = path.join(imagesDir.path, path.basename(oldFile.path));
        await oldFile.copy(newPath);
        card.imagePath = newPath;
        await box.put(card.id, card);
        print('🟢 Card ${card.name} の画像パスを更新: $newPath');
      } else {
        print('⚠️ Card ${card.name} の旧画像ファイルが存在しません: ${card.imagePath}');
      }
    }
  }
}

// ======================
// MyApp
// ======================
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const backgroundColor = Colors.black; // 背景黒
    const textColor = Colors.white; // 文字白
    const appBarColor = Colors.white; // AppBar白

    print('🧱 MyApp.build 実行');
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trading Card Manager',
      theme: ThemeData(
        scaffoldBackgroundColor: backgroundColor,
        fontFamily: 'Cinzel Decorative',
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          bodyMedium: TextStyle(color: textColor, fontSize: 16),
          bodyLarge: TextStyle(color: textColor, fontSize: 18),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: appBarColor,
          foregroundColor: textColor,
          titleTextStyle: TextStyle(
            fontFamily: 'Cinzel Decorative',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          iconTheme: IconThemeData(color: Colors.black),
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFF1E1E1E),
          elevation: 3,
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        listTileTheme: const ListTileThemeData(
          textColor: textColor,
          iconColor: textColor,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: appBarColor,
            foregroundColor: backgroundColor,
            textStyle: const TextStyle(
              fontSize: 16,
              fontFamily: 'Cinzel Decorative',
            ),
            iconColor: textColor,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        iconTheme: const IconThemeData(color: textColor),
      ),
      // ⭐ ここを追加
      routes: {
        '/': (context) => CardListScreen(),
        '/trade': (context) => TradeCardScreen(),
      },
    );
  }
}
