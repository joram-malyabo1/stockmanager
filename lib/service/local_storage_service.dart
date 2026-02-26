import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _keyIdentifier = "identifier";
  static const String _keyPassword = "password";
  static const String _keyToken = "token";
  static const String _keyUser = "user";

  // ===========================
  // Sauvegarder les données de login
  // ===========================
  static Future<void> saveLoginData({
    required String identifier,
    required String password,
    String? token,
    required Map<String, dynamic> user,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyIdentifier, identifier);
    await prefs.setString(_keyPassword, password);
    if (token != null) {
      await prefs.setString(_keyToken, token);
    } else {
      await prefs.remove(_keyToken);
    }
    // On sauvegarde l'objet utilisateur sous forme de JSON
    await prefs.setString(_keyUser, jsonEncode(user));
  }

  // ===========================
  // Lire les données de login
  // ===========================
  static Future<Map<String, dynamic>> getLoginData() async {
    final prefs = await SharedPreferences.getInstance();
    final identifier = prefs.getString(_keyIdentifier);
    final password = prefs.getString(_keyPassword);
    final token = prefs.getString(_keyToken);
    final userJson = prefs.getString(_keyUser);

    if (identifier == null || password == null || userJson == null) {
      return {};
    }

    final user = jsonDecode(userJson) as Map<String, dynamic>;

    return {
      "identifier": identifier,
      "password": password,
      "token": token,
      "user": user,
    };
  }

  // ===========================
  // Supprimer toutes les données de login
  // ===========================
  static Future<void> clearLoginData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIdentifier);
    await prefs.remove(_keyPassword);
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUser);
  }
}
