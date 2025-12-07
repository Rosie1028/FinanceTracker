import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/entry_models.dart';

// Assuming your backend is running on http://localhost:8000
const String baseUrl = 'http://127.0.0.1:8000';

class ExpenseService {
  // Fetch all categories
  Future<List<Category>> fetchCategories() async {
    print('Making request to: $baseUrl/categories/');
    final response = await http.get(Uri.parse('$baseUrl/categories/'));
    print('Categories response status: ${response.statusCode}');
    print('Categories response body: ${response.body}');

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      print('Parsed categories: $jsonResponse');
      return jsonResponse
          .map((category) => Category.fromJson(category))
          .toList();
    } else {
      throw Exception(
          'Failed to load categories: ${response.statusCode} - ${response.body}');
    }
  }

  // Add a new expense
  Future<Expense> createExpense(ExpenseCreate expense) async {
    print('Creating expense: ${expense.toJson()}');
    final response = await http.post(
      Uri.parse('$baseUrl/expenses/'),
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(expense.toJson()),
    );
    print('Create expense response status: ${response.statusCode}');
    print('Create expense response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Expense.fromJson(json.decode(response.body));
    } else {
      throw Exception(
          'Failed to create expense: ${response.statusCode} - ${response.body}');
    }
  }

  // Fetch expenses (with limit to get all records)
  Future<List<Expense>> fetchExpenses() async {
    print('Making request to: $baseUrl/expenses/');
    final response = await http.get(Uri.parse('$baseUrl/expenses/?limit=1000'));
    print('Expenses response status: ${response.statusCode}');
    print('Expenses fetched: ${json.decode(response.body).length}');

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((expense) => Expense.fromJson(expense)).toList();
    } else {
      throw Exception(
          'Failed to load expenses: ${response.statusCode} - ${response.body}');
    }
  }

  // Delete an expense
  Future<void> deleteExpense(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/expenses/$id'));

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete expense: ${response.statusCode}');
    }
  }

  // Create a new category
  Future<Category> createCategory(String name, {String? description}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/categories/'),
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        if (description != null) 'description': description,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Category.fromJson(json.decode(response.body));
    } else {
      throw Exception(
          'Failed to create category: ${response.statusCode} - ${response.body}');
    }
  }

  // Delete a category
  Future<void> deleteCategory(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/categories/$id'));

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete category: ${response.statusCode}');
    }
  }
}

class Expense {
  final int id;
  final double amount;
  final String? description;
  final DateTime date;
  final List<Category> categories;

  Expense({
    required this.id,
    required this.amount,
    this.description,
    required this.date,
    required this.categories,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    var categoriesList = json['categories'] as List;
    List<Category> categories =
        categoriesList.map((i) => Category.fromJson(i)).toList();

    return Expense(
      id: json['id'],
      amount: json['amount'].toDouble(),
      description: json['description'],
      date: DateTime.parse(json['date']), // Assuming ISO 8601 format
      categories: categories,
    );
  }
}
