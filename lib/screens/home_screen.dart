import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/transaction.dart';
import '../widgets/add_transaction_modal.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final box = Hive.box<TransactionModel>('transactions');

  double getTotal() {
    return box.values.fold(0, (sum, item) => sum + item.amount);
  }

  void deleteItem(int index) {
    box.deleteAt(index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final transactions = box.values.toList().reversed.toList();

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
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (_) => AddTransactionModal(onAdd: () {
              setState(() {});
            }),
          );
        },
      ),

      body: Column(
        children: [
          // HEADER CARD
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
                  color: Colors.purple.withOpacity(0.3),
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
                  "Rp ${getTotal().toStringAsFixed(0)}",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // TITLE
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Transaksi Terbaru",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          SizedBox(height: 10),

          // LIST
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

                      return Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 6),

                        child: Dismissible(
                          key: Key(item.hashCode.toString()),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => deleteItem(index),

                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(Icons.delete, color: Colors.white),
                          ),

                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ListTile(
                              title: Text(
                                "Rp ${item.amount.toStringAsFixed(0)}",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(item.category),
                            ),
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