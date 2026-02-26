import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/magasin_model.dart';

class MagasinService {
  static const String baseUrl = 'https://backend-gestion-de-stock.onrender.com/api/protected';

  static Future<List<Magasin>> fetchMagasins(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/magasins'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Magasin.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Session expirée - Reconnexion requise');
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }
}
