import 'package:flutter/material.dart';
import 'package:stockmanager/presentation/interfaces/list_articles.dart';

class ArticlesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Articles"),
        backgroundColor: Colors.green,
      ),
      body: ListView(
        children: [
          // ARTICLES
          ListTile(
            leading: Icon(Icons.list),
            title: Text("Articles"),
            // onTap: () {
            //   Navigator.push(
            //     context,
            //     MaterialPageRoute(builder: (_) => ArticlesListPage()),
            //   );
            // },
          ),

          Divider(),

          // CATEGORIES
          ListTile(
            leading: Icon(Icons.category),
            title: Text("Catégories"),
            // onTap: () {
            //   Navigator.push(
            //     context,
            //     MaterialPageRoute(builder: (_) => CategoriesListPage()),
            //   );
            // },
          ),
          Divider(),

          // MODIFICATEURS
          ListTile(
            leading: Icon(Icons.edit_note),
            title: Text("Modificateurs"),
          ),
          Divider(),

          // RÉDUCTIONS
          ListTile(
            leading: Icon(Icons.discount),
            title: Text("Réductions"),
          ),
          Divider(),
        ],
      ),
    );
  }
}
