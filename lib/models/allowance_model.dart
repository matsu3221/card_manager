import 'package:hive/hive.dart';

part 'allowance_model.g.dart'; // ← 自動生成ファイルのリンク

@HiveType(typeId: 1)
class Allowance extends HiveObject {
  @HiveField(0)
  DateTime date; // ← String ではなく DateTime 型に！

  @HiveField(1)
  int amount;

  Allowance({required this.date, required this.amount});
}
