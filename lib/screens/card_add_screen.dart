import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../models/card_model.dart';

class CardAddScreen extends StatefulWidget {
  final CardModel? card;

  const CardAddScreen({Key? key, this.card}) : super(key: key);

  @override
  _CardAddScreenState createState() => _CardAddScreenState();
}

class _CardAddScreenState extends State<CardAddScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController priceController;
  late TextEditingController sourceController;
  bool isWishList = false;
  File? _imageFile;
  String? _tempImagePath;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.card?.name ?? '');
    descriptionController = TextEditingController(
      text: widget.card?.description ?? '',
    );
    priceController = TextEditingController(
      text: widget.card?.price?.toString() ?? '',
    );
    sourceController = TextEditingController(
      // ⭐ 初期化（編集時に既存値を入れる）
      text: widget.card?.source ?? '',
    );
    isWishList = widget.card?.isWishList ?? false;

    // 既存カードの画像ファイルを読み込む
    if (widget.card?.imagePath != null) {
      _loadExistingImage(widget.card!.imagePath!);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    sourceController.dispose(); // ⭐ dispose 追加
    super.dispose();
  }

  Future<void> _loadExistingImage(String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(path.join(dir.path, 'images', path.basename(fileName)));
    if (await file.exists()) {
      setState(() {
        _imageFile = file;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // ⭐ 画像は「images フォルダへコピーしてファイル名を返す」実装に統一
  Future<String?> _saveImage(File image) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(path.join(dir.path, 'images'));

      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final fileName = path.basename(image.path);
      final savedPath = path.join(imagesDir.path, fileName);
      await image.copy(savedPath);

      return fileName; // ファイル名のみ返す
    } catch (e) {
      print('画像保存エラー: $e');
      return null;
    }
  }

  void _saveCard() async {
    if (!_formKey.currentState!.validate()) return;

    String? imagePath = widget.card?.imagePath;

    // 新しい画像が選択された場合だけ保存
    if (_imageFile != null) {
      imagePath = await _saveImage(_imageFile!);
    }

    final card = CardModel(
      id: widget.card?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: nameController.text,
      description: descriptionController.text,
      price: priceController.text.isNotEmpty
          ? int.parse(priceController.text)
          : null,
      imagePath: imagePath, // ← ファイル名のみ保存
      isWishList: isWishList,
      source: sourceController.text.isNotEmpty ? sourceController.text : null,
    );

    Navigator.pop(context, card);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.card != null ? 'カード編集' : 'カード追加')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: _imageFile != null
                    ? Image.file(
                        _imageFile!,
                        width: double.infinity, // 横幅いっぱい
                        height: 250, // 高さも広めに
                        fit: BoxFit.contain, // カード比率を保つ
                      )
                    : Container(
                        width: double.infinity,
                        height: 250,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, size: 80),
                      ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'カード名'),
                validator: (value) =>
                    value == null || value.isEmpty ? '必須項目です' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: '説明'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(labelText: '価格'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              // ⭐ 入手先フィールドを復活
              TextFormField(
                controller: sourceController,
                decoration: const InputDecoration(
                  labelText: '入手先 (例: ヤフオク、店舗名など)',
                ),
                maxLines: 1,
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                title: const Text('ウィッシュリストに追加'),
                value: isWishList,
                onChanged: (val) {
                  setState(() {
                    isWishList = val ?? false;
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _saveCard, child: const Text('保存')),
            ],
          ),
        ),
      ),
    );
  }
}
