import 'package:flutter/material.dart';
import 'package:stockmanager/presentation/interfaces/reception_stock_page.dart';
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
  List<Produit> produits = [];  // ✅ LISTE au lieu de Future
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _chargerProduits();
  }

  Future<void> _chargerProduits() async {
    setState(() => isLoading = true);
    try {
      final liste = await ProduitService.getProduits(widget.magasinId, widget.token);
      setState(() {
        produits = liste;
        print('✅ ${produits.length} PRODUITS CHARGÉS');
      });
    } catch (e) {
      print('❌ ERREUR: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
              child: Column(children: [
                Icon(Icons.add_business, size: 48, color: Colors.green),
                SizedBox(height: 12),
                Text("Ajouter au magasin", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(widget.magasinNom, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
              ]),
            ),
            SizedBox(height: 24),
            // AJOUTER PRODUIT
            GestureDetector(
              onTap: () async {
                Navigator.pop(context);
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AjoutProduitPage(
                      magasinId: widget.magasinId,
                      magasinNom: widget.magasinNom,
                      token: widget.token,
                    ),
                  ),
                );
                if (result == true) _chargerProduits();  // ✅ RECHARGE AUTO
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                margin: EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF1E6FD9), Color(0xFF2563EB)]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 12, offset: Offset(0, 6))],
                ),
                child: Row(children: [
                  Container(padding: EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.inventory_2, color: Colors.white, size: 28)),
                  SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text("➕ Ajouter Produit", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("Nouveau produit complet", style: TextStyle(color: Colors.white70, fontSize: 14)),
                  ])),
                  Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
                ]),
              ),
            ),
            // RÉCEPTION STOCK



            // 👇 REMPLACEZ cette partie dans _showAddOptions()
            GestureDetector(
              onTap: () async {
                Navigator.pop(context);  // Ferme BottomSheet
                final result = await Navigator.push<bool>(  // ✅ OUVRE PAGE
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReceptionStockPage(
                      magasinId: widget.magasinId,
                      magasinNom: widget.magasinNom,
                      token: widget.token,
                    ),
                  ),
                );
                if (result == true) {
                  _chargerProduits();  // ✅ Refresh liste après réception
                }
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  border: Border.all(color: Colors.green, width: 2),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.2), blurRadius: 12, offset: Offset(0, 6))],
                ),
                child: Row(children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12)
                    ),
                    child: Icon(Icons.trending_up, color: Colors.green, size: 28),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            "📦 Réception Stock",
                            style: TextStyle(
                                color: Colors.green[800],
                                fontSize: 18,
                                fontWeight: FontWeight.bold
                            )
                        ),
                        Text(
                            "Augmenter stock existant",
                            style: TextStyle(color: Colors.green[600], fontSize: 14)
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: Colors.green[600], size: 20),
                ]),
              ),
            ),






            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.magasinNom} - Articles"),
        backgroundColor: Color(0xFF1E6FD9),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _chargerProduits, tooltip: 'Actualiser'),
        ],
      ),
      drawer: _buildDrawer(),
      body: RefreshIndicator(
        onRefresh: _chargerProduits,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : produits.isEmpty
            ? Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text("Aucun produit trouvé", style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            ElevatedButton(onPressed: _chargerProduits, child: Text('Recharger')),
          ]),
        )
            : Column(children: [
          _buildHeaderTable(),
          Expanded(child: _buildTableProduits()),
        ]),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddOptions,
        backgroundColor: Color(0xFF1E6FD9),
        icon: Icon(Icons.add, color: Colors.white, size: 28),
        label: Text("Ajouter", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildHeaderTable() {
    return Container(
      color: Color(0xFF06014C),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(children: [
        Expanded(flex: 4, child: Text("Réf/Désignation", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white))),
        Expanded(flex: 1, child: Text("Qté", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white))),
        Expanded(flex: 3, child: Text("Emplacement", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white))),
        Expanded(flex: 2, child: Text("État", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white))),
        Expanded(flex: 1, child: Text("Action", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white))),
      ]),
    );
  }

  Widget _buildTableProduits() {
    return ListView.builder(
      itemCount: produits.length,
      itemBuilder: (context, index) {
        final p = produits[index];
        final etat = _getEtatStock(p);
        final colorEtat = _getEtatColor(etat);

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: EdgeInsets.only(left: 0, bottom: 4),
              child: Text(p.reference ?? '', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Expanded(
                flex: 4,
                child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                  (p.photoUrl ?? '').isNotEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(p.photoUrl!, height: 40, width: 40, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(height: 40, width: 40, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.image_not_supported, size: 20))),
                  )
                      : Container(height: 40, width: 40, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.image_not_supported, size: 20)),
                  SizedBox(width: 8),
                  Expanded(child: Text(p.designation ?? '', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)),
                ]),
              ),
              Expanded(flex: 1, child: Text("${p.quantiteActuelle ?? 0}", textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
              Expanded(flex: 3, child: Text(p.rayonId?.nomRayon ?? '', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)),
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: colorEtat.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                  child: Text(etat, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: colorEtat, fontWeight: FontWeight.bold)),
                ),
              ),
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DetailsProduitPage(produitId: p.id!, magasinNom: widget.magasinNom, token: widget.token))),
                  child: Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: Color(0xFF1E6FD9), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.visibility, size: 18, color: Colors.white)),
                ),
              ),
            ]),
          ]),
        );
      },
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(children: [
        DrawerHeader(
          decoration: BoxDecoration(color: Color(0xFF1E6FD9)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            CircleAvatar(radius: 30, backgroundColor: Colors.white, child: Icon(Icons.store, size: 30, color: Color(0xFF1E6FD9))),
            SizedBox(height: 10),
            Text(widget.nomUtilisateur ?? "Utilisateur", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(widget.magasinNom, style: TextStyle(fontSize: 14, color: Colors.white70)),
          ]),
        ),
        Expanded(child: ListView(padding: EdgeInsets.zero, children: [
          _drawerItem(Icons.dashboard, "Dashboard", onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => DashboardMagasinPage(magasinId: widget.magasinId, magasinNom: widget.magasinNom, token: widget.token, nomUtilisateur: widget.nomUtilisateur)));
          }),
          _drawerItem(Icons.list, "Articles"),
          _drawerItem(Icons.shopping_basket, "Ventes"),
          _drawerItem(Icons.receipt_long, "Recettes"),
          _drawerItem(Icons.logout, "Déconnexion", color: Colors.red),
        ])),
      ]),
    );
  }

  Widget _drawerItem(IconData icon, String title, {Color? color, VoidCallback? onTap}) {
    return ListTile(leading: Icon(icon, color: color ?? Color(0xFF1E6FD9)), title: Text(title, style: TextStyle(fontWeight: FontWeight.w500)), onTap: onTap ?? () => Navigator.pop(context));
  }

  String _getEtatStock(Produit p) {
    if (p.quantiteActuelle == 0) return "Rupture";
    return "En stock";
  }

  Color _getEtatColor(String etat) {
    switch (etat) {
      case "Rupture": return Colors.red;
      case "Alerte": return Colors.orange;
      case "En stock": return Colors.green;
      default: return Colors.green;
    }
  }
}
