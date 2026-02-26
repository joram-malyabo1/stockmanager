import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiConfig {
  static const String baseUrl =
      'https://backend-gestion-de-stock.onrender.com/api';
}

class AuthService {
  static Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/login');

    print('🔍 URL: $url');
    final body = jsonEncode({
      'identifier': identifier,
      'password': password,
    });
    print('🔍 Body envoyé: $body');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: body,
    );

    print('🔍 StatusCode: ${response.statusCode}');
    print('🔍 Headers: ${response.headers}');
    print('🔍 Response body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur ${response.statusCode}: ${response.body}');
    }
  }
}
