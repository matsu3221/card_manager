import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
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
  final TextEditingController _otherSiteController = TextEditingController();

  late Box<Purchase> _purchaseBox;

  String _listingSite = 'メルカリ';
  File? _imageFile;
  bool _isSold = false;

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  Future<void> _openBox() async {
    _purchaseBox = await Hive.openBox<Purchase>('purchases');
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _saveImage(File image) async {
    final dir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(path.join(dir.path, 'purchase_images'));
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${path.basename(image.path)}';
    final savedFile = await image.copy(path.join(imagesDir.path, fileName));
    return savedFile.path;
  }

  void _savePurchase() async {
    if (!_formKey.currentState!.validate()) return;

    String? imagePath;
    if (_imageFile != null) {
      imagePath = await _saveImage(_imageFile!);
    }

    final purchase = Purchase(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      cardName: _nameController.text,
      price: int.parse(_priceController.text),
      date: DateTime.now(),
      imagePath: imagePath,
      listingSite: _listingSite == 'その他'
          ? _otherSiteController.text
          : _listingSite,
      isSold: _isSold,
    );

    await _purchaseBox.put(purchase.id, purchase);
    Navigator.pop(context, purchase);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('仕入れカード追加')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // カード名
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'カード名'),
                  validator: (value) =>
                      value == null || value.isEmpty ? '必須項目です' : null,
                ),
                const SizedBox(height: 12),
                // 仕入れ価格
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: '仕入れ価格'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return '必須項目です';
                    if (int.tryParse(value) == null) return '数字で入力してください';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                // 画像選択
                Row(
                  children: [
                    _imageFile != null
                        ? Image.file(
                            _imageFile!,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, size: 40),
                          ),
                    const SizedBox(width: 12),
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () => _pickImage(ImageSource.camera),
                          child: const Text('カメラ'),
                        ),
                        ElevatedButton(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          child: const Text('ギャラリー'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // 出品先
                DropdownButtonFormField<String>(
                  value: _listingSite,
                  items: ['メルカリ', 'PayPayフリマ', 'その他']
                      .map(
                        (site) =>
                            DropdownMenuItem(value: site, child: Text(site)),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _listingSite = value;
                      });
                    }
                  },
                  decoration: const InputDecoration(labelText: '出品先'),
                ),
                if (_listingSite == 'その他')
                  TextFormField(
                    controller: _otherSiteController,
                    decoration: const InputDecoration(labelText: '出品先（その他）'),
                    validator: (value) {
                      if (_listingSite == 'その他' &&
                          (value == null || value.isEmpty)) {
                        return '入力してください';
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 12),
                // 売却済み
                CheckboxListTile(
                  value: _isSold,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _isSold = value;
                      });
                    }
                  },
                  title: const Text('売却済み'),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _savePurchase,
                  child: const Text('保存'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
