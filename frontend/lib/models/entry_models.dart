// Shared data models for entry creation and category

class Category {
  final int id;
  final String name;
  final String? description;

  Category({required this.id, required this.name, this.description});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }
}

class ExpenseCreate {
  final double amount;
  final String? description;
  final DateTime date;
  final List<int> categoryIds;

  ExpenseCreate({
    required this.amount,
    this.description,
    required this.date,
    required this.categoryIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'category_ids': categoryIds,
    };
  }
}

class InvestmentCreate {
  final double amount;
  final String? description;
  final DateTime date;

  InvestmentCreate({
    required this.amount,
    this.description,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
    };
  }
}

class SavingCreate {
  final double amount;
  final String? description;
  final DateTime date;

  SavingCreate({
    required this.amount,
    this.description,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
    };
  }
}

class IncomeCreate {
  final double amount;
  final String? description;
  final DateTime date;
  final String? source;

  IncomeCreate({
    required this.amount,
    this.description,
    required this.date,
    this.source,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'source': source,
    };
  }
}
