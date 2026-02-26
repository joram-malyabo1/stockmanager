import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/categorie.dart';
import '../models/produit.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('stockmanager.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  // ==========================
  // CREATION DES TABLES
  // ==========================
  Future<void> _onCreate(Database db, int version) async {

    // CONTEXTE ENTREPRISE
    await db.execute('''
      CREATE TABLE entreprise_context (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entreprise_nom TEXT,
        entreprise_adresse TEXT,
        entreprise_devise TEXT,
        entreprise_logo TEXT,
        magasin_nom TEXT,
        guichet_nom TEXT,
        utilisateur_nom TEXT,
        utilisateur_role TEXT,
        utilisateur_profil TEXT,
        date_synchro TEXT
      )
    ''');

    // UTILISATEUR
    await db.execute('''
      CREATE TABLE utilisateur (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        telephone TEXT,
        email TEXT,
        password TEXT NOT NULL,
        role TEXT NOT NULL,
        entreprise_nom TEXT,
        magasin_nom TEXT,
        guichet_nom TEXT,
        profil TEXT,
        actif INTEGER DEFAULT 1
      )
    ''');

    // CATEGORIE
    await db.execute('''
      CREATE TABLE categorie (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL
      )
    ''');

    // ARTICLE
    await db.execute('''
      CREATE TABLE article (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        categorie_id INTEGER,
        quantite INTEGER DEFAULT 0,
        prix REAL NOT NULL,
        devise TEXT DEFAULT 'USD',
        magasin_nom TEXT,
        image TEXT,
        couleur INTEGER,
        date_ajout TEXT,
        etat_emplacement TEXT,
        rayon TEXT,
        stock_min INTEGER,
        date_expiration TEXT,
        FOREIGN KEY (categorie_id) REFERENCES categorie(id)
      )
    ''');

    // VENTE
    await db.execute('''
      CREATE TABLE vente (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        article_id INTEGER,
        quantite INTEGER,
        montant_total REAL,
        date TEXT,
        utilisateur_nom TEXT,
        magasin_nom TEXT,
        guichet_nom TEXT
      )
    ''');

    // MOUVEMENT STOCK

    await db.execute('''
      CREATE TABLE mouvement_stock (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        article_id INTEGER,
        type_mouvement TEXT,
        quantite INTEGER,
        date TEXT,
        utilisateur_nom TEXT,
        magasin_nom TEXT
      )
   ''');
  }

  // ==========================
  // CONTEXTE
  // ==========================
  Future<Map<String, dynamic>?> getContexteActif() async {
    final db = await database;
    final res = await db.query('entreprise_context', limit: 1);
    return res.isNotEmpty ? res.first : null;
  }

  // ==========================
  // UTILISATEUR
  // ==========================
  Future<int> insertUtilisateur(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('utilisateur', data);
  }

  Future<List<Map<String, dynamic>>> getUtilisateurs() async {
    final db = await database;
    return await db.query('utilisateur');
  }

  Future<Map<String, dynamic>?> login(String login, String password) async {
    final db = await database;
    final res = await db.query(
      'utilisateur',
      where: '(telephone = ? OR email = ?) AND password = ? AND actif = 1',
      whereArgs: [login, login, password],
    );
    return res.isNotEmpty ? res.first : null;
  }


  Future<void> insertContexteParDefaut() async {
    final db = await database;

    final existing = await db.query(
      'entreprise_context',
      limit: 1,
    );

    // Si le contexte existe déjà → ne rien faire
    if (existing.isNotEmpty) return;

    // Sinon on insère un contexte par défaut
    await db.insert('entreprise_context', {
      'entreprise_nom': 'ENTREPRISE DEMO',
      'entreprise_adresse': 'Goma',
      'entreprise_devise': 'USD / FC',
      'entreprise_logo': null,
      'magasin_nom': 'MAGASIN PRINCIPAL',
      'guichet_nom': 'GUICHET 1',
      'utilisateur_nom': 'ADMIN',
      'utilisateur_role': 'ADMIN',
      'utilisateur_profil': null,
      'date_synchro': DateTime.now().toIso8601String(),
    });
  }


  Future<int> insertCategorie(Categorie categorie) async {
    final db = await database;

    final res = await db.query(
      'categorie',
      where: 'nom = ?',
      whereArgs: [categorie.nom],
    );

    if (res.isNotEmpty) {
      return res.first['id'] as int;
    }

    return await db.insert('categorie', categorie.toMap());
  }

  Future<List<String>> getCategories() async {
    final db = await database;
    final result = await db.query('categorie', orderBy: 'nom ASC');

    // retourne la liste des noms
    return result.map((e) => e['nom'] as String).toList();
  }

  

// INSÉRER UN ARTICLE
  Future<int> insertArticle(Article article) async {
    final db = await database;

    int? categorieId;
    if (article.categorie != null) {
      categorieId = await insertCategorie(
        Categorie(nom: article.categorie!),
      );
    }

    final map = article.toMap();
    map['categorie_id'] = categorieId;

    return await db.insert('article', map);
  }



  Future<List<Article>> getAllArticles() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'article',
      orderBy: 'nom ASC',
    );
    return maps.map((e) => Article.fromMap(e)).toList();
  }

  Future<List<Article>> getArticlesByCategorie(String categorie) async {
    final db = await database;
    final result = await db.query(
      'articles',
      where: 'categorie = ?',
      whereArgs: [categorie],
    );
    return result.map((e) => Article.fromMap(e)).toList();
  }

  Future<void> destockerArticle(int articleId, int quantiteVendue) async {
    final db = await database;
    await db.rawUpdate(
      '''
    UPDATE articles
    SET quantite = quantite - ?
    WHERE id = ? AND quantite >= ?
    ''',
      [quantiteVendue, articleId, quantiteVendue],
    );
  }




}
