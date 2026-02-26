import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/Produit_Detail_Model.dart';
import '../../service/produit_service.dart';  // ✅ SUPPRIMÉ produit_model.dart

class DetailsProduitPage extends StatefulWidget {
  final String produitId;        // ✅ CHANGÉ : String ID
  final String magasinNom;
  final String token;

  const DetailsProduitPage({
    Key? key,
    required this.produitId,     // ✅ CHANGÉ
    required this.magasinNom,
    required this.token,
  }) : super(key: key);

  @override
  State<DetailsProduitPage> createState() => _DetailsProduitPageState();
}

class _DetailsProduitPageState extends State<DetailsProduitPage> {
  late Future<DetailProduit> futureDetails;

  @override
  void initState() {
    super.initState();
    print('👁️ Loading détails pour ID: ${widget.produitId}');  // ✅ CHANGÉ
    futureDetails = ProduitService.getDetailsProduit(widget.produitId, widget.token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Détails Produit',  // ✅ SIMPLIFIÉ (plus widget.produit)
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Color(0xFF1E6FD9),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<DetailProduit>(
        future: futureDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Color(0xFF1E6FD9)));
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return _errorWidget(snapshot.error);
          }

          final details = snapshot.data!;
          print('✅ DÉTAILS CHARGÉS: ${details.designation}');

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                _heroPhoto(details),
                SizedBox(height: 24),
                _statsPrincipales(details),
                SizedBox(height: 24),
                _alertesCard(details.alertes),
                SizedBox(height: 24),
                _actionsRow(details),
                SizedBox(height: 24),
                _mouvementsSection(details),
                SizedBox(height: 24),
                _receptionsSection(details),
                SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _heroPhoto(DetailProduit details) {
    return Container(
      height: 240,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 6))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: details.photoUrl?.isNotEmpty == true
            ? Image.network(
          details.photoUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => _placeholderImage(),
        )
            : _placeholderImage(),
      ),
    );
  }

  Widget _placeholderImage() => Container(
    color: Colors.grey[300],
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.inventory_2, size: 48, color: Colors.grey[400]),
        SizedBox(height: 8),
        Text('Pas de photo', style: TextStyle(color: Colors.grey[600])),
      ],
    ),
  );

  Widget _statsPrincipales(DetailProduit details) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Expanded(child: _statCard('Référence', details.reference, Icons.label)),
          SizedBox(width: 12),
          Expanded(child: _statCard('Stock', '${details.quantiteActuelle}', Icons.inventory)),
          SizedBox(width: 12),
          Expanded(child: _statCard('Prix', '${details.prixUnitaire} FC', Icons.attach_money)),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon) => Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
    ),
    child: Column(
      children: [
        Icon(icon, color: Color(0xFF1E6FD9), size: 28),
        SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    ),
  );

  Widget _alertesCard(Alertes alertes) {
    final isAlert = alertes.stockBas;
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isAlert
              ? [Colors.orange.shade50, Colors.orange.shade100]
              : [Colors.green.shade50, Colors.green.shade100],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isAlert ? Colors.orange : Colors.green, width: 2),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Row(
        children: [
          Icon(
            isAlert ? Icons.warning_amber_rounded : Icons.check_circle_rounded,
            color: isAlert ? Colors.orange[700] : Colors.green[700],
            size: 36,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stock ${isAlert ? '⚠️ Alerte' : '✅ OK'}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text('Niveau: ${alertes.niveau.toUpperCase()}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionsRow(DetailProduit details) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.trending_down, color: Colors.white),
              label: Text('Sortie Stock', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade500,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.trending_up, color: Colors.white),
              label: Text('Entrée Stock', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade500,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mouvementsSection(DetailProduit details) {
    return _sectionCard(
      '📊 Mouvements Récents',
      Icons.history,
      details.mouvements.take(3).map((m) => _mouvementTile(m)).toList(),
    );
  }

  Widget _mouvementTile(Mouvement m) => ListTile(
    dense: true,
    leading: CircleAvatar(
      radius: 16,
      backgroundColor: Colors.blue.shade100,
      child: Icon(Icons.move_to_inbox, color: Colors.blue[700], size: 18),
    ),
    title: Text(m.type, style: TextStyle(fontWeight: FontWeight.w500)),
    subtitle: Text('${m.quantite} unités - ${m.fournisseur}'),
    trailing: Icon(Icons.arrow_forward_ios, size: 16),
  );

  Widget _receptionsSection(DetailProduit details) {
    if (details.receptions.isEmpty) return SizedBox();
    return _sectionCard(
      '📦 Réceptions & Lots',
      Icons.inventory_2,
      details.receptions.map((r) => _receptionTile(r)).toList(),
    );
  }

  Widget _receptionTile(Reception r) => ExpansionTile(
    leading: CircleAvatar(
      radius: 16,
      backgroundColor: Colors.green.shade100,
      child: Icon(Icons.receipt_long, color: Colors.green[700], size: 18),
    ),
    title: Text(r.lotNumber, style: TextStyle(fontWeight: FontWeight.w500)),
    subtitle: Text('${r.fournisseur} (${r.lots.length} lots)'),
    children: r.lots.map((l) => ListTile(
      dense: true,
      title: Text('${l.quantiteRestante} ${l.uniteDetail}'),
    )).toList(),
  );

  Widget _sectionCard(String title, IconData icon, List<Widget> children) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(0xFF1E6FD9).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: Color(0xFF1E6FD9)),
                  ),
                  SizedBox(width: 12),
                  Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 16),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _errorWidget(dynamic error) => Center(
    child: Padding(
      padding: EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
          SizedBox(height: 16),
          Text('Erreur chargement', style: TextStyle(fontSize: 20, color: Colors.red)),
          SizedBox(height: 8),
          Text(error?.toString() ?? 'Inconnu'),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => setState(() {
              futureDetails = ProduitService.getDetailsProduit(widget.produitId, widget.token);  // ✅ CHANGÉ
            }),
            icon: Icon(Icons.refresh),
            label: Text('Réessayer'),
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF1E6FD9)),
          ),
        ],
      ),
    ),
  );
}
