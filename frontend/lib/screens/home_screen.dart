import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/expense_service.dart';
import '../services/income_service.dart';
import '../services/investment_and_saving_service.dart';
import '../widgets/add_entry_form.dart';
import '../models/entry_models.dart';
import 'package:intl/intl.dart';
import 'settings_screen.dart';

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
  final IncomeService _incomeService = IncomeService();
  final InvestmentAndSavingService _iasService = InvestmentAndSavingService();
  List<Category> _categories = [];
  List<Expense> _expenses = [];
  List<Income> _incomes = [];
  List<Saving> _savings = [];
  List<Investment> _investments = [];
  bool _isLoading = true;
  DateTime _displayMonth = DateTime.now();
  int? _selectedCategoryId; // null means all categories
  final String _username = 'Rosangela';

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final categories = await _expenseService.fetchCategories();
      final expenses = await _expenseService.fetchExpenses();
      final incomes = await _incomeService.fetchIncomes();
      final savings = await _iasService.fetchSavings();
      final investments = await _iasService.fetchInvestments();

      // Determine display month: current month if it has data, otherwise last month with data
      final now = DateTime.now();
      final currentMonth = DateTime(now.year, now.month);

      final allMonths = [
        ...expenses.map((e) => DateTime(e.date.year, e.date.month)),
        ...incomes.map((i) => DateTime(i.date.year, i.date.month)),
        ...savings.map((s) => DateTime(s.date.year, s.date.month)),
        ...investments.map((inv) => DateTime(inv.date.year, inv.date.month)),
      ].toSet().toList();
      allMonths.sort((a, b) => b.compareTo(a));

      DateTime displayMonth = currentMonth;
      if (allMonths.isNotEmpty) {
        // If current month has no data, use the most recent month with data
        if (!allMonths.contains(currentMonth)) {
          displayMonth = allMonths.first;
        }
      } else {
        // No data at all, use last month
        displayMonth = DateTime(now.year, now.month - 1);
      }

      setState(() {
        _categories = categories;
        _expenses = expenses;
        _incomes = incomes;
        _savings = savings;
        _investments = investments;
        _displayMonth = displayMonth;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() => _isLoading = false);
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

  // Get expenses for a specific month
  List<Expense> _getExpensesForMonth(DateTime month) {
    return _expenses.where((e) {
      return e.date.year == month.year && e.date.month == month.month;
    }).toList();
  }

  // Get incomes for a specific month
  List<Income> _getIncomesForMonth(DateTime month) {
    return _incomes.where((i) {
      return i.date.year == month.year && i.date.month == month.month;
    }).toList();
  }

  // Get savings for a specific month
  List<Saving> _getSavingsForMonth(DateTime month) {
    return _savings.where((s) {
      return s.date.year == month.year && s.date.month == month.month;
    }).toList();
  }

  // Get investments for a specific month
  List<Investment> _getInvestmentsForMonth(DateTime month) {
    return _investments.where((inv) {
      return inv.date.year == month.year && inv.date.month == month.month;
    }).toList();
  }

  // Calculate total savings for a month
  double _getTotalSavings(DateTime month) {
    final savings = _getSavingsForMonth(month);
    return savings.fold(0.0, (sum, s) => sum + s.amount);
  }

  // Calculate total investments for a month
  double _getTotalInvestments(DateTime month) {
    final investments = _getInvestmentsForMonth(month);
    return investments.fold(0.0, (sum, inv) => sum + inv.amount);
  }

  // Calculate total expenses for a month (optionally filtered by category)
  double _getTotalExpenses(DateTime month, {int? categoryId}) {
    var expenses = _getExpensesForMonth(month);
    if (categoryId != null) {
      expenses = expenses.where((e) {
        return e.categories.any((c) => c.id == categoryId);
      }).toList();
    }
    return expenses.fold(0.0, (sum, e) => sum + e.amount);
  }

  // Calculate total income for a month
  double _getTotalIncome(DateTime month) {
    final incomes = _getIncomesForMonth(month);
    return incomes.fold(0.0, (sum, i) => sum + i.amount);
  }

  // Get all available months from data
  List<DateTime> _getAvailableMonths() {
    final allMonths = [
      ..._expenses.map((e) => DateTime(e.date.year, e.date.month)),
      ..._incomes.map((i) => DateTime(i.date.year, i.date.month)),
      ..._savings.map((s) => DateTime(s.date.year, s.date.month)),
      ..._investments.map((inv) => DateTime(inv.date.year, inv.date.month)),
    ].toSet().toList();
    allMonths.sort((a, b) => b.compareTo(a)); // Newest first
    return allMonths;
  }

  // Get last 3 months (in ascending order - oldest to newest)
  List<DateTime> _getLast3Months() {
    final months = <DateTime>[];
    for (int i = 2; i >= 0; i--) {
      months.add(DateTime(_displayMonth.year, _displayMonth.month - i));
    }
    return months;
  }

  // Get category color
  Color _getCategoryColor(int categoryId) {
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
    final categoryIndex = _categories.indexWhere((c) => c.id == categoryId);
    return colorList[categoryIndex % colorList.length];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('${_getGreeting()}, $_username'),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          actions: [
            IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsScreen()),
                );
              },
              tooltip: 'Settings',
            ),
          ],
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Get expenses for display month (filtered by category if selected)
    final displayExpenses = _getExpensesForMonth(_displayMonth);
    final filteredExpenses = _selectedCategoryId == null
        ? displayExpenses
        : displayExpenses.where((e) {
            return e.categories.any((c) => c.id == _selectedCategoryId);
          }).toList();

    // Calculate totals
    final totalExpenses =
        _getTotalExpenses(_displayMonth, categoryId: _selectedCategoryId);
    final totalIncome = _getTotalIncome(_displayMonth);
    final last3Months = _getLast3Months();

    // Calculate category totals for pie chart
    Map<String, double> categoryTotals = {};
    for (final expense in filteredExpenses) {
      if (expense.categories.isNotEmpty) {
        final catName = expense.categories.first.name;
        categoryTotals[catName] =
            (categoryTotals[catName] ?? 0) + expense.amount;
      }
    }

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
        title: Text(
          '${_getGreeting()}, $_username',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w300,
            fontStyle: FontStyle.italic,
            letterSpacing: 0.8,
          ),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Row(
        children: [
          // Left Sidebar
          Container(
            width: 300,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                right: BorderSide(color: colorScheme.primary.withOpacity(0.2)),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Month Selector
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Select Month',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButton<DateTime>(
                            value: _displayMonth,
                            isExpanded: true,
                            items: _getAvailableMonths().map((month) {
                              return DropdownMenuItem<DateTime>(
                                value: month,
                                child: Text(DateFormat.yMMMM().format(month)),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _displayMonth = value;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category Filter
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Filter by Category',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButton<int?>(
                            value: _selectedCategoryId,
                            isExpanded: true,
                            hint: const Text('All Categories'),
                            items: [
                              const DropdownMenuItem<int?>(
                                value: null,
                                child: Text('All Categories'),
                              ),
                              ..._categories.map((category) {
                                return DropdownMenuItem<int?>(
                                  value: category.id,
                                  child: Text(category.name),
                                );
                              }),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedCategoryId = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Current Month Totals
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Current Month Summary',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildSummaryRow(
                              'Total Expenses', totalExpenses, Colors.red),
                          const SizedBox(height: 8),
                          _buildSummaryRow(
                              'Total Earnings', totalIncome, Colors.green),
                          const SizedBox(height: 8),
                          _buildSummaryRow(
                            'Net',
                            totalIncome - totalExpenses,
                            totalIncome - totalExpenses >= 0
                                ? Colors.green
                                : Colors.red,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Main Content Area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Month Summary Title
                  Text(
                    '${DateFormat.yMMMM().format(_displayMonth)} Summary',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Pie Chart
                  if (categoryTotals.isEmpty)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.pie_chart_outline,
                            size: 64,
                            color: colorScheme.onSurface.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No expenses for this month${_selectedCategoryId != null ? ' in this category' : ''}',
                            style: TextStyle(
                              fontSize: 16,
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 300,
                            width: 300,
                            child: PieChart(
                              PieChartData(
                                sections: categoryTotals.entries.map((entry) {
                                  final color = colorList[categoryTotals.keys
                                          .toList()
                                          .indexOf(entry.key) %
                                      colorList.length];
                                  return PieChartSectionData(
                                    value: entry.value,
                                    title: '',
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
                          // Legend
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: categoryTotals.entries.map((entry) {
                              final color = colorList[categoryTotals.keys
                                      .toList()
                                      .indexOf(entry.key) %
                                  colorList.length];
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                        width: 16, height: 16, color: color),
                                    const SizedBox(width: 8),
                                    Text(
                                      entry.key,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '\$${entry.value.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: colorScheme.onSurface
                                            .withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),
                  // 3 Month Comparison Bar Chart (only when category is selected)
                  if (_selectedCategoryId != null) ...[
                    const SizedBox(height: 48),
                    Text(
                      'Last 3 Months Comparison',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                          height: 300,
                          child: _build3MonthBarChart(
                            last3Months,
                            _selectedCategoryId!,
                            colorScheme,
                          ),
                        ),
                      ),
                    ),
                  ],
                  // Earnings, Savings, Investments, Spending Comparison Bar Chart (only when no category is selected)
                  if (_selectedCategoryId == null) ...[
                    const SizedBox(height: 48),
                    Text(
                      'Earnings, Savings, Investments & Spending Comparison',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // Legend
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 24,
                              runSpacing: 8,
                              children: [
                                _buildLegendItem('Earnings', Colors.green),
                                _buildLegendItem('Savings', Colors.blue),
                                _buildLegendItem('Investments', Colors.purple),
                                _buildLegendItem('Spending', Colors.red),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 300,
                              child: _buildEarningsSavingsInvestmentsChart(
                                last3Months,
                                colorScheme,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
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

  Widget _buildEarningsSavingsInvestmentsChart(
      List<DateTime> months, ColorScheme colorScheme) {
    final maxValue = months.map((m) {
      final income = _getTotalIncome(m);
      final savings = _getTotalSavings(m);
      final investments = _getTotalInvestments(m);
      final expenses = _getTotalExpenses(m);
      return [income, savings, investments, expenses]
          .reduce((a, b) => a > b ? a : b);
    }).fold(0.0, (a, b) => a > b ? a : b);

    final barGroups = months.asMap().entries.map((entry) {
      final month = entry.value;
      final income = _getTotalIncome(month);
      final savings = _getTotalSavings(month);
      final investments = _getTotalInvestments(month);
      final expenses = _getTotalExpenses(month);

      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: income,
            color: Colors.green,
            width: 18,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
          BarChartRodData(
            toY: savings,
            color: Colors.blue,
            width: 18,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
          BarChartRodData(
            toY: investments,
            color: Colors.purple,
            width: 18,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
          BarChartRodData(
            toY: expenses,
            color: Colors.red,
            width: 18,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
        barsSpace: 4,
      );
    }).toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxValue * 1.2,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipRoundedRadius: 8,
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String label;
              switch (rodIndex) {
                case 0:
                  label = 'Earnings';
                  break;
                case 1:
                  label = 'Savings';
                  break;
                case 2:
                  label = 'Investments';
                  break;
                case 3:
                  label = 'Spending';
                  break;
                default:
                  label = '';
              }
              return BarTooltipItem(
                '$label\n\$${rod.toY.toStringAsFixed(2)}',
                TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < months.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat.yMMM().format(months[value.toInt()]),
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 70,
              interval: maxValue > 0 ? (maxValue * 1.2) / 5 : 100,
              getTitlesWidget: (value, meta) {
                if (value < 0) return const Text('');
                String formatted;
                if (value >= 1000) {
                  formatted = '\$${(value / 1000).toStringAsFixed(1)}k';
                } else {
                  formatted = '\$${value.toStringAsFixed(0)}';
                }
                return Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: Text(
                    formatted,
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.right,
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: colorScheme.onSurface.withOpacity(0.1),
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: colorScheme.onSurface.withOpacity(0.2)),
            left: BorderSide(color: colorScheme.onSurface.withOpacity(0.2)),
          ),
        ),
        barGroups: barGroups,
      ),
    );
  }

  Widget _build3MonthBarChart(
      List<DateTime> months, int categoryId, ColorScheme colorScheme) {
    final maxValue = months
        .map((m) => _getTotalExpenses(m, categoryId: categoryId))
        .fold(0.0, (a, b) => a > b ? a : b);

    final categoryColor = _getCategoryColor(categoryId);

    final barGroups = months.asMap().entries.map((entry) {
      final month = entry.value;
      final value = _getTotalExpenses(month, categoryId: categoryId);
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: value,
            color: categoryColor,
            width: 40,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxValue * 1.2, // Add 20% padding at top
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipRoundedRadius: 8,
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '\$${rod.toY.toStringAsFixed(2)}',
                TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < months.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat.yMMM().format(months[value.toInt()]),
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 70,
              interval:
                  maxValue > 0 ? (maxValue * 1.2) / 5 : 100, // Show 5 labels
              getTitlesWidget: (value, meta) {
                if (value < 0) return const Text('');
                // Format to avoid overlap: use k for thousands, otherwise show full number
                String formatted;
                if (value >= 1000) {
                  formatted = '\$${(value / 1000).toStringAsFixed(1)}k';
                } else {
                  formatted = '\$${value.toStringAsFixed(0)}';
                }
                return Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: Text(
                    formatted,
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.right,
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: colorScheme.onSurface.withOpacity(0.1),
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: colorScheme.onSurface.withOpacity(0.2)),
            left: BorderSide(color: colorScheme.onSurface.withOpacity(0.2)),
          ),
        ),
        barGroups: barGroups,
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, double amount, Color color,
      {double fontSize = 14}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: fontSize),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
