import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/purchase_model.dart';
import 'TradeCardAddScreen.dart';
import 'dart:io';

class TradeCardScreen extends StatefulWidget {
  @override
  _TradeCardScreenState createState() => _TradeCardScreenState();
}

class _TradeCardScreenState extends State<TradeCardScreen> {
  late Box<Purchase> _purchaseBox;
  List<Purchase> _purchases = [];

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  Future<void> _openBox() async {
    _purchaseBox = await Hive.openBox<Purchase>('purchases');
    setState(() {
      _purchases = _purchaseBox.values.toList();
    });
  }

  Future<void> _refresh() async {
    setState(() {
      _purchases = _purchaseBox.values.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('仕入れ管理')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView.builder(
          itemCount: _purchases.length,
          itemBuilder: (context, index) {
            final p = _purchases[index];
            return ListTile(
              leading: p.imagePath != null
                  ? Image.file(
                      File(p.imagePath!),
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.image_not_supported),
              title: Text(p.cardName),
              subtitle: Text(
                '仕入れ: ¥${p.price} '
                '推奨: ¥${(p.price * 2).toInt()}\n'
                '出品先: ${p.listingSite} '
                '売却: ${p.isSold ? "済" : "未"} '
                '日付: ${p.date.toLocal().toString().split(' ')[0]}',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  await _purchaseBox.delete(p.id);
                  await _refresh();
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TradeCardAddScreen()),
          );
          if (result != null) {
            _refresh();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
