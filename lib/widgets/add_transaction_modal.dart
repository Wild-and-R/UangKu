import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/transaction.dart';

class AddTransactionModal extends StatefulWidget {
  final Function onAdd;

  AddTransactionModal({required this.onAdd});

  @override
  _AddTransactionModalState createState() =>
      _AddTransactionModalState();
}

class _AddTransactionModalState extends State<AddTransactionModal> {
  final amountController = TextEditingController();
  String category = "Makan";

  final box = Hive.box<TransactionModel>('transactions');

  void save() {
    final amount = double.tryParse(amountController.text);

    if (amount == null) return;

    box.add(TransactionModel(
      amount: amount,
      category: category,
      date: DateTime.now(),
    ));

    widget.onAdd();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20, 
          left: 16,
          right: 16,
          top: 16,
        ),
        child: SingleChildScrollView( 
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Tambah Transaksi",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 15),

              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Nominal",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              SizedBox(height: 15),

              DropdownButtonFormField<String>(
                value: category,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: [
                  "Makan",
                  "Transport",
                  "Belanja",
                  "Tagihan",
                  "Lainnya"
                ].map((e) {
                  return DropdownMenuItem(
                    value: e,
                    child: Text(e),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    category = val!;
                  });
                },
              ),

              SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: save,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.deepPurple,
                  ),
                  child: Text("Simpan"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}