import 'package:flutter/material.dart';
import '../../core/delayed_animation.dart';
import '../../models/Produit_Detail_Model.dart';
import '../../service/produit_service.dart';
import 'ListProduit.dart';
import 'reception_stock_page.dart';
import 'welcome_page.dart';
import 'liste_receptions_page.dart';

class DetailsProduitPage extends StatefulWidget {
  final String produitId;
  final String magasinNom;
  final String token;
  // Paramètres pour le Drawer
  final String? guichetId;
  final String? utilisateurId;
  final String? nomUtilisateur;

  const DetailsProduitPage({
    Key? key,
    required this.produitId,
    required this.magasinNom,
    required this.token,
    this.guichetId,
    this.utilisateurId,
    this.nomUtilisateur = "Utilisateur",
  }) : super(key: key);

  @override
  State<DetailsProduitPage> createState() => _DetailsProduitPageState();
}

class _DetailsProduitPageState extends State<DetailsProduitPage> {
  late Future<DetailProduit> futureDetails;

  // Couleurs du projet
  final Color orangeMax = const Color(0xFFFF7900);
  final Color bleuNuit = const Color(0xFF0D084B);

  @override
  void initState() {
    super.initState();
    futureDetails = ProduitService.getDetailsProduit(widget.produitId, widget.token);
  }

