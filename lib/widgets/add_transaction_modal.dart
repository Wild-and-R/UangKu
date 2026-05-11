import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import '../models/transaction.dart';

class AddTransactionModal extends StatefulWidget {
  final Function onAdd;
  final TransactionModel? transaction;
  final int? transactionIndex;

  AddTransactionModal({
    required this.onAdd,
    this.transaction,
    this.transactionIndex,
  });

  @override
  _AddTransactionModalState createState() =>
      _AddTransactionModalState();
}

class _AddTransactionModalState
    extends State<AddTransactionModal> {
  final amountController = TextEditingController();
  final descController = TextEditingController();

  final formatter = NumberFormat("#,###", "id_ID");

  String category = "Makan";
  DateTime selectedDate = DateTime.now();

  final box = Hive.box<TransactionModel>('transactions');

  @override
  void initState() {
    super.initState();

    // EDIT MODE
    if (widget.transaction != null) {
      final item = widget.transaction!;

      amountController.text =
          formatter.format(item.amount);

      descController.text = item.description;

      category = item.category;
      selectedDate = item.date;
    }
  }

  void formatCurrency(String value) {
    value = value.replaceAll(".", "");

    if (value.isEmpty) {
      amountController.clear();
      return;
    }

    final number = int.parse(value);

    amountController.text =
        formatter.format(number);

    amountController.selection =
        TextSelection.fromPosition(
      TextPosition(
        offset: amountController.text.length,
      ),
    );
  }

  Future pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void save() {
    final raw =
        amountController.text.replaceAll(".", "");

    final amount = double.tryParse(raw);

    if (amount == null) return;

    final transaction = TransactionModel(
      amount: amount,
      category: category,
      date: selectedDate,
      description: descController.text,
    );

    // UPDATE
    if (widget.transactionIndex != null) {
      box.putAt(widget.transactionIndex!, transaction);
    }

    // ADD
    else {
      box.add(transaction);
    }

    widget.onAdd();

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom:
              MediaQuery.of(context).viewInsets.bottom +
                  20,
          left: 16,
          right: 16,
          top: 16,
        ),

        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                widget.transaction == null
                    ? "Tambah Transaksi"
                    : "Edit Transaksi",

                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 15),

              // NOMINAL
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,

                onChanged: formatCurrency,

                decoration: InputDecoration(
                  labelText: "Nominal",
                  prefixText: "Rp ",

                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                ),
              ),

              SizedBox(height: 15),

              //  DESKRIPSI
              TextField(
                controller: descController,

                decoration: InputDecoration(
                  labelText: "Deskripsi",

                  hintText:
                      "Contoh: Restoran X",

                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                ),
              ),

              SizedBox(height: 15),

              //  DATE
              GestureDetector(
                onTap: pickDate,

                child: Container(
                  width: double.infinity,

                  padding: EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 12,
                  ),

                  decoration: BoxDecoration(
                    border:
                        Border.all(color: Colors.grey),

                    borderRadius:
                        BorderRadius.circular(10),
                  ),

                  child: Text(
                    DateFormat('dd MMM yyyy')
                        .format(selectedDate),
                  ),
                ),
              ),

              SizedBox(height: 15),

              // CATEGORY
              DropdownButtonFormField<String>(
                value: category,

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

                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                ),
              ),

              SizedBox(height: 20),

              SizedBox(
                width: double.infinity,

                child: ElevatedButton(
                  onPressed: save,

                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.deepPurple,

                    padding: EdgeInsets.symmetric(
                        vertical: 14),
                  ),

                  child: Text(
                    widget.transaction == null
                        ? "Simpan"
                        : "Update",

                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}