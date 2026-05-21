import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movement_model.dart';

class RapportService {
  static const String baseUrl = "https://backend-gestion-de-stock.onrender.com";

  static Future<List<StockMovement>> getMovements(String magasinId, String token) async {
    final url = Uri.parse("$baseUrl/api/protected/magasins/$magasinId/stock-movements");

    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List list = data['movements'];
        return list.map((m) => StockMovement.fromJson(m)).toList();
      } else {
        throw "Erreur lors de la récupération des rapports";
      }
    } catch (e) {
      rethrow;
    }
  }
}