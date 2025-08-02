import 'package:flutter/material.dart';
import '../models/entry_models.dart';
import '../services/expense_service.dart';
import '../services/investment_and_saving_service.dart';
import '../services/income_service.dart';

class AddEntryForm extends StatefulWidget {
  final List<Category> categories;
  final VoidCallback onExpenseAdded;
  final VoidCallback onSavingAdded;
  final VoidCallback onInvestmentAdded;
  final VoidCallback onIncomeAdded;

  const AddEntryForm({
    super.key,
    required this.categories,
    required this.onExpenseAdded,
    required this.onSavingAdded,
    required this.onInvestmentAdded,
    required this.onIncomeAdded,
  });

  @override
  State<AddEntryForm> createState() => _AddEntryFormState();
}

enum EntryType { expense, saving, investment, income }

class _AddEntryFormState extends State<AddEntryForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _sourceController = TextEditingController();
  Category? _selectedCategory;
  String _selectedMonth = 'January';
  int _selectedYear = DateTime.now().year;
  EntryType _selectedType = EntryType.expense;

  final ExpenseService _expenseService = ExpenseService();
  final InvestmentAndSavingService _iasService = InvestmentAndSavingService();
  final IncomeService _incomeService = IncomeService();

  final List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _sourceController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Create date from month and year (first day of the month)
        final selectedDate =
            DateTime(_selectedYear, _getMonthNumber(_selectedMonth), 1);

        switch (_selectedType) {
          case EntryType.expense:
            final newExpense = ExpenseCreate(
              amount: double.parse(_amountController.text),
              description: _descriptionController.text.isEmpty
                  ? null
                  : _descriptionController.text,
              date: selectedDate,
              categoryIds:
                  _selectedCategory != null ? [_selectedCategory!.id] : [],
            );
            await _expenseService.createExpense(newExpense);
            widget.onExpenseAdded();
            break;
          case EntryType.saving:
            final newSaving = SavingCreate(
              amount: double.parse(_amountController.text),
              description: _descriptionController.text.isEmpty
                  ? null
                  : _descriptionController.text,
              date: selectedDate,
            );
            await _iasService.createSaving(newSaving);
            widget.onSavingAdded();
            break;
          case EntryType.investment:
            final newInvestment = InvestmentCreate(
              amount: double.parse(_amountController.text),
              description: _descriptionController.text.isEmpty
                  ? null
                  : _descriptionController.text,
              date: selectedDate,
            );
            await _iasService.createInvestment(newInvestment);
            widget.onInvestmentAdded();
            break;
          case EntryType.income:
            final newIncome = IncomeCreate(
              amount: double.parse(_amountController.text),
              description: _descriptionController.text.isEmpty
                  ? null
                  : _descriptionController.text,
              date: selectedDate,
              source: _sourceController.text.isEmpty
                  ? null
                  : _sourceController.text,
            );
            await _incomeService.createIncome(newIncome);
            widget.onIncomeAdded();
            break;
        }

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Entry added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error adding entry: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  int _getMonthNumber(String month) {
    const months = {
      'January': 1,
      'February': 2,
      'March': 3,
      'April': 4,
      'May': 5,
      'June': 6,
      'July': 7,
      'August': 8,
      'September': 9,
      'October': 10,
      'November': 11,
      'December': 12
    };
    return months[month] ?? 1;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add New Entry',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<EntryType>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'Type'),
                items: const [
                  DropdownMenuItem(
                    value: EntryType.expense,
                    child: Text('Expense'),
                  ),
                  DropdownMenuItem(
                    value: EntryType.saving,
                    child: Text('Saving'),
                  ),
                  DropdownMenuItem(
                    value: EntryType.investment,
                    child: Text('Investment'),
                  ),
                  DropdownMenuItem(
                    value: EntryType.income,
                    child: Text('Income'),
                  ),
                ],
                onChanged: (type) {
                  setState(() {
                    _selectedType = type!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration:
                    const InputDecoration(labelText: 'Description (Optional)'),
              ),
              if (_selectedType == EntryType.expense) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<Category>(
                  decoration: const InputDecoration(labelText: 'Category'),
                  value: _selectedCategory,
                  items: widget.categories.map((category) {
                    return DropdownMenuItem<Category>(
                      value: category,
                      child: Text(category.name),
                    );
                  }).toList(),
                  onChanged: (category) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  validator: (value) {
                    if (widget.categories.isNotEmpty && value == null) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                ),
              ],
              if (_selectedType == EntryType.income) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _sourceController,
                  decoration:
                      const InputDecoration(labelText: 'Source (Optional)'),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedMonth,
                      decoration: const InputDecoration(labelText: 'Month'),
                      items: _months.map((month) {
                        return DropdownMenuItem<String>(
                          value: month,
                          child: Text(month),
                        );
                      }).toList(),
                      onChanged: (month) {
                        setState(() {
                          _selectedMonth = month!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedYear,
                      decoration: const InputDecoration(labelText: 'Year'),
                      items: [
                        DropdownMenuItem<int>(
                          value: DateTime.now().year,
                          child: Text(DateTime.now().year.toString()),
                        ),
                      ],
                      onChanged: (year) {
                        setState(() {
                          _selectedYear = year!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Save Entry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
