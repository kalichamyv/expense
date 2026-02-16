import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:expense/screens/homepage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:expense/model/expense.dart';
import 'package:expense/calculation/expense_calculation.dart';

class StatusPage extends StatefulWidget {
  const StatusPage({super.key});

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  int _currentIndex = 1;

  late Box<Expense> expenseBox;

  final List<Widget> _pages = [MyHomePage(), StatusPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('')),
      body: _currentIndex == 1
          ? Column(children: [_totalAmount(), _barChart()])
          : _pages[_currentIndex],
    );
  }
}

Widget _totalAmount() {
  return ValueListenableBuilder(
    // it change the ui when the data change
    valueListenable: Hive.box<Expense>('expenses').listenable(),
    builder: (context, Box<Expense> box, _) {
      final income = totalIncome(box);
      final expense = totalExpense(box);
      final totalAmount = income + expense;
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Row(
          children: [
            _total(
              "totalAmount",
              '₹${totalAmount.toStringAsFixed(0)}',
              "This Month",
            ),
          ],
        ),
      );
    },
  );
}

Widget _total(String title, String amount, String subtitle) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.only(top: 18),
      margin: EdgeInsets.only(left: 60, right: 40),
      alignment: Alignment.center,
      height: 130,
      width: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          colors: [Color(0xFF43A047), Color(0xFF185A9D)],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _barChart() {
  return ValueListenableBuilder(
    valueListenable: Hive.box<Expense>('expenses').listenable(),
    builder: (context, Box<Expense> box, _) {
      final income = totalIncome(box);
      final expense = totalExpense(box);

      return Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 220,
          child: BarChart(
            BarChartData(
              barGroups: [
                BarChartGroupData(
                  x: 0,
                  barRods: [
                    BarChartRodData(
                      toY: income,
                      color: Colors.green,
                      width: 30,
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 1,
                  barRods: [
                    BarChartRodData(toY: expense, color: Colors.red, width: 30),
                  ],
                ),
              ],
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      switch (value.toInt()) {
                        case 0:
                          return const Text('Income');
                        case 1:
                          return const Text('Expense');
                      }
                      return const Text('');
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(show: false),
            ),
          ),
        ),
      );
    },
  );
}
