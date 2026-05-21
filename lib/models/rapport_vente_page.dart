import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../service/rapport_service.dart';
import '../models/movement_model.dart';
import '../core/delayed_animation.dart'; // Assurez-vous d'avoir ce fichier pour l'animation

class RapportVentePage extends StatefulWidget {
  final String magasinId;
  final String token;

  const RapportVentePage({Key? key, required this.magasinId, required this.token}) : super(key: key);

  @override
  _RapportVentePageState createState() => _RapportVentePageState();
}

class _RapportVentePageState extends State<RapportVentePage> {
  final Color orangeMax = const Color(0xFFFF7900);
  final Color bleuNuit = const Color(0xFF0D084B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("HISTORIQUE & FLUX", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: bleuNuit,
        elevation: 0,
      ),
      body: FutureBuilder<List<StockMovement>>(
        future: RapportService.getMovements(widget.magasinId, widget.token),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: orangeMax));
          }
          if (snapshot.hasError) {
            return Center(child: Text("Erreur : ${snapshot.error}"));
          }

          final movements = snapshot.data ?? [];

          return Column(
            children: [
              _buildSummaryHeader(movements),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: movements.length,
                  itemBuilder: (context, index) {
                    final m = movements[index];
                    return DelayedAnimation(
                      delay: 100 + (index * 50), // Animation en cascade
                      child: _buildMovementCard(m),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Header avec petit résumé
  Widget _buildSummaryHeader(List<StockMovement> list) {
    int ventes = list.where((m) => m.type == "SORTIE").length;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bleuNuit,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem("Mouvements", list.length.toString(), Colors.white),
          _statItem("Ventes (Sorties)", ventes.toString(), orangeMax),
        ],
      ),
    );
  }

  Widget _statItem(String label, String val, Color color) {
    return Column(
      children: [
        Text(val, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  // Carte de mouvement individuelle
  Widget _buildMovementCard(StockMovement m) {
    bool isSortie = m.type == "SORTIE";

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Icone directionelle
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSortie ? orangeMax.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSortie ? Icons.arrow_upward : Icons.arrow_downward,
                color: isSortie ? orangeMax : Colors.green,
                size: 20,
              ),
            ),
            const SizedBox(width: 15),

            // Infos produit
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m.designation.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, color: bleuNuit, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(m.observations, style: TextStyle(color: Colors.grey[600], fontSize: 11, fontStyle: FontStyle.italic)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.person, size: 12, color: orangeMax),
                      const SizedBox(width: 4),
                      Text(m.utilisateur, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),

            // Quantité et Date
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${isSortie ? '-' : '+'}${m.quantite.toInt()}",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isSortie ? orangeMax : Colors.green
                  ),
                ),
                Text(
                  DateFormat('dd/MM HH:mm').format(m.date),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                      color: bleuNuit.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(4)
                  ),
                  child: Text(m.type, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: bleuNuit)),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}