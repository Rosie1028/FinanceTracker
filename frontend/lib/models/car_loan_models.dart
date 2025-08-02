class CarLoan {
  final int id;
  final String month;
  final int year;
  final double principalBalance;
  final double payoffBalance;
  final double amountPaid;
  final double principal;
  final double finance;
  final double endingBalance;
  final double? interestYtd;

  CarLoan({
    required this.id,
    required this.month,
    required this.year,
    required this.principalBalance,
    required this.payoffBalance,
    required this.amountPaid,
    required this.principal,
    required this.finance,
    required this.endingBalance,
    this.interestYtd,
  });

  factory CarLoan.fromJson(Map<String, dynamic> json) {
    return CarLoan(
      id: json['id'],
      month: json['month'],
      year: json['year'],
      principalBalance: json['principal_balance'].toDouble(),
      payoffBalance: json['payoff_balance'].toDouble(),
      amountPaid: json['amount_paid'].toDouble(),
      principal: json['principal'].toDouble(),
      finance: json['finance'].toDouble(),
      endingBalance: json['ending_balance'].toDouble(),
      interestYtd: json['interest_ytd']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'month': month,
      'year': year,
      'principal_balance': principalBalance,
      'payoff_balance': payoffBalance,
      'amount_paid': amountPaid,
      'principal': principal,
      'finance': finance,
      'ending_balance': endingBalance,
      'interest_ytd': interestYtd,
    };
  }
}

class CarLoanSummary {
  final double latestBalance;
  final double totalInterestPaid;
  final double totalPrincipalPaid;
  final double totalPayments;

  CarLoanSummary({
    required this.latestBalance,
    required this.totalInterestPaid,
    required this.totalPrincipalPaid,
    required this.totalPayments,
  });

  factory CarLoanSummary.fromJson(Map<String, dynamic> json) {
    return CarLoanSummary(
      latestBalance: json['latest_balance'].toDouble(),
      totalInterestPaid: json['total_interest_paid'].toDouble(),
      totalPrincipalPaid: json['total_principal_paid'].toDouble(),
      totalPayments: json['total_payments'].toDouble(),
    );
  }
}
