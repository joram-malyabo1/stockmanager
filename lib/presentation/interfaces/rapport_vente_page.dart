import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stockmanager/core/delayed_animation.dart';
import 'package:stockmanager/models/movement_model.dart';
import 'package:stockmanager/service/rapport_service.dart';


class RapportVentePage extends StatefulWidget {
  final String magasinId;
  final String token;
  const RapportVentePage({Key? key, required this.magasinId, required this.token}) : super(key: key);

  // ... reste du code ...

  @override
  _RapportVentePageState createState() => _RapportVentePageState();
}

class _RapportVentePageState extends State<RapportVentePage> {
  final Color orangeMax = const Color(0xFFFF7900);
  final Color bleuNuit = const Color(0xFF0D084B);

  List<StockMovement> allMovements = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _chargerDonnees();
  }

  Future<void> _chargerDonnees() async {
    setState(() => isLoading = true);
    try {
      final data = await RapportService.getMovements(widget.magasinId, widget.token);
      setState(() {
        allMovements = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // On définit le contrôleur d'onglets (3 onglets : Ventes, Réceptions, Initialisation)
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: bleuNuit,
          title: const Text("RAPPORTS DÉTAILLÉS", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          elevation: 0,
          bottom: TabBar(
            indicatorColor: orangeMax,
            indicatorWeight: 3,
            labelColor: orangeMax,
            unselectedLabelColor: Colors.white60,
            tabs: const [
              Tab(icon: Icon(Icons.shopping_bag), text: "VENTES"),
              Tab(icon: Icon(Icons.local_shipping), text: "RÉCEPTIONS"),
              Tab(icon: Icon(Icons.inventory), text: "INITIAL"),
            ],
          ),
          actions: [
            IconButton(onPressed: _chargerDonnees, icon: const Icon(Icons.refresh, color: Colors.white))
          ],
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator(color: orangeMax))
            : TabBarView(
          children: [
            _buildTabContent("SORTIE"),            // Onglet Ventes
            _buildTabContent("RECEPTION"),         // Onglet Réceptions
            _buildTabContent("ENTREE_INITIALE"),   // Onglet Initialisation
          ],
        ),
      ),
    );
  }

  // Générateur de contenu pour chaque onglet
  Widget _buildTabContent(String type) {
    final filteredList = allMovements.where((m) => m.type == type).toList();

    // Calcul du total pour cet onglet spécifique
    double totalQte = filteredList.fold(0, (sum, item) => sum + item.quantite);

    if (filteredList.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // En-tête de résumé spécifique à l'onglet
        _buildSectionHeader(type, filteredList.length, totalQte),

        // Liste des mouvements
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            itemCount: filteredList.length,
            itemBuilder: (context, index) {
              return DelayedAnimation(
                delay: 100 + (index * 50),
                child: _buildMovementCard(filteredList[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  // Header bleu ciel / blanc pour le résumé de l'onglet
  Widget _buildSectionHeader(String type, int count, double total) {
    String label = "";
    Color iconColor = bleuNuit;
    if (type == "SORTIE") { label = "Articles vendus"; iconColor = orangeMax; }
    else if (type == "RECEPTION") { label = "Articles reçus"; iconColor = Colors.green; }
    else { label = "Stock de départ"; iconColor = Colors.blue; }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              const SizedBox(height: 5),
              Text("${total.toInt()} PCS", style: TextStyle(color: bleuNuit, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Text("$count Opérations", style: TextStyle(color: iconColor, fontWeight: FontWeight.bold, fontSize: 12)),
          )
        ],
      ),
    );
  }

  // Carte de mouvement stylisée
  Widget _buildMovementCard(StockMovement m) {
    bool isSortie = m.type == "SORTIE";
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Colors.grey[200]!)
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50, height: 50,
          decoration: BoxDecoration(
              color: isSortie ? orangeMax.withOpacity(0.1) : Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12)
          ),
          child: Icon(
            isSortie ? Icons.outbox : Icons.move_to_inbox,
            color: isSortie ? orangeMax : Colors.green,
          ),
        ),
        title: Text(m.designation.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, color: bleuNuit, fontSize: 13)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Text(m.observations, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.access_time, size: 12, color: orangeMax),
                const SizedBox(width: 5),
                Text(DateFormat('dd/MM/yyyy HH:mm').format(m.date), style: const TextStyle(fontSize: 10)),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "${isSortie ? '-' : '+'}${m.quantite.toInt()}",
              style: TextStyle(color: isSortie ? orangeMax : Colors.green, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const Text("Pièces", style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insert_chart_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 10),
          Text("Aucune donnée pour cette catégorie", style: TextStyle(color: Colors.grey[400])),
        ],
      ),
    );
  }
}