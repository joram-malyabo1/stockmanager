import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:stockmanager/models/Produit_Detail_Model.dart' as detail;
import '../models/produit_model.dart';
import '../models/type_rayon_model.dart';
import '../models/reception_model.dart';

class ProduitService {
  // Votre base URL actuelle
  static const String baseUrl = 'https://backend-gestion-de-stock.onrender.com/api/protected';

// ==========================================
// 1. UPLOAD IMAGE (Corrigé selon Postman)
// ==========================================
  static Future<String?> uploadImageProduit(File imageFile, String token) async {
    try {
      print("🚀 [UPLOAD] Début de l'envoi image...");

      // Correction de l'URL : On ajoute '/upload/produit-image' à la suite du baseUrl
      // URL finale : https://backend-gestion-de-stock.onrender.com/api/protected/upload/produit-image
      var request = http.MultipartRequest(
          'POST',
          Uri.parse('$baseUrl/upload/produit-image')
      );

      request.headers['Authorization'] = 'Bearer $token';

      // Correction de la clé : Postman montre 'image', donc on change 'photo' par 'image'
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      var streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      var response = await http.Response.fromStream(streamedResponse);

      print("📡 [UPLOAD STATUS]: ${response.statusCode}");
      print("📡 [UPLOAD BODY]: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        // ✅ VÉRIFICATION IMPORTANTE :
        // Regardez dans Postman si le serveur renvoie {"photoUrl": "..."} ou {"url": "..."}
        // Si c'est 'url', remplacez data['photoUrl'] par data['url'] ci-dessous :
        return data['photoUrl'] ?? data['url'];
      } else {
        print("❌ Erreur serveur lors de l'upload");
        return null;
      }
    } catch (e) {
      print("❌ [UPLOAD ERROR]: $e");
      return null;
    }
  }

  // ==========================================
  // 2. GESTION DES RÉCEPTIONS
  // ==========================================

  // ✅ CRÉER UNE RÉCEPTION (Sécurisée contre les doublons)
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

      final response = await http.post(
        Uri.parse('$baseUrl/receptions'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: json.encode(data),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {"success": true, "message": "Réception enregistrée"};
      } else {
        final decodedBody = json.decode(response.body);
        return {"success": false, "message": decodedBody['error'] ?? "Erreur serveur"};
      }
    } on TimeoutException catch (_) {
      return {"success": false, "message": "Délai d'attente dépassé."};
    } catch (e) {
      return {"success": false, "message": "Erreur de connexion : $e"};
    }
  }

  // ✅ OBTENIR L'HISTORIQUE DES RÉCEPTIONS
  static Future<List<Reception>> getReceptions(String magasinId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/receptions?magasinId=$magasinId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data['success'] == true && data['receptions'] != null) {
          return (data['receptions'] as List).map((e) => Reception.fromJson(e)).toList();
        } else if (data is List) {
          return data.map((e) => Reception.fromJson(e)).toList();
        }
      }
    } catch (e) {
      print("❌ [GET RECEPTIONS ERROR]: $e");
    }
    return [];
  }



  // ✅ MODIFIER UNE RÉCEPTION EXISTANTE
  static Future<Map<String, dynamic>> modifierReception({
    required String token,
    required String receptionId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/receptions/$receptionId');
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: json.encode(data),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        return {"success": true, "message": "Réception mise à jour"};
      } else {
        final decodedBody = json.decode(response.body);
        return {"success": false, "message": decodedBody['error'] ?? "Erreur lors de la modification"};
      }
    } catch (e) {
      return {"success": false, "message": "Erreur de connexion : $e"};
    }
  }

  // ==========================================
  // 3. GESTION DES PRODUITS
  // ==========================================

  static Future<List<Produit>> getProduits(String magasinId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/magasins/$magasinId/produits'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        List<dynamic> produitsJson = (data is Map && data.containsKey('produits'))
            ? data['produits']
            : (data is List ? data : []);
        return produitsJson.map((item) => Produit.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print("❌ [GET PRODUITS ERROR]: $e");
      return [];
    }
  }

  static Future<detail.DetailProduit> getDetailsProduit(String produitId, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/produits/$produitId?include=mouvements,receptions,alertes,enregistrement'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return detail.DetailProduit.fromJson(json.decode(response.body));
    }
    throw Exception('Erreur de chargement des détails');
  }

  static Future<Map<String, dynamic>> creerProduit({
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
        'photoUrl': photoUrl,
        'notes': notes,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/magasins/$magasinId/produits'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      final decoded = json.decode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {"success": true};
      } else {
        return {"success": false, "message": decoded['message'] ?? "Erreur serveur"};
      }
    } catch (e) {
      return {"success": false, "message": "Erreur de connexion : $e"};
    }
  }

  // ==========================================
  // 4. CONFIGURATION (TYPES / RAYONS)
  // ==========================================
  static Future<List<TypeProduitSimple>> getTypesProduits(String magasinId, String token) async {
    final response = await http.get(
        Uri.parse('$baseUrl/magasins/$magasinId/types-produits'),
        headers: {'Authorization': 'Bearer $token'}
    );
    if (response.statusCode == 200) {
      final dynamic data = json.decode(response.body);
      List<dynamic> cats = (data is Map) ? (data['categories'] ?? []) : data;
      return cats.map((e) => TypeProduitSimple.fromJson(e)).toList();
    }
    return [];
  }

  static Future<List<RayonSimple>> getRayons(String magasinId, String token) async {
    final response = await http.get(
        Uri.parse('$baseUrl/magasins/$magasinId/rayons'),
        headers: {'Authorization': 'Bearer $token'}
    );
    if (response.statusCode == 200) {
      return (json.decode(response.body) as List).map((e) => RayonSimple.fromJson(e)).toList();
    }
    return [];
  }
}