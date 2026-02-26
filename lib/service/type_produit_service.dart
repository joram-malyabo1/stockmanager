// service/produit_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/produit_model.dart';

class ProduitService {
  static const String baseUrl =
      'https://backend-gestion-de-stock.onrender.com/api/protected';

  static Future<List<Produit>> getProduits(
      String magasinId, String token) async {
    final url = Uri.parse('$baseUrl/magasins/$magasinId/produits');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => Produit.fromJson(e)).toList();
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
