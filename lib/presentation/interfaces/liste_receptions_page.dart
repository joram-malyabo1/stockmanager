import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ⚠️ Ajustez les imports selon votre projet
import '../../service/produit_service.dart';
import '../../models/reception_model.dart';
import '../../core/delayed_animation.dart'; // Si vous l'avez dans un fichier séparé, sinon remettez la classe en bas

class ListeReceptionsPage extends StatefulWidget {
  final String magasinId;
  final String token;

  const ListeReceptionsPage({
    Key? key,
    required this.magasinId,
    required this.token,
  }) : super(key: key);

  @override
  State<ListeReceptionsPage> createState() => _ListeReceptionsPageState();
}

class _ListeReceptionsPageState extends State<ListeReceptionsPage> {
  bool isLoading = true;
  List<Reception> receptions = [];

  @override
  void initState() {
    super.initState();
    _chargerReceptions();
  }

  Future<void> _chargerReceptions() async {
    setState(() => isLoading = true);
    try {
      final List<Reception> liste = await ProduitService.getReceptions(widget.magasinId, widget.token); // ignore: unnecessary_await
      if (mounted) {
        setState(() {
          receptions = liste;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- Design des badges de statut ---
  Widget _buildBadge(String texte, Color couleur) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: couleur.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: couleur.withOpacity(0.5)),
      ),
      child: Text(
        texte.toUpperCase(),
        style: TextStyle(color: couleur, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Color _getCouleurStatut(String statut) {
    switch (statut.toLowerCase()) {
      case 'stocké':
      case 'stocke':
      case 'validé':
        return Colors.green;
      case 'controle':
      case 'en_attente':
        return Colors.orange;
      case 'rejetter':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Historique des Réceptions', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E6FD9),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _chargerReceptions,
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1E6FD9)))
          : receptions.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text("Aucune réception trouvée.", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _chargerReceptions,
        color: const Color(0xFF1E6FD9),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: receptions.length,
          itemBuilder: (context, index) {
            final r = receptions[index];
            final isLot = r.nombrePieces != null && r.nombrePieces! > 0;

            return DelayedAnimation(
              delay: (index * 100).clamp(100, 800), // Apparition en cascade
              child: Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- IMAGE ---
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: r.photoUrl.isNotEmpty
                              ? Image.network(
                            r.photoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.image_not_supported, color: Colors.grey),
                          )
                              : const Icon(Icons.inventory_2, color: Colors.grey, size: 40),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // --- DÉTAILS ---
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Ligne 1 : Nom et Statut
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    r.produitNom,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                _buildBadge(r.statut, _getCouleurStatut(r.statut)),
                              ],
                            ),
                            const SizedBox(height: 4),

                            // Ligne 2 : Fournisseur et Date
                            Row(
                              children: [
                                const Icon(Icons.store, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  r.fournisseur,
                                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                                ),
                                const Spacer(),
                                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  r.dateReception != null ? DateFormat('dd/MM/yyyy').format(r.dateReception!) : '--/--/----',
                                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Divider(height: 1),
                            const SizedBox(height: 8),

                            // Ligne 3 : Quantité (Gère Simple et Lot) et Prix
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Quantité", style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                                    if (isLot)
                                      Text(
                                        "${r.nombrePieces} Pièces (${r.quantite} Total)",
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E6FD9)),
                                      )
                                    else
                                      Text(
                                        "${r.quantite}",
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E6FD9)),
                                      ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text("Coût Total", style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                                    Text(
                                      "${r.prixTotal.toStringAsFixed(0)} FG",
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                                    ),
                                  ],
                                ),
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
}