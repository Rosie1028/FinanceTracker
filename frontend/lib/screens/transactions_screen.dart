import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/entry_models.dart';
import '../services/expense_service.dart';
import '../services/income_service.dart';
import '../services/investment_and_saving_service.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  List<Expense> _expenses = [];
  List<Income> _incomes = [];
  List<Saving> _savings = [];
  List<Investment> _investments = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final expenses = await ExpenseService().fetchExpenses();
      final incomes = await IncomeService().fetchIncomes();
      final savings = await InvestmentAndSavingService().fetchSavings();
      final investments = await InvestmentAndSavingService().fetchInvestments();

      setState(() {
        _expenses = expenses;
        _incomes = incomes;
        _savings = savings;
        _investments = investments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load transactions: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<TransactionItem> get _allTransactions {
    final List<TransactionItem> transactions = [];

    // Add expenses
    for (final expense in _expenses) {
      transactions.add(TransactionItem(
        id: expense.id,
        type: TransactionType.expense,
        amount: -expense.amount, // Negative for expenses
        description: expense.description ?? 'Expense',
        date: expense.date,
        category: expense.categories.isNotEmpty
            ? expense.categories.first.name
            : 'No Category',
        data: expense,
      ));
    }

    // Add incomes
    for (final income in _incomes) {
      transactions.add(TransactionItem(
        id: income.id,
        type: TransactionType.income,
        amount: income.amount,
        description: income.source ?? 'Income',
        date: income.date,
        category: 'Income',
        data: income,
      ));
    }

    // Add savings
    for (final saving in _savings) {
      transactions.add(TransactionItem(
        id: saving.id,
        type: TransactionType.saving,
        amount: saving.amount,
        description: saving.description ?? 'Saving',
        date: saving.date,
        category: 'Saving',
        data: saving,
      ));
    }

    // Add investments
    for (final investment in _investments) {
      transactions.add(TransactionItem(
        id: investment.id,
        type: TransactionType.investment,
        amount: investment.amount,
        description: investment.description ?? 'Investment',
        date: investment.date,
        category: 'Investment',
        data: investment,
      ));
    }

    // Sort by date (newest first)
    transactions.sort((a, b) => b.date.compareTo(a.date));

    // Apply filter
    if (_selectedFilter != 'All') {
      transactions.removeWhere((transaction) {
        switch (_selectedFilter) {
          case 'Expenses':
            return transaction.type != TransactionType.expense;
          case 'Income':
            return transaction.type != TransactionType.income;
          case 'Savings':
            return transaction.type != TransactionType.saving;
          case 'Investments':
            return transaction.type != TransactionType.investment;
          default:
            return false;
        }
      });
    }

    return transactions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter dropdown
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              value: _selectedFilter,
              decoration: const InputDecoration(
                labelText: 'Filter by Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'All', child: Text('All Transactions')),
                DropdownMenuItem(value: 'Expenses', child: Text('Expenses')),
                DropdownMenuItem(value: 'Income', child: Text('Income')),
                DropdownMenuItem(value: 'Savings', child: Text('Savings')),
                DropdownMenuItem(
                    value: 'Investments', child: Text('Investments')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                });
              },
            ),
          ),
          // Transactions list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _allTransactions.isEmpty
                    ? const Center(
                        child: Text(
                          'No transactions found',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _allTransactions.length,
                        itemBuilder: (context, index) {
                          final transaction = _allTransactions[index];
                          return _buildTransactionCard(transaction);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(TransactionItem transaction) {
    final isExpense = transaction.type == TransactionType.expense;
    final color = isExpense ? Colors.red : Colors.green;
    final icon = _getTransactionIcon(transaction.type);

    return Dismissible(
      key: Key('${transaction.type}_${transaction.id}'),
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
                  'Are you sure you want to delete this ${transaction.type.name.toLowerCase()}?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        _deleteTransaction(transaction);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color),
          ),
          title: Text(
            transaction.description,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(transaction.category),
              Text(
                DateFormat('MMMM yyyy').format(transaction.date),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          trailing: Text(
            '${isExpense ? '-' : '+'}\$${transaction.amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  IconData _getTransactionIcon(TransactionType type) {
    switch (type) {
      case TransactionType.expense:
        return Icons.remove_circle;
      case TransactionType.income:
        return Icons.add_circle;
      case TransactionType.saving:
        return Icons.savings;
      case TransactionType.investment:
        return Icons.trending_up;
    }
  }

  void _deleteTransaction(TransactionItem transaction) async {
    try {
      switch (transaction.type) {
        case TransactionType.expense:
          await ExpenseService().deleteExpense(transaction.id);
          break;
        case TransactionType.income:
          await IncomeService().deleteIncome(transaction.id);
          break;
        case TransactionType.saving:
          await InvestmentAndSavingService().deleteSaving(transaction.id);
          break;
        case TransactionType.investment:
          await InvestmentAndSavingService().deleteInvestment(transaction.id);
          break;
      }

      // Refresh data after deletion
      _fetchData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete transaction: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

enum TransactionType { expense, income, saving, investment }

class TransactionItem {
  final int id;
  final TransactionType type;
  final double amount;
  final String description;
  final DateTime date;
  final String category;
  final dynamic data;

  TransactionItem({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.date,
    required this.category,
    required this.data,
  });
}
