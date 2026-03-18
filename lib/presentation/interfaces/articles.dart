import 'package:flutter/material.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:stockmanager/presentation/interfaces/add_categorie_page.dart';
import 'add_article_page.dart';
import 'list_articles.dart';
import 'list_categorie.dart';

class ItemsPage extends StatelessWidget {
  const ItemsPage({super.key});

  // MENU POUR AJOUTER
  void _showAddMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return DelayedDisplay(
          delay: const Duration(milliseconds: 200),
          slidingBeginOffset: const Offset(0.0, 0.3),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                  "Ajouter",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              DelayedDisplay(
                delay: const Duration(milliseconds: 350),
                slidingBeginOffset: const Offset(0.3, 0),
                child: ListTile(
                  leading: const Icon(Icons.list_alt, color: Colors.green),
                  title: const Text("Ajouter un article"),
                  onTap: () {
                    // Navigator.pop(context);
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (_) => AddArticlePage()),
                    // );
                  },
                ),
              ),
              DelayedDisplay(
                delay: const Duration(milliseconds: 450),
                slidingBeginOffset: const Offset(0.3, 0),
                child: ListTile(
                  leading: const Icon(Icons.category, color: Colors.green),
                  title: const Text("Ajouter une catégorie"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AddCategoriePage()),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // APPBAR
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: DelayedDisplay(
          delay: const Duration(milliseconds: 0),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: Colors.green, size: 28),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          "Articles",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    IconButton(
                      icon:
                      const Icon(Icons.person_add, color: Colors.white, size: 20),
                      onPressed: () {},
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert,
                          color: Colors.white, size: 20),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                            value: 'synchroniser', child: Text('Synchroniser')),
                        const PopupMenuItem(
                            value: 'parametres', child: Text('Paramètres')),
                        const PopupMenuItem(value: 'aide', child: Text('Aide')),
                      ],
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),

      // 🟢 ICI : LA LISTE DES OPTIONS (Articles – Catégories – etc.)
      body: DelayedDisplay(
        delay: const Duration(milliseconds: 200),
        slidingBeginOffset: const Offset(0, 0.2),
        child: ListView(
          children: [
            // ARTICLES
            ListTile(
              leading: const Icon(Icons.list, color: Colors.green),
              title: const Text("Articles"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navigator.push(
                //   context,
                //   // MaterialPageRoute(
                //   //   // builder: (_) => ArticlesListPage(),
                //   // ),
                // );
              },
            ),
            const Divider(height: 1),

            // CATEGORIES
            ListTile(
              leading: const Icon(Icons.category, color: Colors.green),
              title: const Text("Catégories"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CategoryListPage(), // 👉 page liste catégories
                  ),
                );
              },
            ),
            const Divider(height: 1),
          ],
        ),
      ),

      // BOUTON +
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMenu(context),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}
