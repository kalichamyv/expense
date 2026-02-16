import 'package:hive_flutter/hive_flutter.dart';
import 'package:expense/model/expense.dart';

double totalIncome(Box<Expense> box) {
  return box.values
      .where((e) => e.type == 'Income')
      .fold(0.0, (sum, e) => sum + e.amount);
}

double totalExpense(Box<Expense> box) {
  return box.values
      .where((e) => e.type == 'Expense')
      .fold(0.0, (sum, e) => sum + e.amount);
}
