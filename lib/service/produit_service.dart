// service/produit_service.dart - VERSION COMPLÈTEMENT CORRIGÉE
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stockmanager/models/Produit_Detail_Model.dart';
import '../models/produit_model.dart';
import '../models/type_rayon_model.dart';

class ProduitService {
  // ✅ baseUrl CORRECT : inclut déjà /api/protected
  static const String baseUrl = 'https://backend-gestion-de-stock.onrender.com/api/protected';

  // ✅ 1. GET PRODUITS (DÉJÀ CORRECT)
  static Future<List<Produit>> getProduits(String magasinId, String token) async {
    final url = Uri.parse('$baseUrl/magasins/$magasinId/produits');
    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['produits'] ?? [];
        return data.map((e) => Produit.fromJson(e)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Session expirée - Reconnexion requise');
      }
      return [];
    } catch (e) {
      print('❌ Erreur getProduits: $e');
      return [];
    }
  }

  // ✅ 2. GET DÉTAILS PRODUIT (DÉJÀ CORRECT)
  static Future<DetailProduit> getDetailsProduit(String produitId, String token) async {
    try {
      final url = Uri.parse('$baseUrl/produits/$produitId?include=mouvements,receptions,alertes,enregistrement');
      print('🌐 DÉTAILS: $url');

      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      }).timeout(Duration(seconds: 10));

      print('📡 STATUS DÉTAILS: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return DetailProduit.fromJson(jsonData);
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('💥 ERREUR DÉTAILS: $e');
      rethrow;
    }
  }

  static Future<List<TypeProduitSimple>> getTypesProduits(String magasinId, String token) async {
    try {
      final url = '$baseUrl/magasins/$magasinId/types-produits';
      print('🌐 GET TYPES: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('📡 STATUS TYPES: ${response.statusCode}');
      print('📡 BODY TYPES RAW: ${response.body}');  // ✅ TOUT le body

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);

        // ✅ DEBUG : Voir structure exacte
        print('🔍 DATA TYPE: ${data.runtimeType}');
        print('🔍 DATA KEYS: ${data is Map ? data.keys.toList() : "PAS MAP"}');

        List<dynamic> categories = [];

        // ✅ CAS 1 : {"success": true, "categories": [...]}
        if (data is Map && data.containsKey('categories')) {
          categories = data['categories'];
        }
        // ✅ CAS 2 : [...] direct array
        else if (data is List) {
          categories = data;
        }
        // ✅ CAS 3 : {"success": true, "data": {...}}
        else if (data is Map && data.containsKey('data')) {
          final nested = data['data'];
          categories = nested is Map && nested.containsKey('categories') ? nested['categories'] : [];
        }

        print('✅ CATEGORIES trouvées: ${categories.length}');
        print('✅ PREMIER TYPE: ${categories.isNotEmpty ? categories[0] : "VIDE"}');

        return categories.map((e) {
          print('🔨 Parsing: ${e['nomType']}');
          return TypeProduitSimple.fromJson(e);
        }).where((t) => t.nomType != 'Inconnu').toList();  // Filtre invalides
      }
      return [];
    } catch (e, stack) {
      print('💥 ERREUR TYPES: $e');
      print('💥 STACK: $stack');
      return [];
    }
  }



  // ✅ 4. GET RAYONS - CORRIGÉ (SANS double /api/protected)
  static Future<List<RayonSimple>> getRayons(String magasinId, String token) async {
    try {
      final url = '$baseUrl/magasins/$magasinId/rayons';  // ✅ SANS /api/protected supplémentaire
      print('🌐 GET RAYONS: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('📡 STATUS RAYONS: ${response.statusCode}');
      print('📡 BODY RAYONS: ${response.body.substring(0, 200)}...');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('✅ RAYONS trouvés: ${data.length}');
        return data.map((e) => RayonSimple.fromJson(e)).toList();
      }
      print('❌ STATUS RAYONS ${response.statusCode}');
      return [];
    } catch (e) {
      print('❌ Erreur rayons: $e');
      return [];
    }
  }

  // ✅ 5. CRÉER PRODUIT - CORRIGÉ (URL magasinId)
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
        if (photoUrl.isNotEmpty) 'photo': photoUrl,
        if (notes.isNotEmpty) 'notes': notes,
      };

      print('📤 CRÉER PRODUIT: $data');

      final url = '$baseUrl/magasins/$magasinId/produits';  // ✅ CORRIGÉ : magasinId requis
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );

      print('📡 CRÉATION STATUS: ${response.statusCode}');
      print('📡 CRÉATION BODY: ${response.body}');

      if (response.statusCode == 201) {
        print('✅ PRODUIT CRÉÉ!');
        return true;
      } else {
        print('❌ ERREUR CRÉATION: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Exception création: $e');
      return false;
    }
  }
}
