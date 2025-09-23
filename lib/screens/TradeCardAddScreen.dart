import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/purchase_model.dart';

class TradeCardAddScreen extends StatefulWidget {
  const TradeCardAddScreen({Key? key}) : super(key: key);

  @override
  _TradeCardAddScreenState createState() => _TradeCardAddScreenState();
}

class _TradeCardAddScreenState extends State<TradeCardAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  late Box<Purchase> _purchaseBox;

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  Future<void> _openBox() async {
    _purchaseBox = await Hive.openBox<Purchase>('purchases');
  }

  void _savePurchase() {
    if (!_formKey.currentState!.validate()) return;

    final purchase = Purchase(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      cardName: _nameController.text,
      price: int.parse(_priceController.text),
      date: DateTime.now(),
    );

    _purchaseBox.put(purchase.id, purchase);
    Navigator.pop(context, purchase);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('仕入れ追加')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'カード名'),
                validator: (value) =>
                    value == null || value.isEmpty ? '必須項目です' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: '仕入れ価格'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? '必須項目です' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _savePurchase, child: const Text('保存')),
            ],
          ),
        ),
      ),
    );
  }
}
