import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/entry_models.dart';

// Assuming your backend is running on http://localhost:8000
const String baseUrl = 'http://127.0.0.1:8000';

class InvestmentAndSavingService {
  // Fetch all savings
  Future<List<Saving>> fetchSavings() async {
    final response = await http.get(Uri.parse('$baseUrl/savings/'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((saving) => Saving.fromJson(saving)).toList();
    } else {
      throw Exception('Failed to load savings');
    }
  }

  // Add a new saving entry
  Future<Saving> createSaving(SavingCreate saving) async {
    final response = await http.post(
      Uri.parse('$baseUrl/savings/'),
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(saving.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Saving.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create saving entry');
    }
  }

  // Fetch all investments
  Future<List<Investment>> fetchInvestments() async {
    final response = await http.get(Uri.parse('$baseUrl/investments/'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((investment) => Investment.fromJson(investment))
          .toList();
    } else {
      throw Exception('Failed to load investments');
    }
  }

  // Add a new investment entry
  Future<Investment> createInvestment(InvestmentCreate investment) async {
    final response = await http.post(
      Uri.parse('$baseUrl/investments/'),
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(investment.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Investment.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create investment entry');
    }
  }

  // Delete a saving entry
  Future<void> deleteSaving(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/savings/$id'));

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete saving entry: ${response.statusCode}');
    }
  }

  // Delete an investment entry
  Future<void> deleteInvestment(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/investments/$id'));

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
          'Failed to delete investment entry: ${response.statusCode}');
    }
  }
}

// Basic models for data transfer (should match your backend schemas)
class Saving {
  final int id;
  final double amount;
  final String? description;
  final DateTime date;

  Saving({
    required this.id,
    required this.amount,
    this.description,
    required this.date,
  });

  factory Saving.fromJson(Map<String, dynamic> json) {
    return Saving(
      id: json['id'],
      amount: json['amount'].toDouble(),
      description: json['description'],
      date: DateTime.parse(json['date']), // Assuming ISO 8601 format
    );
  }
}

class Investment {
  final int id;
  final double amount;
  final String? description;
  final DateTime date;

  Investment({
    required this.id,
    required this.amount,
    this.description,
    required this.date,
  });

  factory Investment.fromJson(Map<String, dynamic> json) {
    return Investment(
      id: json['id'],
      amount: json['amount'].toDouble(),
      description: json['description'],
      date: DateTime.parse(json['date']), // Assuming ISO 8601 format
    );
  }
}
