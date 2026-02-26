import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/rayon.dart';

class RayonService {
  static const String baseUrl = 'https://backend-gestion-de-stock.onrender.com/api/protected';

  static Future<List<Rayon>> getRayons(String magasinId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/magasins/$magasinId/rayons'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Rayon.fromJson(json)).toList();
      }
      throw Exception('Erreur chargement rayons: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }
}
