// service/produit_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

// ✅ Alias 'detail' pour éviter le conflit sur la classe "Reception"
import 'package:stockmanager/models/Produit_Detail_Model.dart' as detail;
import '../models/produit_model.dart';
import '../models/type_rayon_model.dart';
import '../models/reception_model.dart';

class ProduitService {
  static const String baseUrl = 'https://backend-gestion-de-stock.onrender.com/api/protected';

  // ==========================================
  // 📸 UPLOAD DE L'IMAGE (Version Mise à Jour)
  // ==========================================

  static Future<String?> uploadImageProduit(File imageFile, String token) async {
    try {
      final url = Uri.parse('$baseUrl/upload/produit-image');
      var request = http.MultipartRequest('POST', url);

      // Nettoyage du token au cas où il contient déjà "Bearer"
      String cleanToken = token.replaceAll('Bearer ', '');

      request.headers.addAll({
        'Authorization': 'Bearer $cleanToken',
        'Accept': 'application/json',
      });

      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      // On donne 60 secondes au serveur pour répondre (au lieu de 10 par défaut)
      var streamedResponse = await request.send().timeout(const Duration(seconds: 60));
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['url'] ?? data['imageUrl'] ?? data['data']?['url'];
      } else {
        print('❌ Erreur Upload (${response.statusCode}): ${response.body}');
        return null;
      }
    } catch (e) {
      print('💥 Exception Upload: $e');
      return null;
    }
  }

  // ✅ 1. OBTENIR LES PRODUITS
  static Future<List<Produit>> getProduits(String magasinId, String token) async {
    final url = Uri.parse('$baseUrl/magasins/$magasinId/produits');
    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        List<dynamic> produits = [];

        if (data is Map && data.containsKey('produits')) {
          produits = data['produits'] ?? [];
        } else if (data is List) {
          produits = data;
        } else if (data is Map && data.containsKey('data')) {
          produits = data['data']['produits'] ?? [];
        }

        return produits.map((item) => Produit.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('💥 ERREUR GET PRODUITS: $e');
      return [];
    }
  }

  // ✅ 2. OBTENIR DÉTAILS PRODUIT
  static Future<detail.DetailProduit> getDetailsProduit(String produitId, String token) async {
    final url = Uri.parse('$baseUrl/produits/$produitId?include=mouvements,receptions,alertes,enregistrement');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    }).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return detail.DetailProduit.fromJson(json.decode(response.body));
    } else {
      throw Exception('HTTP ${response.statusCode}');
    }
  }

  // ✅ 3. OBTENIR TYPES PRODUITS
  static Future<List<TypeProduitSimple>> getTypesProduits(String magasinId, String token) async {
    try {
      final url = '$baseUrl/magasins/$magasinId/types-produits';
      final response = await http.get(Uri.parse(url), headers: {'Authorization': 'Bearer $token'});

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        List<dynamic> categories = [];
        if (data is Map && data.containsKey('categories')) {
          categories = data['categories'];
        } else if (data is List) {
          categories = data;
        }
        return categories.map((e) => TypeProduitSimple.fromJson(e)).toList();
      }
    } catch (e) {
      print('💥 ERREUR TYPES: $e');
    }
    return [];
  }

  // ✅ 4. OBTENIR RAYONS
  static Future<List<RayonSimple>> getRayons(String magasinId, String token) async {
    try {
      final url = '$baseUrl/magasins/$magasinId/rayons';
      final response = await http.get(Uri.parse(url), headers: {'Authorization': 'Bearer $token'});

      if (response.statusCode == 200) {
        return (json.decode(response.body) as List).map((e) => RayonSimple.fromJson(e)).toList();
      }
    } catch (e) {
      print('💥 ERREUR RAYONS: $e');
    }
    return [];
  }

  // ✅ 5. CRÉER PRODUIT
  static Future<bool> creerProduit({
    required String magasinId,
    required String token,
    required String reference,
    required String designation,
    required String typeProduitId,
    required String rayonId,
    required double prixUnitaire,
    required double quantiteEntree,
    double seuilAlerte = 10.0,
    String photoUrl = '',
    String notes = '',
  }) async {
    try {
      final data = {
        'reference': reference,
        'designation': designation,
        'typeProduitId': typeProduitId,
        'rayonId': rayonId,
        'prixUnitaire': prixUnitaire,
        'quantiteEntree': quantiteEntree,
        'seuilAlerte': seuilAlerte,
        'etat': 'Neuf',
        if (photoUrl.isNotEmpty) 'photoUrl': photoUrl,
        if (notes.isNotEmpty) 'notes': notes,
      };

      final url = '$baseUrl/magasins/$magasinId/produits';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      print('📡 CREER PRODUIT STATUS: ${response.statusCode}');
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('💥 ERREUR CREER PRODUIT: $e');
      return false;
    }
  }

  // ✅ 6. CRÉER UNE RÉCEPTION
  static Future<Map<String, dynamic>> creerReception({
    required String token,
    required String magasinId,
    required String produitId,
    required String rayonId,
    required String typeProduitId,
    required double quantite,
    required double prixAchat,
    required String fournisseur,
    required String dateReception,
    String photoUrl = "",
    String observations = "",
    bool isLot = false,
    int? nombrePieces,
    double? quantiteParPiece,
    String? uniteDetail,
    double? prixParUnite,
  }) async {
    try {
      final Map<String, dynamic> data = {
        "magasinId": magasinId,
        "produitId": produitId,
        "rayonId": rayonId,
        "quantite": quantite,
        "typeProduitId": typeProduitId,
        "prixAchat": prixAchat,
        "fournisseur": fournisseur.isNotEmpty ? fournisseur : "Inconnu",
        "dateReception": dateReception,
        if (observations.isNotEmpty) "observations": observations,
        if (photoUrl.isNotEmpty) "photoUrl": photoUrl,
        if (isLot && nombrePieces != null) "nombrePieces": nombrePieces,
        if (isLot && quantiteParPiece != null) "quantiteParPiece": quantiteParPiece,
        if (isLot) "uniteDetail": uniteDetail ?? "unité",
        if (isLot && prixParUnite != null) "prixParUnite": prixParUnite,
      };

      final url = Uri.parse('$baseUrl/receptions');
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {"success": true, "message": "Réception enregistrée"};
      } else {
        final decodedBody = json.decode(response.body);
        return {"success": false, "message": decodedBody['error'] ?? "Erreur serveur"};
      }
    } catch (e) {
      return {"success": false, "message": "Erreur de connexion : $e"};
    }
  }

  // ✅ 7. OBTENIR LES RÉCEPTIONS
  static Future<List<Reception>> getReceptions(String magasinId, String token) async {
    try {
      final url = Uri.parse('$baseUrl/receptions?magasinId=$magasinId');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        if (data is Map && data['success'] == true && data['receptions'] != null) {
          final List<dynamic> listeApi = data['receptions'];
          return listeApi.map((e) => Reception.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      print('💥 ERREUR GET RECEPTIONS: $e');
      return [];
    }
  }
}