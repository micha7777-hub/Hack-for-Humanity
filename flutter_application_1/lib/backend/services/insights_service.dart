import 'dart:convert';
import 'package:http/http.dart' as http;

class InsightsService {
  // ⚠️ CHANGE PORT IF YOUR BACKEND USES A DIFFERENT ONE
  static const String baseUrl = 'http://localhost:3001';

  static Future<Map<String, dynamic>> fetchInsights(
    List<Map<String, dynamic>> transactions,
  ) async {
    final uri = Uri.parse('$baseUrl/api/insights');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'transactions': transactions,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Insights API error: ${response.statusCode} ${response.body}',
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}