  // --- APP BAR PREMIUM ---
  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(100),
      child: Container(
        decoration: BoxDecoration(
          color: bleuNuit,
          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(35), bottomRight: Radius.circular(35)),
          boxShadow: [BoxShadow(color: bleuNuit.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: SafeArea(
          child: Center(
            child: Text(
              "DÉTAILS DE L'ARTICLE",
              style: TextStyle(color: orangeMax, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.5),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: _buildAppBar(),
      drawer: _buildDrawer(), // ✅ DRAWER RÉINTÉGRÉ
      body: FutureBuilder<DetailProduit>(
        future: futureDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: orangeMax));
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return _errorWidget(snapshot.error);
          }

          final d = snapshot.data!;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            child: Column(
              children: [
                // 📸 HERO PHOTO
                DelayedAnimation(
                  delay: 200,
                  child: _heroPhoto(d),
                ),
                const SizedBox(height: 25),

                // 📝 TITRE & RÉFÉRENCE
                DelayedAnimation(
                  delay: 300,
                  child: Column(
                    children: [
                      Text(d.designation, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: bleuNuit), textAlign: TextAlign.center),
                      const SizedBox(height: 5),
                      Text("RÉFÉRENCE : ${d.reference}", style: TextStyle(color: orangeMax, fontWeight: FontWeight.w900, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // 📊 STATS PRINCIPALES
                _statsGrid(d),
                const SizedBox(height: 25),

                // ⚠️ ALERTE STOCK
                DelayedAnimation(delay: 600, child: _alertBanner(d.alertes)),
                const SizedBox(height: 30),

                // 📊 MOUVEMENTS & RÉCEPTIONS
                _sectionCard("MOUVEMENTS RÉCENTS", Icons.history, d.mouvements.take(3).map((m) => _mouvementTile(m)).toList(), 700),
                const SizedBox(height: 20),

                _sectionCard("RÉCEPTIONS & LOTS", Icons.inventory_2, d.receptions.map((r) => _receptionTile(r)).toList(), 800),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _heroPhoto(DetailProduit d) {
    return Container(
      height: 220, width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: d.photoUrl != null && d.photoUrl!.isNotEmpty
            ? Image.network(d.photoUrl!, fit: BoxFit.cover)
            : Icon(Icons.inventory_2, size: 80, color: Colors.grey[200]),
      ),
    );
  }

  Widget _statsGrid(DetailProduit d) {
    return Row(
      children: [
        Expanded(child: _statCard("STOCK", "${d.quantiteActuelle}", Icons.inventory, 400)),
        const SizedBox(width: 15),
        Expanded(child: _statCard("PRIX UNIT.", "${d.prixUnitaire} FG", Icons.payments, 500)),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, int delay) {
    return DelayedAnimation(
      delay: delay,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]),
        child: Column(
          children: [
            Icon(icon, color: orangeMax, size: 28),
            const SizedBox(height: 12),
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: bleuNuit), textAlign: TextAlign.center),
            Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 10, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }

  Widget _alertBanner(Alertes a) {
    final bool isCritical = a.stockBas;
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: isCritical ? [Colors.red, Colors.orange] : [Colors.green, Colors.teal]),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(isCritical ? Icons.warning_amber_rounded : Icons.verified_user, color: Colors.white),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("SITUATION DU STOCK", style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.bold)),
                Text(isCritical ? "ALERTE : STOCK CRITIQUE" : "STOCK EN BON ÉTAT", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
          Text(a.niveau.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _sectionCard(String title, IconData icon, List<Widget> items, int delay) {
    return DelayedAnimation(
      delay: delay,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: orangeMax, size: 20),
              const SizedBox(width: 10),
              Text(title, style: TextStyle(color: bleuNuit, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
            ]),
            const Divider(height: 30),
            if (items.isEmpty) const Text("Aucune donnée disponible", style: TextStyle(fontSize: 12, color: Colors.grey))
            else ...items,
          ],
        ),
      ),
    );
  }

  Widget _mouvementTile(Mouvement m) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(backgroundColor: bleuNuit.withOpacity(0.1), child: Icon(Icons.swap_horiz, color: bleuNuit, size: 20)),
      title: Text(m.type, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      subtitle: Text("${m.quantite} unités - ${m.fournisseur}", style: const TextStyle(fontSize: 11)),
      trailing: const Icon(Icons.chevron_right, size: 16),
    );
  }

  Widget _receptionTile(Reception r) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      leading: Icon(Icons.bookmark_outline, color: orangeMax),
      title: Text("Lot : ${r.lotNumber}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      subtitle: Text(r.fournisseur, style: const TextStyle(fontSize: 11)),
      children: r.lots.map((l) => ListTile(
        title: Text("${l.quantiteRestante} ${l.uniteDetail} restants", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      )).toList(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 60, bottom: 30, left: 20),
            width: double.infinity, decoration: BoxDecoration(color: bleuNuit, borderRadius: const BorderRadius.only(bottomRight: Radius.circular(50))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const CircleAvatar(radius: 35, backgroundColor: Colors.white, child: Icon(Icons.person, size: 40, color: Color(0xFF0D084B))),
              const SizedBox(height: 15),
              Text(widget.nomUtilisateur ?? "User", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              Text(widget.magasinNom, style: TextStyle(color: orangeMax, fontSize: 12)),
            ]),
          ),
          ListTile(leading: Icon(Icons.dashboard, color: orangeMax), title: const Text("Dashboard"), onTap: () => Navigator.pop(context)),
          ListTile(leading: Icon(Icons.inventory, color: orangeMax), title: const Text("Stock"), onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => ListeProduitsPage(magasinId: "", magasinNom: widget.magasinNom, token: widget.token, guichetId: widget.guichetId!, utilisateurId: widget.utilisateurId!, nomUtilisateur: widget.nomUtilisateur)));
          }),
          const Spacer(),
          const Divider(),
          ListTile(leading: const Icon(Icons.logout, color: Colors.red), title: const Text("Déconnexion", style: TextStyle(color: Colors.red)), onTap: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const WelcomePage()), (r) => false)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _errorWidget(dynamic err) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    const Icon(Icons.error_outline, size: 60, color: Colors.red),
    const SizedBox(height: 15),
    Text("Erreur de chargement : $err"),
    TextButton(onPressed: () => setState(() { futureDetails = ProduitService.getDetailsProduit(widget.produitId, widget.token); }), child: const Text("RÉESSAYER"))
  ]));
}