// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:path_provider/path_provider.dart';
// import 'models/card_model.dart';
// import 'models/allowance_model.dart';
// import 'models/spend_model.dart';
// import 'screens/card_list_screen.dart';
// import 'screens/spend_history_screen.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   print('🟡 main() に入ったよ');

//   final appDocumentDir = await getApplicationDocumentsDirectory();
//   Hive.init(appDocumentDir.path);

//   // Adapter登録
//   if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(CardModelAdapter());
//   if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(AllowanceAdapter());
//   if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(SpendAdapter());

//   // Box開封（try-catchで安全に）
//   try {
//     await Hive.openBox<CardModel>('cards');
//   } catch (_) {
//     await Hive.deleteBoxFromDisk('cards');
//     await Hive.openBox<CardModel>('cards');
//   }

//   try {
//     await Hive.openBox<Allowance>('allowances');
//   } catch (_) {
//     await Hive.deleteBoxFromDisk('allowances');
//     await Hive.openBox<Allowance>('allowances');
//   }

//   try {
//     await Hive.openBox<Spend>('spends');
//   } catch (_) {
//     await Hive.deleteBoxFromDisk('spends');
//     await Hive.openBox<Spend>('spends');
//   }

//   runApp(MyApp()); // Box 完全開封後に実行
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     const backgroundColor = Colors.black; // ← 背景を黒に
//     const textColor = Colors.white; // ← 本文は白でコントラストを確保
//     const appBarColor = Colors.white; // ← ヘッダーを白にークブラウン

//     print('🧱 MyApp.build 実行');
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Trading Card Manager',
//       theme: ThemeData(
//         // ⭐ 変更: 背景色をオレンジ系に統一
//         scaffoldBackgroundColor: backgroundColor,

//         // ⭐ 変更: テキストテーマを茶色基調に統一
//         fontFamily: 'Cinzel Decorative',
//         textTheme: const TextTheme(
//           titleLarge: TextStyle(
//             color: textColor,
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//           bodyMedium: TextStyle(color: textColor, fontSize: 16),
//           bodyLarge: TextStyle(color: textColor, fontSize: 18),
//         ),

//         // ⭐ 変更: AppBarも茶色系に
//         appBarTheme: const AppBarTheme(
//           backgroundColor: appBarColor,
//           foregroundColor: textColor,
//           titleTextStyle: TextStyle(
//             fontFamily: 'Cinzel Decorative',
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//             color: Colors.black,
//           ),
//           iconTheme: IconThemeData(color: Colors.black),
//         ),

//         // ⭐ 変更: カードも背景と調和する色に
//         cardTheme: const CardThemeData(
//           color: Color(0xFF1E1E1E),
//           elevation: 3,
//           margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.all(Radius.circular(12)),
//           ),
//         ),

//         // ⭐ 変更: ListTile の文字・アイコン色も統一
//         listTileTheme: const ListTileThemeData(
//           textColor: textColor,
//           iconColor: textColor,
//         ),

//         // ⭐ 変更: ボタンの背景と文字色も調整
//         elevatedButtonTheme: ElevatedButtonThemeData(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: appBarColor,
//             foregroundColor: backgroundColor,
//             textStyle: const TextStyle(
//               fontSize: 16,
//               fontFamily: 'Cinzel Decorative',
//             ),
//             iconColor: textColor,
//             shape: const RoundedRectangleBorder(
//               borderRadius: BorderRadius.all(Radius.circular(12)),
//             ),
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           ),
//         ),
//         iconTheme: const IconThemeData(color: textColor),
//       ),
//       home: CardListScreen(),
//     );
//   }
// }
