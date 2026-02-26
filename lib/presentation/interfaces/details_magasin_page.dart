import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/produit_model.dart';
import '../../service/produit_service.dart';
import 'DetailsProduitPage.dart';
import 'ListProduit.dart';

class DashboardMagasinPage extends StatefulWidget {
  final String magasinId;
  final String magasinNom;
  final String token;
  final String? nomUtilisateur;

  const DashboardMagasinPage({
    Key? key,
    required this.magasinId,
    required this.magasinNom,
    required this.token,
    this.nomUtilisateur = "Utilisateur",
  }) : super(key: key);

  @override
  State<DashboardMagasinPage> createState() => _DashboardMagasinPageState();
}

class _DashboardMagasinPageState extends State<DashboardMagasinPage> {
  late Future<List<Produit>> futureProduits;

  @override
  void initState() {
    super.initState();
    futureProduits = ProduitService.getProduits(widget.magasinId, widget.token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard - ${widget.magasinNom}"),
        backgroundColor: const Color(0xFF1E6FD9),
        foregroundColor: Colors.white,
      ),
      drawer: _buildDrawer(), // ✅ MENU
      body: FutureBuilder<List<Produit>>(
        future: futureProduits,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("Aucun produit trouvé"),
            );
          }

          final produits = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDashboard(produits), // ✅ DASHBOARD COMPLET
                const SizedBox(height: 20),
                _buildBoutonArticles(), // ✅ BOUTON VERS ARTICLES
              ],
            ),
          );
        },
      ),
    );
  }

  // ✅ VOTRE DASHBOARD EXACT (copié tel quel)
  Widget _buildDashboard(List<Produit> produits) {
    final stockTotal = produits.fold<int>(0, (sum, p) => sum + p.quantiteActuelle);
    final rayonsActifs = produits.map((p) => p.rayonId).toSet().length;
    final alertesStock = produits.where((p) => p.quantiteActuelle <= p.seuilAlerte).length;
    final rayonsPleins = 0;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _statCard(
                  title: "Stock Total",
                  value: "$stockTotal",
                  subtitle: "Articles",
                  color: Colors.blue,
                ),
              ),
              Expanded(
                child: _statCard(
                  title: "Rayons Actifs",
                  value: "$rayonsActifs",
                  subtitle: "Actifs",
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _statCard(
                  title: "Alertes Stock",
                  value: "$alertesStock",
                  subtitle: "Alertes",
                  color: Colors.orange,
                ),
              ),
              Expanded(
                child: _statCard(
                  title: "Rayons Pleins",
                  value: "$rayonsPleins",
                  subtitle: "Pleins",
                  color: Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ✅ BOUTON VERS LISTE ARTICLES
  Widget _buildBoutonArticles() {
    return SizedBox(
      width: double.infinity,
      height: 60,  // ✅ Hauteur fixe pour cohérence
      child: ElevatedButton.icon(
        onPressed: () async {
          // ✅ LOADING + NAVIGATION FLUIDE
          HapticFeedback.lightImpact();  // Vibration Android

          // Animation scale bouton
          final controller = AnimationController(
            duration: Duration(milliseconds: 150),
            vsync: Navigator.of(context),
          );
          Animation<double> scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeInOut),
          );

          controller.forward();

          await Future.delayed(Duration(milliseconds: 150));
          controller.reverse();
          controller.dispose();

          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => ListeProduitsPage(
                magasinId: widget.magasinId,
                magasinNom: widget.magasinNom,
                token: widget.token,
                nomUtilisateur: widget.nomUtilisateur,
              ),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(begin: Offset(0, 0.1), end: Offset.zero)
                      .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
                  child: child,
                );
              },
              transitionDuration: Duration(milliseconds: 300),
            ),
          );
        },
        icon: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.list_alt, color: Colors.white, size: 22),  // Icône moderne
        ),
        label: Text(
          "Voir tous les articles (${widget.magasinId})",  // Magasin ID info
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF1E6FD9),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          elevation: 4,
          shadowColor: Color(0xFF1E6FD9).withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),  // Coins arrondis
          ),
          // Hover/pressed effect
          animationDuration: Duration(milliseconds: 200),
        ),
      ),
    );
  }


  // ✅ MENU DRAWER (comme avant)
  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF1E6FD9)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.store, size: 30, color: const Color(0xFF1E6FD9)),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.nomUtilisateur ?? "Utilisateur",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  widget.magasinNom,
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _drawerItem(Icons.dashboard, "Dashboard", onTap: () {}), // Page actuelle
                _drawerItem(Icons.list, "Articles", onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DashboardMagasinPage(
                        magasinId: widget.magasinId,
                        magasinNom: widget.magasinNom,
                        token: widget.token,
                        nomUtilisateur: widget.nomUtilisateur,
                      ),
                    ),
                  );
                }),
                _drawerItem(Icons.shopping_basket, "Ventes"),
                _drawerItem(Icons.receipt_long, "Recettes"),
                _drawerItem(Icons.access_time, "Reçus"),
                _drawerItem(Icons.logout, "Déconnexion", color: Colors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, {Color? color, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: color ?? const Color(0xFF1E6FD9)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: onTap ?? () => Navigator.pop(context),
    );
  }
}
