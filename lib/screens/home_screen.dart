import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../widgets/add_transaction_modal.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final box = Hive.box<TransactionModel>('transactions');

  final rupiahFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  double getTotal() {
    return box.values.fold(0, (sum, item) => sum + item.amount);
  }

  void deleteItem(int index) {
    box.deleteAt(index);
    setState(() {});
  }

  IconData getCategoryIcon(String category) {
    switch (category) {
      case "Makan":
        return Icons.restaurant;
      case "Transport":
        return Icons.directions_car;
      case "Belanja":
        return Icons.shopping_bag;
      case "Tagihan":
        return Icons.receipt;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactions = box.values.toList().reversed.toList();

    return Scaffold(
      backgroundColor: Color(0xFFF5F6FA),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          "Expense Tracker",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        child: Icon(Icons.add),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            builder: (_) => AddTransactionModal(onAdd: () {
              setState(() {});
            }),
          );
        },
      ),

      body: Column(
        children: [
          // HEADER (TOTAL CARD)
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(20),
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurple,
                  Colors.purpleAccent,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Total Pengeluaran",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  rupiahFormat.format(getTotal()),
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // LIST TITLE
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Transaksi Terbaru",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          SizedBox(height: 10),

          // LIST / EMPTY STATE
          Expanded(
            child: transactions.isEmpty
                ? Center(
                    child: Text(
                      "Belum ada transaksi",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final item = transactions[index];

                      return Dismissible(
                        key: Key(item.hashCode.toString()),
                        onDismissed: (_) => deleteItem(index),
                        background: Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 20),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 5,
                              )
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor:
                                    Colors.deepPurple.withOpacity(0.1),
                                child: Icon(
                                  getCategoryIcon(item.category),
                                  color: Colors.deepPurple,
                                ),
                              ),
                              SizedBox(width: 12),

                              // TEXT
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      rupiahFormat.format(item.amount),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      item.category,
                                      style:
                                          TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),

                              // DATE
                              Text(
                                "Hari ini",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}