import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../models/card_model.dart';
import 'card_add_screen.dart';
import ' allowance_screen.dart';

class CardListScreen extends StatefulWidget {
  @override
  _CardListScreenState createState() => _CardListScreenState();
}

class _CardListScreenState extends State<CardListScreen>
    with SingleTickerProviderStateMixin {
  List<CardModel> _allCards = [];
  late Box<CardModel> _cardBox;
  TabController? _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _openHiveBox();
  }

  Future<void> _openHiveBox() async {
    _cardBox = await Hive.openBox<CardModel>('cards');
    _refreshCards();
  }

  Future<void> _refreshCards() async {
    setState(() {
      _allCards = _cardBox.values.toList();
    });
  }

  Future<File?> _getImageFile(String? fileName) async {
    if (fileName == null) return null;
    final dir = await getApplicationDocumentsDirectory();
    final file = File(path.join(dir.path, 'images', fileName));
    return await file.exists() ? file : null;
  }

  Future<void> _navigateToAddOrEdit(CardModel? card) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CardAddScreen(card: card)),
    );
    if (result != null && result is CardModel) {
      await _cardBox.put(result.id, result);
      await _refreshCards();
    }
  }

  List<CardModel> _filteredCards(bool wishlist) {
    return _allCards.where((c) {
      final matchesTab = wishlist ? c.isWishList : !c.isWishList;
      final matchesSearch = c.name.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      return matchesTab && matchesSearch;
    }).toList();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('カード一覧'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'カード追加',
              onPressed: () => _navigateToAddOrEdit(null),
            ),
            IconButton(
              icon: const Icon(Icons.bar_chart),
              tooltip: '統計',
              onPressed: () {
                // TODO: 統計画面への遷移
              },
            ),
            IconButton(
              icon: const Icon(Icons.savings),
              tooltip: 'お小遣い機能',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AllowanceScreen()),
                );
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: '所持カード'),
              Tab(text: 'ウィッシュリスト'),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: '検索...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildCardList(_filteredCards(false)),
                  _buildCardList(_filteredCards(true)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardList(List<CardModel> cards) {
    if (cards.isEmpty) {
      return const Center(child: Text('カードが登録されていません'));
    }
    return RefreshIndicator(
      onRefresh: _refreshCards,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        itemCount: cards.length,
        itemBuilder: (context, index) {
          final card = cards[index];
          return FutureBuilder<File?>(
            future: _getImageFile(card.imagePath),
            builder: (context, snapshot) {
              final imageFile = snapshot.data;
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [Colors.grey[200]!, Colors.grey[400]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black38,
                      blurRadius: 10,
                      offset: const Offset(4, 4),
                    ),
                  ],
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _navigateToAddOrEdit(card),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: imageFile != null
                              ? Image.file(
                                  imageFile,
                                  width: double.infinity, // 横幅いっぱい
                                  height: 250, // 高さを広めに
                                  fit: BoxFit.contain, // カードの比率を保って表示
                                )
                              : Container(
                                  width: double.infinity,
                                  height: 250,
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.image,
                                    size: 80,
                                    color: Colors.grey,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                card.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                card.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14),
                              ),
                              if (card.price != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    '¥${card.price}',
                                    style: TextStyle(
                                      color: Colors.green[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('削除確認'),
                                content: const Text('本当にこのカードを削除しますか？'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('キャンセル'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('削除'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await _cardBox.delete(card.id);
                              await _refreshCards();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
