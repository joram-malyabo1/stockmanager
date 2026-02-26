import 'package:flutter/material.dart';
import '../../models/produit_model.dart';
import '../../service/produit_service.dart';
import 'DetailsProduitPage.dart';
import 'ajout_produit_page.dart';
import 'details_magasin_page.dart';

class ListeProduitsPage extends StatefulWidget {
  final String magasinId;
  final String magasinNom;
  final String token;
  final String? nomUtilisateur;

  const ListeProduitsPage({
    Key? key,
    required this.magasinId,
    required this.magasinNom,
    required this.token,
    this.nomUtilisateur = "Utilisateur",
  }) : super(key: key);

  @override
  State<ListeProduitsPage> createState() => _ListeProduitsPageState();
}

class _ListeProduitsPageState extends State<ListeProduitsPage> {
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
        title: Text("${widget.magasinNom} - Articles"),
        backgroundColor: const Color(0xFF1E6FD9),
        foregroundColor: Colors.white,
      ),
      drawer: _buildDrawer(),
      body: FutureBuilder<List<Produit>>(
        future: futureProduits,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "Aucun produit trouvé",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final produits = snapshot.data!;
          return Column(
            children: [
              _buildHeaderTable(),
              Expanded(child: _buildTableProduits(produits)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AjoutProduitPage(
                magasinId: widget.magasinId,
                magasinNom: widget.magasinNom,
                token: widget.token,
              ),
            ),
          );
        },
        backgroundColor: Color(0xFF1E6FD9),
        child: Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  // ✅ EN-TÊTE DU TABLEAU
  Widget _buildHeaderTable() {
    return Container(
      color: const Color(0xFF06014C),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: const Row(
        children: [
          Expanded(flex: 4, child: Text("Réf/Désignation", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white))),
          Expanded(flex: 1, child: Text("Qté", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white))),
          Expanded(flex: 3, child: Text("Emplacement", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white))),
          Expanded(flex: 2, child: Text("État", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white))),
          Expanded(flex: 1, child: Text("Action", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white))),
        ],
      ),
    );
  }

  // ✅ TABLEAU DES PRODUITS
  Widget _buildTableProduits(List<Produit> produits) {
    return ListView.builder(
      itemCount: produits.length,
      itemBuilder: (context, index) {
        final p = produits[index];
        final etat = _getEtatStock(p);
        final colorEtat = _getEtatColor(etat);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Référence
              Padding(
                padding: const EdgeInsets.only(left: 0, bottom: 4),
                child: Text(
                  p.reference ?? '',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Ligne principale
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Image + Désignation (flex 4)
                  Expanded(
                    flex: 4,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Image 40x40
                        if ((p.photoUrl ?? '').isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              p.photoUrl!,
                              height: 40,
                              width: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.image_not_supported, size: 20),
                                );
                              },
                            ),
                          )
                        else
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.image_not_supported, size: 20),
                          ),
                        const SizedBox(width: 8),
                        // Désignation
                        Expanded(
                          child: Text(
                            p.designation ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // QUANTITÉ
                  Expanded(
                    flex: 1,
                    child: Text(
                      "${p.quantiteActuelle ?? 0}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // EMPLACEMENT
                  Expanded(
                    flex: 3,
                    child: Text(
                      p.rayonId?.nomRayon ?? '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // ÉTAT
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: colorEtat.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        etat,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorEtat,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // ACTION
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      onTap: () {
                        print("🔍 CLIC: ${p.reference}");
                        // Dans _buildTableProduits, onTap:
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailsProduitPage(
                              produitId: p.id!,       // ✅ UTILISEZ 'produitId' au lieu de 'produit'
                              magasinNom: widget.magasinNom,
                              token: widget.token,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E6FD9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.visibility, size: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }


  // ✅ MENU DRAWER
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
                _drawerItem(Icons.dashboard, "Dashboard", onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DashboardMagasinPage( // ← Retour Dashboard
                        magasinId: widget.magasinId,
                        magasinNom: widget.magasinNom,
                        token: widget.token,
                        nomUtilisateur: widget.nomUtilisateur,
                      ),
                    ),
                  );
                }),
                _drawerItem(Icons.list, "Articles"), // Page actuelle
                _drawerItem(Icons.shopping_basket, "Ventes"),
                _drawerItem(Icons.receipt_long, "Recettes"),
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

  // ✅ LOGIQUE ÉTAT STOCK
  String _getEtatStock(Produit p) {
    if (p.quantiteActuelle == 0) return "Rupture";
    if (p.quantiteActuelle <= p.seuilAlerte) return "Alerte";
    return "En stock";
  }

  Color _getEtatColor(String etat) {
    switch (etat) {
      case "Rupture":
        return Colors.red;
      case "Alerte":
        return Colors.orange;
      case "En stock":
      default:
        return Colors.green;
    }
  }
}
