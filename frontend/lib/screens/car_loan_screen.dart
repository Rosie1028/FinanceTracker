import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/car_loan_service.dart';
import '../models/car_loan_models.dart';
import '../widgets/add_car_loan_form.dart';
import 'package:intl/intl.dart';

class CarLoanScreen extends StatefulWidget {
  const CarLoanScreen({super.key});

  @override
  State<CarLoanScreen> createState() => _CarLoanScreenState();
}

class _CarLoanScreenState extends State<CarLoanScreen> {
  final CarLoanService _carLoanService = CarLoanService();
  List<CarLoan> _carLoans = [];
  CarLoanSummary? _summary;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);

    // Clear existing data first
    setState(() {
      _carLoans = [];
      _summary = null;
    });

    try {
      print('=== REFRESHING CAR LOAN DATA ===');
      print('Fetching car loan data...');
      final carLoans = await _carLoanService.fetchCarLoans();
      print('Car loans fetched: ${carLoans.length}');

      // Print all car loans for debugging
      for (var loan in carLoans) {
        print(
            '  ${loan.month} ${loan.year}: Balance ${loan.endingBalance}, Principal ${loan.principal}, Interest ${loan.finance}');
      }

      print('Fetching car loan summary...');
      final summary = await _carLoanService.fetchCarLoanSummary();
      print('Summary fetched: ${summary.latestBalance}');
      print('Total interest: ${summary.totalInterestPaid}');
      print('Total principal: ${summary.totalPrincipalPaid}');
      print('Total payments: ${summary.totalPayments}');

      setState(() {
        _carLoans = carLoans;
        _summary = summary;
        _isLoading = false;
      });
      print('Data loaded successfully');
    } catch (e) {
      print('Error fetching car loan data: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading car loan data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Car Loan Tracker'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _carLoans.isEmpty
              ? const Center(child: Text('No car loan data available.'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Summary Cards
                      if (_summary != null) _buildSummaryCards(),
                      const SizedBox(height: 24),

                      // Balance Over Time Chart
                      _buildBalanceChart(),
                      const SizedBox(height: 24),

                      // Payment History
                      _buildPaymentHistory(),
                      const SizedBox(height: 100), // Extra padding at bottom
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCarLoanForm,
        icon: const Icon(Icons.add),
        label: const Text('Add Payment'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Current Balance',
                '\$${_summary!.latestBalance.toStringAsFixed(2)}',
                Colors.red,
                Icons.account_balance,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                'Total Interest Paid',
                '\$${_summary!.totalInterestPaid.toStringAsFixed(2)}',
                Colors.orange,
                Icons.trending_up,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Total Principal Paid',
                '\$${_summary!.totalPrincipalPaid.toStringAsFixed(2)}',
                Colors.green,
                Icons.payments,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                'Total Payments',
                '\$${_summary!.totalPayments.toStringAsFixed(2)}',
                Colors.blue,
                Icons.attach_money,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
      String title, String value, Color color, IconData icon) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceChart() {
    // Sort loans by date
    final sortedLoans = List<CarLoan>.from(_carLoans)
      ..sort((a, b) => DateTime(a.year, _getMonthNumber(a.month))
          .compareTo(DateTime(b.year, _getMonthNumber(b.month))));

    final spots = sortedLoans.asMap().entries.map((entry) {
      final loan = entry.value;
      return FlSpot(entry.key.toDouble(), loan.endingBalance);
    }).toList();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Loan Balance Over Time',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        getTitlesWidget: (value, meta) {
                          return Text(
                              '\$${(value / 1000).toStringAsFixed(0)}k');
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < sortedLoans.length) {
                            final loan = sortedLoans[value.toInt()];
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                '${loan.month.substring(0, 3)}\n${loan.year}',
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentHistory() {
    // Sort loans by date (newest first)
    final sortedLoans = List<CarLoan>.from(_carLoans)
      ..sort((a, b) => DateTime(b.year, _getMonthNumber(b.month))
          .compareTo(DateTime(a.year, _getMonthNumber(a.month))));

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Payment History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...sortedLoans
                .map((loan) => Dismissible(
                      key: Key(loan.id.toString()),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20.0),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Confirm Delete'),
                              content: Text(
                                  'Are you sure you want to delete the payment for ${loan.month} ${loan.year}?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      onDismissed: (direction) {
                        _deleteCarLoan(loan.id);
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        child: ListTile(
                          title: Text('${loan.month} ${loan.year}'),
                          subtitle: Text(
                              'Balance: \$${loan.endingBalance.toStringAsFixed(2)}'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${loan.amountPaid.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Principal: \$${loan.principal.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.green),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ],
        ),
      ),
    );
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

  void _showAddCarLoanForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: AddCarLoanForm(
            onCarLoanAdded: _fetchData,
          ),
        );
      },
    );
  }

  void _deleteCarLoan(int id) async {
    try {
      await CarLoanService().deleteCarLoan(id);
      // Refresh data after deletion
      _fetchData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete payment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
