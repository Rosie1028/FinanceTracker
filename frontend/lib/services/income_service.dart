import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/entry_models.dart';

// Assuming your backend is running on http://localhost:8000
const String baseUrl = 'http://127.0.0.1:8000';

class IncomeService {
  // Fetch all incomes
  Future<List<Income>> fetchIncomes() async {
    final response = await http.get(Uri.parse('$baseUrl/incomes/'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((income) => Income.fromJson(income)).toList();
    } else {
      throw Exception('Failed to load incomes');
    }
  }

  // Add a new income entry
  Future<Income> createIncome(IncomeCreate income) async {
    final response = await http.post(
      Uri.parse('$baseUrl/incomes/'),
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(income.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Income.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create income entry');
    }
  }

  // Delete an income entry
  Future<void> deleteIncome(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/incomes/$id'));

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete income entry: ${response.statusCode}');
    }
  }
}

// Basic models for data transfer (should match your backend schemas)
class Income {
  final int id;
  final double amount;
  final String? description;
  final DateTime date;
  final String? source;

  Income({
    required this.id,
    required this.amount,
    this.description,
    required this.date,
    this.source,
  });

  factory Income.fromJson(Map<String, dynamic> json) {
    return Income(
      id: json['id'],
      amount: json['amount'].toDouble(),
      description: json['description'],
      date: DateTime.parse(json['date']), // Assuming ISO 8601 format
      source: json['source'],
    );
  }
}
