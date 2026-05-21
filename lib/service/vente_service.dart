import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/TicketItem.dart';

class VenteService {
  static const String baseUrl = "https://backend-gestion-de-stock.onrender.com";

  static Future<Map<String, dynamic>> creerVente({
    required String token,
    required String magasinId,
    required String guichetId,
    required String utilisateurId,
    required String client,
    required List<TicketItem> items,
    required double montantTotal,
  }) async {
    final String url = "$baseUrl/api/protected/ventes";

    // ✅ LOGIQUE DE CALCUL RIGOUREUSE POUR LE STOCK ET LES FINANCES
    List<Map<String, dynamic>> articlesJson = items.map((item) {
      double quantiteFinaleStock = item.quantite.toDouble();
      double prixUnitaireFacture = item.produit.prixUnitaire;

      if (item.typeVente.toLowerCase().contains("lot")) {
        // 1. On calcule combien de pièces contient UN SEUL lot
        // Exemple : PrixLot (450 000) / PrixUnitaire (15 000) = 30 pièces
        double nbPiecesDansUnLot = item.produit.prixLot / item.produit.prixUnitaire;

        // 2. On calcule la quantité totale de pièces à déduire du stock
        // Exemple : 3 lots sélectionnés * 30 pièces = 90 pièces
        quantiteFinaleStock = item.quantite * nbPiecesDansUnLot;

        // Note : Le prix unitaire envoyé reste 15 000 FG (le prix d'une pièce)
      }

      return {
        "produitId": item.produit.id,
        "quantite": quantiteFinaleStock, // 90 pour 3 lots de 30
        "prixUnitaire": prixUnitaireFacture, // 15 000
        "montant": item.total, // 1 350 000 (3 * 450 000)
        "rayonId": item.produit.rayonId.id,
        "typeVente": item.typeVente,
      };
    }).toList();

    final Map<String, dynamic> bodyRequest = {
      "magasinId": magasinId,
      "guichetId": guichetId,
      "utilisateurId": utilisateurId,
      "client": client,
      "montantTotal": montantTotal, // Somme totale (ex: 1 350 000 + autres articles)
      "montantPaye": montantTotal,
      "tauxFC": 2500,
      "articles": articlesJson,
      "observations": "Vente Mobile POS - Calcul Lot Automatique",
    };

    try {
      print("🚀 [POST] Envoi de la vente au serveur...");
      print("📦 Body: ${jsonEncode(bodyRequest)}");

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(bodyRequest),
      );

      print("📥 [SERVER RESPONSE] Status: ${response.statusCode}");

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return responseData; // Succès
      } else {
        // Gestion des erreurs serveurs (ex: stock insuffisant)
        throw responseData['message'] ?? responseData['error'] ?? "Erreur lors de la vente";
      }
    } catch (e) {
      print("❌ [VENTE SERVICE ERROR]: $e");
      rethrow;
    }
  }
}