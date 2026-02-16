import 'package:flutter/material.dart';
import 'package:expense/model/expense.dart';
import 'package:expense/screens/second.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:expense/screens/statusbar.dart';
import 'package:expense/screens/historypage.dart';
import 'package:expense/screens/settingpage.dart';
import 'package:expense/calculation/expense_calculation.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String typeFilter = 'All';
  String timeFilter = 'All time';

  late Box<Expense> expenseBox;
  final now = DateTime.now();

  int _currentIndex = 0;

  final List<Widget> _pages = [
    MyHomePage(),
    StatusPage(),
    HistoryPage(),
    SettingPage(),
  ];

  @override
  void initState() {
    super.initState();
    expenseBox = Hive.box<Expense>('expenses');
    //expenseBox.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: _buildAppBar(),
      body: _currentIndex == 0
          ? Column(children: [_summaryCards(), _filters(), _expenseList()])
          : _pages[_currentIndex],

      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(side: BorderSide(color: Colors.green)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MyExpense()),
          );
        },
        backgroundColor: Colors.green.shade600,
        elevation: 10,
        child: const Icon(Icons.add, size: 40, color: Colors.white),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.green,
        type: BottomNavigationBarType.fixed,

        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Status'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Setting'),
        ],
      ),
    );
  }

  Widget _summaryCards() {
    return ValueListenableBuilder(  // it change the ui when the data change
      valueListenable: Hive.box<Expense>('expenses').listenable(),
      builder: (context, Box<Expense> box, _) {
        final income = totalIncome(box);
        final expense = totalExpense(box);
        {
          if (income == 0 && expense == 0) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No data available',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _card('Income', '₹ ${income.toStringAsFixed(0)}', 'This Month'),
                _card(
                    'Expense', '₹ ${expense.toStringAsFixed(0)}', 'This Month'),
              ],
            ),
          );
        }
        }
    );
  }

  Widget _card(String title, String amount, String subtitle) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(
          horizontal: 10,
        ), // decerating the summary cards and values inside the cards
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFF43A047), Color(0xFF185A9D), Color(0xFF43A047)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              amount,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
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

  Widget _filters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          _dropdown(
            value: typeFilter,
            items: ['All', 'Income', 'Expense'],
            onChanged: (value) {
              setState(() => typeFilter = value!);// the options may not be null
            },
          ),
          const SizedBox(width: 8),
          _dropdown(
            value: timeFilter,
            items: ['All time', 'This month', 'This week'],
            onChanged: (value) {
              setState(() => timeFilter = value!);
            },
          ),
        ],
      ),
    );
  }

  Widget _dropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        icon: const Icon(Icons.keyboard_arrow_down),
        items: items
            .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _expenseList() {
    return Expanded(
      child: ValueListenableBuilder(
        valueListenable: Hive.box<Expense>('expenses').listenable(),
        builder: (context, Box<Expense> box, _) {
          if (box.isEmpty) {
            return const Center(child: Text('No expenses added'));
          }

          final List<Expense> filteredList = box.values.where((e) {
            final DateTime expenseDate = e.date;

            // TYPE FILTER
            if (typeFilter != 'All' && e.type != typeFilter) {
              return false;
            }

            // TIME FILTER
            if (timeFilter == 'This month') {
              return expenseDate.month == now.month &&
                  expenseDate.year == now.year;
            }

            if (timeFilter == 'This week') {
              final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
              return expenseDate.isAfter(startOfWeek);
            }

            return true; // All time
          }).toList();

          if (filteredList.isEmpty) {
            return const Center(child: Text('No data for selected filter'));
          }

          return ListView.builder(
            itemCount: filteredList.length,
            itemBuilder: (context, index) {
              final e = filteredList[index];

              final bool isIncome = e.type == 'Income';
              final Color amountColor = isIncome ? Colors.green : Colors.red;
              final String symbol = isIncome ? '+' : '-';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: ListTile(
                  title: Text(
                    e.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${e.date.day}/${e.date.month}/${e.date.year}'),
                      Text(
                        e.type,
                        style: TextStyle(
                          color: amountColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  trailing: Text(
                    '$symbol ₹${e.amount.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: amountColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    String title = "Expense Tracker";
    switch (_currentIndex) {
      case 0:
        title = "Expense Tracker";
        break;
      case 1:
        title = "Status";
        break;
      case 2:
        title = "History";
        break;
      case 3:
        title = "Setting";
        break;
    }
    return AppBar(
      backgroundColor: Colors.green.shade600,
      title: Row(
        children: [
          Icon(Icons.menu, color: Colors.white, size: 25),
          SizedBox(width: 5),
          Text(title, style: TextStyle(color: Colors.white)),
          Spacer(),
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyExpense()),
              );
            },
          ),
        ],
      ),
    );
  }
}

//Icons.add, size: 25, color: Colors.white
