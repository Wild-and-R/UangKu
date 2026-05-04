import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction.dart';
import '../widgets/add_transaction_modal.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final box = Hive.box<TransactionModel>('transactions');
  final formatter = NumberFormat("#,###", "id_ID");

  final categoryConfig = {
    "Makan": {"color": Colors.orange, "icon": Icons.restaurant},
    "Transport": {"color": Colors.blue, "icon": Icons.directions_car},
    "Belanja": {"color": Colors.green, "icon": Icons.shopping_bag},
    "Tagihan": {"color": Colors.red, "icon": Icons.receipt},
    "Lainnya": {"color": Colors.purple, "icon": Icons.category},
  };

  double getTotal() {
    return box.values.fold(0, (sum, item) => sum + item.amount);
  }

  Map<String, double> getCategoryTotals() {
    Map<String, double> data = {};
    for (var item in box.values) {
      data[item.category] = (data[item.category] ?? 0) + item.amount;
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final transactions = box.values.toList().reversed.toList();
    final categoryData = getCategoryTotals();
    final total = getTotal();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("UangKu"),
        elevation: 0,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (_) => AddTransactionModal(onAdd: () {
              setState(() {});
            }),
          );
        },
      ),

      body: ListView(
        children: [
          // 💰 TOTAL CARD
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.purpleAccent],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Total Pengeluaran",
                    style: TextStyle(color: Colors.white70)),
                SizedBox(height: 10),
                Text(
                  "Rp ${formatter.format(total)}",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // 📊 CHART
          if (categoryData.isNotEmpty)
            Container(
              height: 220,
              child: PieChart(
                PieChartData(
                  sections: categoryData.entries.map((entry) {
                    final percent =
                        (entry.value / total * 100).toStringAsFixed(1);

                    return PieChartSectionData(
                      value: entry.value,
                      title: "$percent%",
                      color: categoryConfig[entry.key]!["color"]
                          as Color,
                      radius: 70,
                      titleStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

          // 🧾 LEGEND
          if (categoryData.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 12,
                runSpacing: 8,
                children: categoryData.entries.map((entry) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 6,
                        backgroundColor: categoryConfig[entry.key]![
                            "color"] as Color,
                      ),
                      SizedBox(width: 6),
                      Text(entry.key),
                    ],
                  );
                }).toList(),
              ),
            ),

          SizedBox(height: 15),

          // TITLE
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Transaksi Terbaru",
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          SizedBox(height: 10),

          // LIST
          ...transactions.asMap().entries.map((entry) {
            int index = entry.key;
            var item = entry.value;

            final realIndex = box.length - 1 - index;

            return Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Dismissible(
                key: Key(index.toString()),
                direction: DismissDirection.endToStart,
                onDismissed: (_) {
                  box.deleteAt(realIndex);
                  setState(() {});
                },
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(Icons.delete, color: Colors.white),
                ),

                // 💳 CARD STYLE FINTECH
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            categoryConfig[item.category]!["color"]
                                as Color,
                        child: Icon(
                          categoryConfig[item.category]!["icon"]
                              as IconData,
                          color: Colors.white,
                        ),
                      ),

                      SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.category,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Rp ${formatter.format(item.amount)}",
                              style: TextStyle(
                                  color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}