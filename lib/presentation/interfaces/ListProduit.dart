import 'package:flutter/material.dart';
import '../../core/delayed_animation.dart';
import '../../models/produit_model.dart';
import '../../service/produit_service.dart';
import 'DetailsProduitPage.dart';
import 'reception_stock_page.dart';
// On cache DelayedAnimation ici car il est déjà dans core/delayed_animation.dart
import 'ajout_produit_page.dart' hide DelayedAnimation;

class ListeProduitsPage extends StatefulWidget {
  final String magasinId;
  final String magasinNom;
  final String token;
  final String guichetId;
  final String utilisateurId;
  final String? nomUtilisateur;

  const ListeProduitsPage({
    Key? key,
    required this.magasinId,
    required this.magasinNom,
    required this.token,
    required this.guichetId,
    required this.utilisateurId,
    this.nomUtilisateur = "Utilisateur",
  }) : super(key: key);

  @override
  State<ListeProduitsPage> createState() => _ListeProduitsPageState();
}

class _ListeProduitsPageState extends State<ListeProduitsPage> {
  List<Produit> produits = [];
  bool isLoading = false;
  final Color orangeMax = const Color(0xFFFF7900);

  @override
  void initState() {
    super.initState();
    _chargerProduits();
  }

  Future<void> _chargerProduits() async {
    setState(() => isLoading = true);
    try {
      final liste = await ProduitService.getProduits(widget.magasinId, widget.token);
      if (mounted) {
        setState(() {
          produits = liste.where((p) => !p.estSupprime).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // --- APP BAR ARRONDIE ET PRO ---
  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(100),
      child: DelayedAnimation(
        delay: 0,
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              color: orangeMax,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(35),
                bottomRight: Radius.circular(35),
              ),
            ),
            child: SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.magasinNom,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                      child: Text("${produits.length} Articles en stock", style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _chargerProduits)
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          const SizedBox(height: 15),
          _buildHeaderTable(),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: orangeMax))
                : ListView.builder(
              padding: const EdgeInsets.only(bottom: 80, left: 10, right: 10),
              itemCount: produits.length,
              itemBuilder: (context, index) {
                return DelayedAnimation(
                  delay: 150 + (index * 60),
                  child: _buildProduitRow(produits[index]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProfessionalBottomSheet(context),
        backgroundColor: orangeMax,
        elevation: 4,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Ajouter", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // --- ENTÊTE DU TABLEAU ---
  Widget _buildHeaderTable() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFF0D084B), borderRadius: BorderRadius.circular(12)),
      child: const Row(
        children: [
          Expanded(flex: 4, child: Text("Réf/Désignation", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
          Expanded(flex: 1, child: Text("Qté", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
          Expanded(flex: 2, child: Text("Rayon", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
          Expanded(flex: 2, child: Text("État", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
          SizedBox(width: 35, child: Text("Dét", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
        ],
      ),
    );
  }

  // --- LIGNE DE PRODUIT (STYLE TABLEAU) ---
  Widget _buildProduitRow(Produit p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          // DESIGNATION ET PHOTO
          Expanded(
            flex: 4,
            child: Row(
              children: [
                _buildProductImage(p.photoUrl),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.designation, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(p.reference, style: TextStyle(color: Colors.grey[500], fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // QUANTITE
          Expanded(
            flex: 1,
            child: Text("${p.quantiteActuelle}", textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          // RAYON
          Expanded(
            flex: 2,
            child: Text(p.rayonId.nomRayon, textAlign: TextAlign.center, style: TextStyle(color: Colors.blueGrey[700], fontSize: 11)),
          ),
          // ETAT (BADGE)
          Expanded(
            flex: 2,
            child: _buildStatusBadge(p),
          ),
          // BOUTON ACTION (OEIL) AVEC MENU
          SizedBox(
            width: 35,
            child: PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.visibility, color: Color(0xFF1E6FD9), size: 22),
              onSelected: (val) => _handleAction(val, p),
              itemBuilder: (context) => [
                _buildMenuItem('voir', Icons.info_outline, "Voir Détails", Colors.blue),
                _buildMenuItem('reception', Icons.download_for_offline, "Réception Stock", Colors.green),
                _buildMenuItem('edit', Icons.edit_note, "Modifier", Colors.orange),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(String? url) {
    return Container(
      width: 35, height: 35,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), color: Colors.grey[100]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: url != null && url.isNotEmpty
            ? Image.network(url, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image_not_supported, size: 15))
            : const Icon(Icons.inventory_2, size: 15, color: Colors.grey),
      ),
    );
  }

  Widget _buildStatusBadge(Produit p) {
    String txt = p.quantiteActuelle <= 0 ? "Rupture" : (p.quantiteActuelle <= p.seuilAlerte ? "Bas" : "En Stock");
    Color color = p.quantiteActuelle <= 0 ? Colors.red : (p.quantiteActuelle <= p.seuilAlerte ? Colors.orange : Colors.green);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.5))),
      child: Text(txt, textAlign: TextAlign.center, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }

  PopupMenuItem<String> _buildMenuItem(String val, IconData icon, String txt, Color color) {
    return PopupMenuItem(
      value: val,
      child: Row(children: [Icon(icon, color: color, size: 20), const SizedBox(width: 10), Text(txt, style: const TextStyle(fontSize: 13))]),
    );
  }

  void _handleAction(String action, Produit p) {
    if (action == 'voir') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => DetailsProduitPage(produitId: p.id, magasinNom: widget.magasinNom, token: widget.token)));
    } else if (action == 'reception') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => ReceptionStockPage(magasinId: widget.magasinId, magasinNom: widget.magasinNom, token: widget.token, produitInitial: p)));
    }
  }

  // --- BOTTOM SHEET PROFESSIONNEL ---
  void _showProfessionalBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 25),
            const Text("Nouvelle Action", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text("Choisissez une option pour continuer", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            const SizedBox(height: 30),

            // OPTION 1 : AJOUTER PRODUIT
            // --- OPTION 1 : AJOUTER PRODUIT ---
            _buildOptionCard(
              title: "Créer un Produit",
              desc: "Ajouter une nouvelle référence au catalogue",
              icon: Icons.add_business_rounded,
              color: const Color(0xFF1E6FD9),
              onTap: () async { // 1. Ajoutez 'async' ici
                Navigator.pop(context); // Ferme le BottomSheet

                // 2. Attendez le résultat de la page d'ajout
                final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => AjoutProduitPage(
                            magasinId: widget.magasinId,
                            magasinNom: widget.magasinNom,
                            token: widget.token
                        )
                    )
                );

                // 3. Si le produit a été créé avec succès (result == true)
                if (result == true) {
                  _chargerProduits(); // Rafraîchit la liste
                }
              },
            ),

            const SizedBox(height: 15),

            // OPTION 2 : RECEPTION STOCK
            // --- OPTION 2 : RECEPTION STOCK ---
            _buildOptionCard(
              title: "Réception de Stock",
              desc: "Enregistrer une entrée de marchandises",
              icon: Icons.archive_rounded,
              color: Colors.green,
              onTap: () async { // Ajoutez async
                Navigator.pop(context);
                final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ReceptionStockPage(
                            magasinId: widget.magasinId,
                            magasinNom: widget.magasinNom,
                            token: widget.token
                        )
                    )
                );

                if (result == true) {
                  _chargerProduits(); // Rafraîchit aussi après une réception
                }
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({required String title, required String desc, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(15),
          color: Colors.grey.shade50,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(desc, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}