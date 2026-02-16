import 'package:flutter/material.dart';
import 'package:expense/model/expense.dart';
import 'package:hive/hive.dart';

class MyExpense extends StatefulWidget {
  const MyExpense({super.key});

  @override
  State<MyExpense> createState() => _MyExpenseState();
}

class _MyExpenseState extends State<MyExpense> {
  final TextEditingController _nameController = TextEditingController();
  //DateTime _selectedDate=DateTime.now();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  String type = "Expense";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade600,
        title: const Text('Add Expense', style: TextStyle(color: Colors.white)),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              // Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    gapPadding: 5,
                  ),
                  labelText: 'Enter the name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return ("name is required");
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Select date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                validator: (_) {
                  if (_selectedDate == null) {
                    return 'Select a date';
                  }
                  return null;
                },
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );

                  if (pickedDate != null) {
                    setState(() {
                      _selectedDate = pickedDate;
                    });
                    _dateController.text =
                        "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                  }
                },
              ),
              const SizedBox(height: 10),

              // Amount
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    gapPadding: 5,
                  ),
                  labelText: 'Enter the amount',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Enter valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // Type
              DropdownButtonFormField<String>(
                value: type,
                items: const [
                  DropdownMenuItem(value: 'Income', child: Text('Income')),
                  DropdownMenuItem(value: 'Expense', child: Text('Expense')),
                ],
                onChanged: (value) {
                  setState(() {
                    type = value!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Save
              SizedBox(
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      FocusScope.of(context).unfocus();
                      final Expense newExpense = Expense(
                        name: _nameController.text.trim(),
                        date: _selectedDate!,
                        amount: double.parse(_amountController.text),
                        type: type,
                      );
                      Hive.box<Expense>('expenses').add(newExpense);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
