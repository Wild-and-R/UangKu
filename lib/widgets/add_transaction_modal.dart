import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
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

  double parseRupiah(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^0-9]'), '');
    return double.tryParse(cleaned) ?? 0;
  }

  void save() {
    final amount = parseRupiah(amountController.text);

    if (amount <= 0) return;

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
    final formatter = NumberFormat("#,###", "id_ID");

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Nominal",
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              final number = parseRupiah(value);
              final formatted = formatter.format(number);

              amountController.value = TextEditingValue(
                text: formatted,
                selection:
                    TextSelection.collapsed(offset: formatted.length),
              );
            },
          ),

          SizedBox(height: 12),

          DropdownButtonFormField<String>(
            value: category,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
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

          SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: save,
              child: Text("Simpan"),
            ),
          )
        ],
      ),
    );
  }
}