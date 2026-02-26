import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/produit.dart';
import '../../models/categorie.dart';
import '../../service/db_helper.dart';

class ArticlesListPage extends StatefulWidget {
  @override
  State<ArticlesListPage> createState() => _ArticlesListPageState();
}

class _ArticlesListPageState extends State<ArticlesListPage> {
  List<Article> allArticles = [];
  List<Categorie> dbCategories = [];

  bool isSearching = false;
  TextEditingController searchCtrl = TextEditingController();

  String selectedCategory = "Tous les articles";

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // ============================================================
  // 🔥 CHARGEMENT DONNÉES
  // ============================================================
  Future<void> loadData() async {
    final articles = await DBHelper().getAllArticles();
    final categoriesList = await DBHelper().getCategories(); // List<String?>

    setState(() {
      allArticles = articles;

      dbCategories = categoriesList
          .where((c) => c != null && c.toString().trim().isNotEmpty)
          .map((c) => c.toString().trim())
          .toSet() // 🔥 supprime doublons
          .map((c) => Categorie(nom: c))
          .toList();
    });
  }

  // ============================================================
  // 🔍 FILTRAGE
  // ============================================================
  List<Article> get filtered {
    List<Article> data = List.from(allArticles);

    if (selectedCategory != "Tous les articles") {
      data = data.where((e) =>
      e.categorie != null &&
          e.categorie!.trim() == selectedCategory).toList();
    }

    if (searchCtrl.text.isNotEmpty) {
      data = data.where((e) =>
          e.nom.toLowerCase().contains(searchCtrl.text.toLowerCase())).toList();
    }

    return data;
  }

  // ============================================================
  // 🖥️ UI
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Articles"),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: isSearching ? _buildSearchBar() : _buildCategoryBar(),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text("Aucun article"))
                : ListView.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final a = filtered[i];
                return ListTile(
                  leading: _buildImageOrColor(a),
                  title: Text(
                    a.nom,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                  ),
                  subtitle: Text(
                    "Stock : ${a.quantite}",
                    style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w600),
                  ),
                  trailing: Text(
                    "${a.prix.toStringAsFixed(2)} ${a.devise}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🎨 IMAGE OU COULEUR
  // ============================================================
  Widget _buildImageOrColor(Article a) {
    if (a.image.isNotEmpty && File(a.image).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.file(
          File(a.image),
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
      );
    } else if (a.couleur != null) {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Color(a.couleur!),
          borderRadius: BorderRadius.circular(6),
        ),
      );
    } else {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(Icons.image_not_supported),
      );
    }
  }

  // ============================================================
  // 🔹 BARRE CATÉGORIE
  // ============================================================
  Widget _buildCategoryBar() {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedCategory,
                items: [
                  const DropdownMenuItem(
                    value: "Tous les articles",
                    child: Text("Tous les articles"),
                  ),
                  ...dbCategories.map(
                        (c) => DropdownMenuItem(
                      value: c.nom,
                      child: Text(c.nom),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() => selectedCategory = value!);
                },
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                isSearching = true;
                searchCtrl.clear();
              });
            },
            child: Icon(Icons.search, color: Colors.grey[800]),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🔹 BARRE RECHERCHE
  // ============================================================
  Widget _buildSearchBar() {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchCtrl,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: "Rechercher",
                border: InputBorder.none,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                isSearching = false;
                searchCtrl.clear();
              });
            },
            child: Icon(Icons.close, color: Colors.grey[800]),
          ),
        ],
      ),
    );
  }
}
