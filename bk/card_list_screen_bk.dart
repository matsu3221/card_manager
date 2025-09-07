// import 'package:flutter/material.dart';
// import '../models/card_model.dart';
// import 'dart:io';
// import 'card_add_screen.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart' as path;
// import 'package:hive/hive.dart';
// import ' allowance_screen.dart';

// class CardListScreen extends StatefulWidget {
//   @override
//   _CardListScreenState createState() => _CardListScreenState();
// }

// class _CardListScreenState extends State<CardListScreen> {
//   List<CardModel> _cards = [];
//   List<CardModel> _filteredCards = [];
//   late Box<CardModel> _cardBox;
//   bool _isSearching = false;
//   final TextEditingController _searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _openHiveBox();
//   }

//   Future<void> _openHiveBox() async {
//     _cardBox = await Hive.openBox<CardModel>('cards');
//     _refreshCards();
//   }

//   Future<void> _refreshCards() async {
//     setState(() {
//       _cards = _cardBox.values.toList();
//       _filteredCards = List.from(_cards);
//     });
//   }

//   Future<File?> _getImageFile(String? fileName) async {
//     if (fileName == null) return null;
//     final dir = await getApplicationDocumentsDirectory();
//     final file = File(path.join(dir.path, 'images', fileName));
//     return await file.exists() ? file : null;
//   }

//   Future<void> _navigateToAddOrEdit(CardModel? card) async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => CardAddScreen(card: card)),
//     );
//     if (result != null && result is CardModel) {
//       await _cardBox.put(result.id, result);
//       await _refreshCards();
//     }
//   }

//   void _startSearch() {
//     setState(() {
//       _isSearching = true;
//       _filteredCards = List.from(_cards);
//     });
//   }

//   void _stopSearch() {
//     setState(() {
//       _isSearching = false;
//       _searchController.clear();
//       _filteredCards = List.from(_cards);
//     });
//   }

//   void _applySearch(String query) {
//     final lowerQuery = query.toLowerCase();
//     setState(() {
//       _filteredCards = _cards.where((card) {
//         return card.name.toLowerCase().contains(lowerQuery) ||
//             card.description.toLowerCase().contains(lowerQuery);
//       }).toList();
//     });
//   }

//   PreferredSizeWidget _buildAppBar() {
//     if (_isSearching) {
//       return AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: _stopSearch,
//         ),
//         title: TextField(
//           controller: _searchController,
//           autofocus: true,
//           decoration: const InputDecoration(
//             hintText: 'カードを検索...',
//             border: InputBorder.none,
//             hintStyle: TextStyle(color: Colors.white54),
//           ),
//           style: const TextStyle(color: Colors.white),
//           onChanged: _applySearch,
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.clear),
//             onPressed: () {
//               _searchController.clear();
//               _applySearch('');
//             },
//           ),
//         ],
//       );
//     } else {
//       return AppBar(
//         title: const Text('カード一覧'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.search),
//             tooltip: '検索',
//             onPressed: _startSearch,
//           ),
//           IconButton(
//             icon: const Icon(Icons.add),
//             tooltip: 'カード追加',
//             onPressed: () => _navigateToAddOrEdit(null),
//           ),
//           IconButton(
//             icon: const Icon(Icons.bar_chart),
//             tooltip: '統計',
//             onPressed: () {
//               // TODO: 統計画面への遷移を追加
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.savings),
//             tooltip: 'お小遣い機能',
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => AllowanceScreen()),
//               );
//             },
//           ),
//         ],
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: _buildAppBar(),
//       body: RefreshIndicator(
//         onRefresh: _refreshCards,
//         child: _filteredCards.isEmpty
//             ? const Center(child: Text('カードが登録されていません'))
//             : ListView.builder(
//                 padding: const EdgeInsets.symmetric(
//                   vertical: 12,
//                   horizontal: 16,
//                 ),
//                 itemCount: _filteredCards.length,
//                 itemBuilder: (context, index) {
//                   final card = _filteredCards[index];
//                   return FutureBuilder<File?>(
//                     future: _getImageFile(card.imagePath),
//                     builder: (context, snapshot) {
//                       final imageFile = snapshot.data;
//                       return Container(
//                         margin: const EdgeInsets.symmetric(vertical: 8),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(16),
//                           gradient: LinearGradient(
//                             colors: [Colors.grey[200]!, Colors.grey[400]!],
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                           ),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black38,
//                               blurRadius: 10,
//                               offset: const Offset(4, 4),
//                             ),
//                           ],
//                         ),
//                         child: InkWell(
//                           borderRadius: BorderRadius.circular(16),
//                           onTap: () => _navigateToAddOrEdit(card),
//                           child: Padding(
//                             padding: const EdgeInsets.all(12),
//                             child: Row(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 ClipRRect(
//                                   borderRadius: BorderRadius.circular(12),
//                                   child: imageFile != null
//                                       ? Image.file(
//                                           imageFile,
//                                           width: 70,
//                                           height: 70,
//                                           fit: BoxFit.cover,
//                                           key: ValueKey(
//                                             '${card.imagePath}_${DateTime.now().millisecondsSinceEpoch}',
//                                           ),
//                                         )
//                                       : Container(
//                                           width: 70,
//                                           height: 70,
//                                           color: Colors.grey[300],
//                                           child: const Icon(
//                                             Icons.image_not_supported,
//                                             color: Colors.grey,
//                                           ),
//                                         ),
//                                 ),
//                                 const SizedBox(width: 12),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         card.name,
//                                         style: const TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 18,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 4),
//                                       Text(
//                                         card.description,
//                                         maxLines: 2,
//                                         overflow: TextOverflow.ellipsis,
//                                         style: const TextStyle(fontSize: 14),
//                                       ),
//                                       if (card.price != null)
//                                         Padding(
//                                           padding: const EdgeInsets.only(
//                                             top: 4,
//                                           ),
//                                           child: Text(
//                                             '¥${card.price}',
//                                             style: TextStyle(
//                                               color: Colors.green[700],
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                         ),
//                                     ],
//                                   ),
//                                 ),
//                                 IconButton(
//                                   icon: const Icon(
//                                     Icons.delete,
//                                     color: Colors.red,
//                                   ),
//                                   onPressed: () async {
//                                     final confirm = await showDialog<bool>(
//                                       context: context,
//                                       builder: (_) => AlertDialog(
//                                         title: const Text('削除確認'),
//                                         content: const Text('本当にこのカードを削除しますか？'),
//                                         actions: [
//                                           TextButton(
//                                             onPressed: () =>
//                                                 Navigator.pop(context, false),
//                                             child: const Text('キャンセル'),
//                                           ),
//                                           TextButton(
//                                             onPressed: () =>
//                                                 Navigator.pop(context, true),
//                                             child: const Text('削除'),
//                                           ),
//                                         ],
//                                       ),
//                                     );
//                                     if (confirm == true) {
//                                       await _cardBox.delete(card.id);
//                                       await _refreshCards();
//                                     }
//                                   },
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//       ),
//     );
//   }
// }
