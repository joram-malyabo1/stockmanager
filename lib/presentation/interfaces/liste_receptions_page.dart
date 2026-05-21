import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../service/produit_service.dart';
import '../../models/reception_model.dart';
import '../../core/delayed_animation.dart';
import 'reception_stock_page.dart';

class ListeReceptionsPage extends StatefulWidget {
  final String magasinId;
  final String token;
  final String magasinNom;
  final String? guichetId;
  final String? utilisateurId;
  final String? nomUtilisateur;

  const ListeReceptionsPage({
    Key? key,
    required this.magasinId,
    required this.token,
    this.magasinNom = "Magasin",
    this.guichetId,
    this.utilisateurId,
    this.nomUtilisateur = "Utilisateur",
  }) : super(key: key);

  @override
  State<ListeReceptionsPage> createState() => _ListeReceptionsPageState();
}

class _ListeReceptionsPageState extends State<ListeReceptionsPage> {
  bool isLoading = true;
  List<Reception> receptions = [];

  final Color orangeMax = const Color(0xFFFF7900);
  final Color bleuNuit = const Color(0xFF0D084B);

  @override
  void initState() {
    super.initState();
    _chargerReceptions();
  }

  // ✅ RETOUR À LA VERSION ORIGINALE (SANS GROUPEMENT)
  Future<void> _chargerReceptions() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final List<Reception> liste = await ProduitService.getReceptions(widget.magasinId, widget.token);
      if (mounted) {
        setState(() {
          receptions = liste;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ✅ FONCTION POUR AFFICHER LES OPTIONS (MODIFIER/SUPPRIMER)
  void _afficherOptions(Reception r) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
            ),
            Text(
              r.produitNom,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: bleuNuit),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: CircleAvatar(backgroundColor: Colors.blue.withOpacity(0.1), child: const Icon(Icons.edit, color: Colors.blue)),
              title: const Text("Modifier cette réception", style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text("Changer les quantités, prix ou fournisseur"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReceptionStockPage(
                      magasinId: widget.magasinId,
                      magasinNom: widget.magasinNom,
                      token: widget.token,
                      receptionInitiale: r,
                    ),
                  ),
                ).then((_) => _chargerReceptions());
              },
            ),
            const Divider(),
            ListTile(
              leading: CircleAvatar(backgroundColor: Colors.red.withOpacity(0.1), child: const Icon(Icons.delete_forever, color: Colors.red)),
              title: const Text("Supprimer", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                // Logique de suppression ici si nécessaire
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        backgroundColor: bleuNuit,
        elevation: 0,
        centerTitle: true,
        title: Text('HISTORIQUE RÉCEPTIONS', style: TextStyle(color: orangeMax, fontWeight: FontWeight.w900, fontSize: 16)),
        actions: [IconButton(icon: const Icon(Icons.refresh, color: Colors.white70), onPressed: _chargerReceptions)],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: orangeMax))
          : receptions.isEmpty
          ? Center(child: Text("Aucun historique trouvé", style: TextStyle(color: Colors.grey[500], fontSize: 16, fontWeight: FontWeight.bold)))
          : RefreshIndicator(
        onRefresh: _chargerReceptions,
        color: orangeMax,
        child: ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: receptions.length,
          itemBuilder: (context, index) {
            final r = receptions[index];

            // Calculs pour l'affichage
            final bool isLot = (r.nombrePieces != null && r.nombrePieces! > 1);
            double piecesParLot = isLot ? (r.quantite / r.nombrePieces!) : 1;
            double prixParUnite = (r.quantite > 0) ? (r.prixTotal / r.quantite) : 0;
            double prixDunLot = prixParUnite * piecesParLot;

            return DelayedAnimation(
              delay: 100 + (index * 50),
              child: GestureDetector(
                onTap: () => _afficherOptions(r),
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey.shade200)),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.all(15),
                        leading: CircleAvatar(backgroundColor: orangeMax.withOpacity(0.1), child: Icon(isLot ? Icons.layers : Icons.inventory_2, color: orangeMax)),
                        title: Text(r.produitNom, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        subtitle: Text("Fournisseur: ${r.fournisseur}", style: const TextStyle(fontSize: 11)),
                        trailing: _badge(isLot ? "📦 LOT" : "⚖️ SIMPLE", isLot ? Colors.purple : Colors.blueGrey),
                      ),
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(color: orangeMax.withOpacity(0.05), borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _detailCol("SITUATION STOCK", isLot
                                    ? "${r.nombrePieces} Lots x ${piecesParLot.toStringAsFixed(0)} pcs"
                                    : "Total : ${r.quantite.toStringAsFixed(0)} pièces"),
                                _detailCol("UNITÉS TOTALES", "${r.quantite.toStringAsFixed(0)} pcs"),
                              ],
                            ),
                            const Divider(height: 25),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _detailCol("PRIX UNITAIRE", "${prixParUnite.toStringAsFixed(0)} FG", highlight: true),
                                _detailCol(isLot ? "PRIX DU LOT" : "VALEUR TOTALE", isLot
                                    ? "${prixDunLot.toStringAsFixed(0)} FG"
                                    : "${r.prixTotal.toStringAsFixed(0)} FG", highlight: true),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _detailCol(String label, String value, {bool highlight = false}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey[600])),
      Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: highlight ? orangeMax : bleuNuit)),
    ],
  );

  Widget _badge(String t, Color c) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: c.withOpacity(0.4))), child: Text(t, style: TextStyle(color: c, fontSize: 8, fontWeight: FontWeight.bold)));
}