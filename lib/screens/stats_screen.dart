import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/card_model.dart';

class StatsScreen extends StatelessWidget {
  final List<CardModel> cards;

  const StatsScreen({Key? key, required this.cards})
    : super(key: key); // ← super(key) 大事！

  @override
  Widget build(BuildContext context) {
    // print('📈 StatsScreenに入りました。カード数: ${cards.length}');
    // print('🧭 StatsScreen build: cards.length = ${cards.length}');
    final totalAmount = cards.fold<double>(
      0,
      (sum, card) => sum + (card.price ?? 0),
    );

    return Scaffold(
      appBar: AppBar(title: Text('統計情報')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: totalAmount == 0
            ? Center(child: Text('登録された金額がありません'))
            : Column(
                children: [
                  Text(
                    '総額: ¥${totalAmount.toStringAsFixed(0)}',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 32),

                  // ① 円グラフ表示
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sections: cards.where((c) => (c.price ?? 0) > 0).map((
                          card,
                        ) {
                          final price = card.price ?? 0;
                          final percent = price / totalAmount * 100;

                          print('🟡 表示対象カード:');
                          cards.where((c) => (c.price ?? 0) > 0).forEach((c) {
                            print('- ${c.name}: ¥${c.price}');
                          });

                          return PieChartSectionData(
                            value: price.toDouble(), // ← 修正ここ！
                            title: '${percent.toStringAsFixed(0)}%', // カード名なし
                            radius: 60,
                            titleStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                    ),
                  ),

                  SizedBox(height: 32),

                  // ② 折れ線グラフ追加
                  SizedBox(
                    height: 200, // グラフの高さ
                    child: LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            spots: cards
                                .asMap()
                                .entries
                                .where((entry) => entry.value.price != null)
                                .map((entry) {
                                  int index = entry.key;
                                  double price = entry.value.price!.toDouble();
                                  return FlSpot(index.toDouble(), price);
                                })
                                .toList(),
                            isCurved: true,
                            barWidth: 3,
                            color: Colors.blue, // ← ここを colors から color に変更
                            dotData: FlDotData(show: true),
                          ),
                        ],
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                int index = value.toInt();
                                if (index < 0 || index >= cards.length)
                                  return Container();
                                return Text(
                                  cards[index].name,
                                  style: TextStyle(fontSize: 10),
                                );
                              },
                              interval: 1,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1000,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
