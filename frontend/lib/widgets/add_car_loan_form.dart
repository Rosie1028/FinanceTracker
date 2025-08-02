import 'package:flutter/material.dart';
import '../services/car_loan_service.dart';

class AddCarLoanForm extends StatefulWidget {
  final VoidCallback onCarLoanAdded;

  const AddCarLoanForm({
    super.key,
    required this.onCarLoanAdded,
  });

  @override
  State<AddCarLoanForm> createState() => _AddCarLoanFormState();
}

class _AddCarLoanFormState extends State<AddCarLoanForm> {
  final _formKey = GlobalKey<FormState>();
  final _carLoanService = CarLoanService();

  String _selectedMonth = 'January';
  int _selectedYear = DateTime.now().year;
  final _principalBalanceController = TextEditingController();
  final _payoffBalanceController = TextEditingController();
  final _amountPaidController = TextEditingController();
  final _principalController = TextEditingController();
  final _financeController = TextEditingController();
  final _endingBalanceController = TextEditingController();
  final _interestYtdController = TextEditingController();

  bool _isLoading = false;

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
    _principalBalanceController.dispose();
    _payoffBalanceController.dispose();
    _amountPaidController.dispose();
    _principalController.dispose();
    _financeController.dispose();
    _endingBalanceController.dispose();
    _interestYtdController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final carLoanData = {
        'month': _selectedMonth,
        'year': _selectedYear,
        'principal_balance': double.parse(_principalBalanceController.text),
        'payoff_balance': double.parse(_payoffBalanceController.text),
        'amount_paid': double.parse(_amountPaidController.text),
        'principal': double.parse(_principalController.text),
        'finance': double.parse(_financeController.text),
        'ending_balance': double.parse(_endingBalanceController.text),
        'interest_ytd': _interestYtdController.text.isNotEmpty
            ? double.parse(_interestYtdController.text)
            : null,
      };

      await _carLoanService.createCarLoan(carLoanData);

      if (mounted) {
        Navigator.pop(context);
        widget.onCarLoanAdded();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Car loan payment added successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding car loan payment: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add Car Loan Payment',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Month and Year
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedMonth,
                    decoration: const InputDecoration(
                      labelText: 'Month',
                      border: OutlineInputBorder(),
                    ),
                    items: _months.map((month) {
                      return DropdownMenuItem(
                        value: month,
                        child: Text(month),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedMonth = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedYear,
                    decoration: const InputDecoration(
                      labelText: 'Year',
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(10, (index) {
                      final year = DateTime.now().year - 5 + index;
                      return DropdownMenuItem(
                        value: year,
                        child: Text(year.toString()),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        _selectedYear = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Principal Balance
            TextFormField(
              controller: _principalBalanceController,
              decoration: const InputDecoration(
                labelText: 'Principal Balance',
                border: OutlineInputBorder(),
                prefixText: '\$',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter principal balance';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Payoff Balance
            TextFormField(
              controller: _payoffBalanceController,
              decoration: const InputDecoration(
                labelText: 'Payoff Balance',
                border: OutlineInputBorder(),
                prefixText: '\$',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter payoff balance';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Amount Paid
            TextFormField(
              controller: _amountPaidController,
              decoration: const InputDecoration(
                labelText: 'Amount Paid',
                border: OutlineInputBorder(),
                prefixText: '\$',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter amount paid';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Principal and Finance (Interest)
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _principalController,
                    decoration: const InputDecoration(
                      labelText: 'Principal',
                      border: OutlineInputBorder(),
                      prefixText: '\$',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter principal';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _financeController,
                    decoration: const InputDecoration(
                      labelText: 'Interest',
                      border: OutlineInputBorder(),
                      prefixText: '\$',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter interest';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Ending Balance
            TextFormField(
              controller: _endingBalanceController,
              decoration: const InputDecoration(
                labelText: 'Ending Balance',
                border: OutlineInputBorder(),
                prefixText: '\$',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter ending balance';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Interest YTD (Optional)
            TextFormField(
              controller: _interestYtdController,
              decoration: const InputDecoration(
                labelText: 'Interest YTD (Optional)',
                border: OutlineInputBorder(),
                prefixText: '\$',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton(
              onPressed: _isLoading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Add Car Loan Payment'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
