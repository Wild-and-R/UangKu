import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 0)
class TransactionModel {
  @HiveField(0)
  double amount;

  @HiveField(1)
  String category;

  @HiveField(2)
  DateTime date;

  TransactionModel({
    required this.amount,
    required this.category,
    required this.date,
  });
}