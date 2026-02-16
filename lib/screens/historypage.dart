import 'package:flutter/material.dart';
import 'package:expense/screens/homepage.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
 int _currentIndex =2;
// final TextEditingController _nameController =TextEditingController();

 final List<Widget>_pages=[ HistoryPage()];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text(''),
        ),
        body: _currentIndex == 2
         ? Column(children: [_searchBar(),_historyPage()],):_pages[_currentIndex]
      ),
    );
  }
}

Widget _searchBar(){
  return Expanded(
    child: Column(
    children: [
      Container(
        margin: EdgeInsets.only(right: 10,top: 5),
        padding: EdgeInsets.only(top: 15,right: 10),
        height: 10,
        width: 15,
        ),
    TextField(
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6),),
  suffixIcon: Icon(Icons.search),
  label: Text('Search'),
        ),
      ),
    ],
    ),
  );
}

Widget _historyPage(){
  return Column(
    children: [
      Container(
        padding: EdgeInsets.symmetric(vertical: 100),
        child: Text('this page shows all your income and expense history which wa also deleted by the user'),
      ),
    ],
  );
}