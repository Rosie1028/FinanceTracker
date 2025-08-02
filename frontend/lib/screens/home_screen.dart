import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/expense_service.dart';
import '../widgets/add_entry_form.dart';
import '../models/entry_models.dart';
import 'package:intl/intl.dart';

const List<String> chartCategories = [
  'rent',
  'car',
  'car_insurance',
  'health_insurance',
  'groceries',
  'gas',
  'gfs',
  'education',
  'state',
  'house',
  'subscriptions',
  'gifts',
  'pets',
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ExpenseService _expenseService = ExpenseService();
  List<Category> _categories = [];
  List<Expense> _expenses = [];
  bool _isLoading = true;
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      print('Fetching categories...');
      final categories = await _expenseService.fetchCategories();
      print('Categories fetched: ${categories.length}');

      print('Fetching expenses...');
      final expenses = await _expenseService.fetchExpenses();
      print('Expenses fetched: ${expenses.length}');

      // Debug: Print some expense details
      if (expenses.isNotEmpty) {
        print(
            'First expense: ${expenses.first.amount} - ${expenses.first.categories.map((c) => c.name).join(', ')}');
      }

      // Get available months from the loaded expenses
      final availableMonths = expenses
          .map((e) => DateTime(e.date.year, e.date.month))
          .toSet()
          .toList();
      availableMonths.sort((a, b) => b.compareTo(a));

      setState(() {
        _categories = categories;
        _expenses = expenses;
        _isLoading = false;
        // Set the selected month to the most recent month with data
        if (availableMonths.isNotEmpty) {
          _selectedMonth = availableMonths.first;
        }
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() => _isLoading = false);
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  void _showAddEntrySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: AddEntryForm(
            categories: _categories,
            onExpenseAdded: _fetchData,
            onSavingAdded: _fetchData,
            onInvestmentAdded: _fetchData,
            onIncomeAdded: _fetchData,
          ),
        );
      },
    );
  }

  List<DateTime> get _availableMonths {
    final months = _expenses
        .map((e) => DateTime(e.date.year, e.date.month))
        .toSet()
        .toList();
    months.sort((a, b) => b.compareTo(a));
    return months;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Filter expenses for the selected month
    final filteredExpenses = _expenses.where((e) {
      final matches = e.date.year == _selectedMonth.year &&
          e.date.month == _selectedMonth.month;
      print(
          'Comparing: Expense date ${e.date} (${e.date.year}-${e.date.month}) vs Selected ${_selectedMonth.year}-${_selectedMonth.month} = $matches');
      return matches;
    }).toList();

    print('Selected month: ${_selectedMonth.year}-${_selectedMonth.month}');
    print('Total expenses: ${_expenses.length}');
    print('Filtered expenses for selected month: ${filteredExpenses.length}');

    // Debug: Print all expenses for the selected month
    for (final expense in filteredExpenses) {
      print(
          'Expense: ${expense.amount} - Date: ${expense.date} - Categories: ${expense.categories.map((c) => c.name).join(', ')}');
    }

    // Calculate totals for each chart category for the selected month
    Map<String, double> categoryTotals = {
      for (var c in chartCategories) c: 0.0
    };

    // Debug: Print all category names from backend
    print('Backend categories: ${_categories.map((c) => c.name).toList()}');
    print('Chart categories: $chartCategories');

    for (final expense in filteredExpenses) {
      if (expense.categories.isNotEmpty) {
        final originalCat = expense.categories.first.name;
        final cat =
            originalCat.toLowerCase().replaceAll(' ', '_').replaceAll('-', '_');
        print(
            'Processing expense: ${expense.amount} - Original category: "$originalCat" - Normalized: "$cat"');
        if (categoryTotals.containsKey(cat)) {
          categoryTotals[cat] = (categoryTotals[cat] ?? 0) + expense.amount;
          print(
              'Added ${expense.amount} to category "$cat" - Total now: ${categoryTotals[cat]}');
        } else {
          print('Category "$cat" not found in chartCategories!');
        }
      } else {
        print('Expense ${expense.amount} has no categories!');
      }
    }

    print('Final categoryTotals: $categoryTotals');

    final colorList = [
      const Color(0xFF2196F3), // Blue
      const Color(0xFF4CAF50), // Green
      const Color(0xFFFF9800), // Orange
      const Color(0xFFF44336), // Red
      const Color(0xFF9C27B0), // Purple
      const Color(0xFF00BCD4), // Cyan
      const Color(0xFFFFEB3B), // Yellow
      const Color(0xFF795548), // Brown
      const Color(0xFF607D8B), // Blue Grey
      const Color(0xFFE91E63), // Pink
      const Color(0xFF3F51B5), // Indigo
      const Color(0xFF8BC34A), // Light Green
      const Color(0xFFFF5722), // Deep Orange
      const Color(0xFF673AB7), // Deep Purple
      const Color(0xFF009688), // Teal
      const Color(0xFFCDDC39), // Lime
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finance Tracker'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: _availableMonths.isEmpty
                  ? const Text('No data available.')
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Month selector
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: DropdownButton<DateTime>(
                            value: _availableMonths.contains(_selectedMonth)
                                ? _selectedMonth
                                : _availableMonths.first,
                            items: _availableMonths.map((month) {
                              return DropdownMenuItem<DateTime>(
                                value: month,
                                child: Text(DateFormat.yMMMM().format(month)),
                              );
                            }).toList(),
                            onChanged: (month) {
                              if (month != null) {
                                setState(() {
                                  _selectedMonth = month;
                                });
                              }
                            },
                          ),
                        ),
                        if (filteredExpenses.isEmpty)
                          const Text('No data for this month.')
                        else
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Pie chart
                              SizedBox(
                                height: 300,
                                width: 300,
                                child: PieChart(
                                  PieChartData(
                                    sections: chartCategories.map((catName) {
                                      final color = colorList[
                                          chartCategories.indexOf(catName) %
                                              colorList.length];
                                      return PieChartSectionData(
                                        value: categoryTotals[catName] ?? 0,
                                        title: '', // Hide text in the slice
                                        color: color,
                                        radius: 50,
                                      );
                                    }).toList(),
                                    sectionsSpace: 2,
                                    centerSpaceRadius: 40,
                                    startDegreeOffset: -90,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 32),
                              // Vertical legend
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: chartCategories.map((catName) {
                                  final color = colorList[
                                      chartCategories.indexOf(catName) %
                                          colorList.length];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                            width: 16,
                                            height: 16,
                                            color: color),
                                        const SizedBox(width: 8),
                                        Text(
                                          catName,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          categoryTotals[catName]
                                                  ?.toStringAsFixed(2) ??
                                              '0.00',
                                          style: const TextStyle(
                                              color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                      ],
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddEntrySheet,
        icon: const Icon(Icons.add),
        label: const Text('Add Entry'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
    );
  }
}
