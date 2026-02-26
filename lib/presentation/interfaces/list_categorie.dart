import 'package:flutter/material.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:stockmanager/presentation/interfaces/add_categorie_page.dart';
import '../../models/categorie.dart';


class CategoryListPage extends StatelessWidget {

  final List<Categorie> categories = [
    Categorie(id: 1, nom: "Boissons"),
    Categorie(id: 2, nom: "Biscuit"),
    Categorie(id: 3, nom: "Savon"),
    Categorie(id: 4, nom: "Pâtes alimentaires"),
    Categorie(id: 5, nom: "Riz"),
    Categorie(id: 6, nom: "Produits laitiers"),
  ];

  CategoryListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // --------------------- APPBAR ANIMÉE ---------------------
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: DelayedDisplay(
          delay: Duration(milliseconds: 0),
          slidingBeginOffset: Offset(0, -1),
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
                          "Catégories",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),

      // --------------------- LISTE AVEC ANIMATIONS ---------------------
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];

          return DelayedDisplay(
            delay: Duration(milliseconds: 80 * index),
            slidingBeginOffset: Offset(0.3, 0),
            child: Card(
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 3,
              child: ListTile(
                title: Text(
                  category.nom,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Icon(Icons.arrow_forward_ios, size: 18),
              ),
            ),
          );
        },
      ),

      // --------------------- BOUTON AJOUT (+) ---------------------
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: Icon(Icons.add, size: 28),
        onPressed: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddCategoriePage()),
          );
        },
      ),
    );
  }
}
