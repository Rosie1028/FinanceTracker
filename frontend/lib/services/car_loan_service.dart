import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/car_loan_models.dart';

const String baseUrl = 'http://127.0.0.1:8000';

class CarLoanService {
  // Fetch all car loan payments
  Future<List<CarLoan>> fetchCarLoans() async {
    final response = await http.get(Uri.parse('$baseUrl/car-loans/'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((loan) => CarLoan.fromJson(loan)).toList();
    } else {
      throw Exception('Failed to load car loans: ${response.statusCode}');
    }
  }

  // Fetch car loan summary statistics
  Future<CarLoanSummary> fetchCarLoanSummary() async {
    final response =
        await http.get(Uri.parse('$baseUrl/car-loans/stats/summary'));

    if (response.statusCode == 200) {
      return CarLoanSummary.fromJson(json.decode(response.body));
    } else {
      throw Exception(
          'Failed to load car loan summary: ${response.statusCode}');
    }
  }

  // Create a new car loan payment
  Future<CarLoan> createCarLoan(Map<String, dynamic> carLoanData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/car-loans/'),
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(carLoanData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return CarLoan.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create car loan entry');
    }
  }

  // Delete a car loan payment
  Future<void> deleteCarLoan(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/car-loans/$id'));

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
          'Failed to delete car loan entry: ${response.statusCode}');
    }
  }
}
