// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import '../models/card_model.dart';
// import 'package:path/path.dart' as path;
// import 'package:path_provider/path_provider.dart';
// import 'package:hive/hive.dart';

// class CardAddScreen extends StatefulWidget {
//   final CardModel? card;
//   CardAddScreen({this.card});

//   @override
//   _CardAddScreenState createState() => _CardAddScreenState();
// }

// class _CardAddScreenState extends State<CardAddScreen> {
//   final _nameController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final _priceController = TextEditingController();
//   final _sourceController = TextEditingController();

//   File? _imageFile;
//   String? _imagePath;
//   late Box<CardModel> _cardBox;

//   @override
//   void initState() {
//     super.initState();
//     _cardBox = Hive.box<CardModel>('cards');

//     if (widget.card != null) {
//       _nameController.text = widget.card!.name;
//       _descriptionController.text = widget.card!.description;
//       _imagePath = widget.card!.imagePath;
//       if (_imagePath != null) _loadImageIfExists();
//       if (widget.card!.price != null) {
//         _priceController.text = widget.card!.price.toString();
//       }
//       _sourceController.text = widget.card!.source ?? '';
//     }
//   }

//   Future<void> _loadImageIfExists() async {
//     final dir = await getApplicationDocumentsDirectory();
//     final file = File(path.join(dir.path, 'images', _imagePath!));
//     if (await file.exists()) {
//       setState(() => _imageFile = file);
//     }
//   }

//   Future<void> _pickImage(ImageSource source) async {
//     final picked = await ImagePicker().pickImage(source: source);
//     if (picked == null) return;

//     final dir = await getApplicationDocumentsDirectory();
//     final imageDir = Directory(path.join(dir.path, 'images'));
//     if (!await imageDir.exists()) await imageDir.create(recursive: true);

//     // 既存パスがある場合はそのまま上書き。無ければ新規作成
//     final ext = path.extension(picked.path);
//     if (_imagePath == null) {
//       _imagePath =
//           'card_image_${widget.card?.id ?? DateTime.now().millisecondsSinceEpoch}$ext';
//     }
//     final savedPath = path.join(imageDir.path, _imagePath!);

//     // 上書き保存
//     final savedFile = File(savedPath);
//     if (await savedFile.exists()) await savedFile.delete();
//     await File(picked.path).copy(savedPath);

//     // ⭐️画像キャッシュを明示的に破棄（同じパスでも新しいバイトを読ませる）
//     await FileImage(File(savedPath)).evict();

//     setState(() {
//       _imageFile = File(savedPath);
//       // _imagePath はそのまま
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(widget.card == null ? 'カード追加' : 'カード編集')),
//       body: Padding(
//         padding: EdgeInsets.all(16),
//         child: ListView(
//           children: [
//             TextField(
//               controller: _nameController,
//               decoration: InputDecoration(labelText: 'カード名'),
//             ),
//             TextField(
//               controller: _descriptionController,
//               decoration: InputDecoration(labelText: '説明'),
//               maxLines: 3,
//             ),
//             SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ElevatedButton(
//                   onPressed: () => _pickImage(ImageSource.camera),
//                   child: Text('カメラ'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () => _pickImage(ImageSource.gallery),
//                   child: Text('ギャラリー'),
//                 ),
//               ],
//             ),
//             if (_imageFile != null)
//               Padding(
//                 padding: EdgeInsets.symmetric(vertical: 16),
//                 child: Image.file(
//                   _imageFile!,
//                   // ⭐️Key変更ではキャッシュは壊れませんが、Widget再構築の補助になります
//                   key: ValueKey(
//                     '${_imageFile!.path}_${DateTime.now().millisecondsSinceEpoch}',
//                   ),
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             TextField(
//               controller: _priceController,
//               decoration: InputDecoration(labelText: '金額（円）'),
//               keyboardType: TextInputType.number,
//             ),
//             TextField(
//               controller: _sourceController,
//               decoration: InputDecoration(labelText: '入手先'),
//             ),
//             SizedBox(height: 50),
//             ElevatedButton(
//               onPressed: () async {
//                 if (_nameController.text.isEmpty) {
//                   ScaffoldMessenger.of(
//                     context,
//                   ).showSnackBar(SnackBar(content: Text('カード名は必須です')));
//                   return;
//                 }
//                 if (_imagePath == null) {
//                   ScaffoldMessenger.of(
//                     context,
//                   ).showSnackBar(SnackBar(content: Text('画像が選択されていません')));
//                   return;
//                 }

//                 if (widget.card == null) {
//                   // 新規
//                   final newCard = CardModel(
//                     id: DateTime.now().toString(),
//                     name: _nameController.text,
//                     description: _descriptionController.text,
//                     imagePath: _imagePath,
//                     price: int.tryParse(_priceController.text),
//                     source: _sourceController.text,
//                   );
//                   await _cardBox.put(newCard.id, newCard);

//                   // ⭐️一覧に戻る前に、保存先パスのキャッシュを破棄（戻り先でも最新を読ませる）
//                   final appDir = await getApplicationDocumentsDirectory();
//                   final abs = path.join(appDir.path, 'images', _imagePath!);
//                   await FileImage(File(abs)).evict(); // ←重要

//                   Navigator.pop(context, newCard);
//                 } else {
//                   // ⭐️編集：finalフィールドなので直接代入せず copyWith で新インスタンスを作る
//                   final updatedCard = widget.card!.copyWith(
//                     name: _nameController.text,
//                     description: _descriptionController.text,
//                     imagePath: _imagePath, // 新しい画像を選んでいなければ元の値
//                     price: int.tryParse(_priceController.text),
//                     source: _sourceController.text,
//                   );

//                   await _cardBox.put(updatedCard.id, updatedCard);

//                   // ⭐️戻る前に画像キャッシュを破棄して一覧・詳細で即時反映
//                   final appDir = await getApplicationDocumentsDirectory();
//                   final abs = path.join(
//                     appDir.path,
//                     'images',
//                     updatedCard.imagePath!,
//                   );
//                   await FileImage(File(abs)).evict(); // ←重要

//                   Navigator.pop(context, updatedCard);
//                 }
//               },
//               child: Text(widget.card == null ? '登録' : '保存'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
