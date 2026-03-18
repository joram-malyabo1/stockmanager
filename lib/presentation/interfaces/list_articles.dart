import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/produit.dart';
import '../../models/categorie.dart';
import '../../service/db_helper.dart';
import 'add_article_page.dart';

class ArticlesListPage extends StatefulWidget {
  final String magasinId;
  final String magasinNom;
  final String token;

  const ArticlesListPage({
    Key? key,
    required this.magasinId,
    required this.magasinNom,
    required this.token,
  }) : super(key: key);

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

  Future<void> loadData() async {
    final articles = await DBHelper().getAllArticles();
    final categoriesList = await DBHelper().getCategories();

    setState(() {
      allArticles = articles;
      dbCategories = categoriesList
          .where((c) => c != null && c.toString().trim().isNotEmpty)
          .map((c) => c.toString().trim())
          .toSet()
          .map((c) => Categorie(nom: c))
          .toList();
    });
  }

  List<Article> get filtered {
    List<Article> data = List.from(allArticles);
    if (selectedCategory != "Tous les articles") {
      data = data.where((e) =>
      e.categorie != null && e.categorie!.trim() == selectedCategory).toList();
    }
    if (searchCtrl.text.isNotEmpty) {
      data = data.where((e) =>
          e.nom.toLowerCase().contains(searchCtrl.text.toLowerCase())).toList();
    }
    return data;
  }

  // ✅ BOTTOM SHEET SIMPLIFIÉ (100% fonctionnel)
  void _showAddOptions() {
    print('🔥 BOUTON + CLIQUE'); // DEBUG
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Ajouter au magasin\n${widget.magasinNom}",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 32),

              // ✅ OPTION 1
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Color(0xFF1E6FD9).withOpacity(0.1),
                  child: Icon(Icons.inventory_2, color: Color(0xFF1E6FD9)),
                ),
                title: Text("Nouveau Produit", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Ajouter un produit complet"),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.pop(context);
                  _goToAddArticle(); // ✅ NAVIGATION
                },
              ),

              // ✅ OPTION 2
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green.withOpacity(0.1),
                  child: Icon(Icons.trending_up, color: Colors.green),
                ),
                title: Text("Réception Stock", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Recevoir une livraison"),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.pop(context);
                  print('🔥 Réception cliquée');
                },
              ),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ NAVIGATION AddArticlePage
  void _goToAddArticle() {
    print('🚀 Navigation AddArticlePage'); // DEBUG
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddArticlePage(
          magasinId: widget.magasinId,
          magasinNom: widget.magasinNom,
          token: widget.token,
        ),
      ),
    ).then((_) {
      print('🔄 Refresh après AddArticle');
      loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Articles - ${widget.magasinNom}"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 2,
      ),

      // ✅ FLOATING ACTION BUTTON (PAS dans Stack)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddOptions,
        icon: Icon(Icons.add, color: Colors.white),
        label: Text(
          "Ajouter",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        heroTag: "add_articles",
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // ✅ Position

      body: Column(
        children: [
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 250),
              child: isSearching ? _buildSearchBar() : _buildCategoryBar(),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: filtered.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text("Aucun article trouvé", style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                  SizedBox(height: 8),
                  Text("Ajoutez votre premier produit", style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                ],
              ),
            )
                : ListView.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, __) => Divider(height: 1),
              itemBuilder: (_, i) {
                final a = filtered[i];
                return ListTile(
                  leading: _buildImageOrColor(a),
                  title: Text(a.nom, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                  subtitle: Text("Stock : ${a.quantite} | ${a.categorie ?? 'Non classé'}",
                      style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600)),
                  trailing: Text("${a.prix.toStringAsFixed(2)} ${a.devise}",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widgets inchangés...
  Widget _buildImageOrColor(Article a) {
    if (a.image.isNotEmpty && File(a.image).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.file(File(a.image), width: 50, height: 50, fit: BoxFit.cover),
      );
    }
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(6)),
      child: Icon(Icons.image_not_supported, size: 24),
    );
  }

  Widget _buildCategoryBar() {
    return Container(
      height: 45,
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey),
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedCategory,
                items: [
                  DropdownMenuItem(value: "Tous les articles", child: Text("Tous les articles")),
                  ...dbCategories.map((c) => DropdownMenuItem(value: c.nom, child: Text(c.nom))),
                ],
                onChanged: (value) => setState(() => selectedCategory = value!),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() {
              isSearching = true;
              searchCtrl.clear();
            }),
            child: Icon(Icons.search, color: Colors.green[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 45,
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchCtrl,
              autofocus: true,
              decoration: InputDecoration(hintText: "Rechercher...", border: InputBorder.none),
              onChanged: (_) => setState(() {}),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() {
              isSearching = false;
              searchCtrl.clear();
            }),
            child: Icon(Icons.close, color: Colors.red[700]),
          ),
        ],
      ),
    );
  }
  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }
}
