import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/delayed_animation.dart';
import '../../models/produit_model.dart';
import '../../models/rapport_vente_page.dart';
import '../../service/produit_service.dart';
import 'ListProduit.dart';
import 'reception_stock_page.dart';
import 'liste_receptions_page.dart';
import 'VenteProduit.dart';
import 'welcome_page.dart';

class DashboardMagasinPage extends StatefulWidget {
  final String magasinId;
  final String magasinNom;
  final String magasinAdresse; // Paramètre d'adresse ajouté
  final String token;
  final String guichetId;
  final String utilisateurId;
  final String? nomUtilisateur;

  const DashboardMagasinPage({
    Key? key,
    required this.magasinId,
    required this.magasinNom,
    required this.magasinAdresse, // Requis dans le constructeur
    required this.token,
    required this.guichetId,
    required this.utilisateurId,
    this.nomUtilisateur = "Utilisateur",
  }) : super(key: key);

  @override
  State<DashboardMagasinPage> createState() => _DashboardMagasinPageState();
}

class _DashboardMagasinPageState extends State<DashboardMagasinPage> {
  late Future<List<Produit>> futureProduits;

  // COULEURS PROJET
  final Color orangeMax = const Color(0xFFFF7900);
  final Color bleuNuit = const Color(0xFF0D084B);

  @override
  void initState() {
    super.initState();
    _refreshDashboard();
  }

  void _refreshDashboard() {
    setState(() {
      futureProduits = ProduitService.getProduits(widget.magasinId, widget.token);
    });
  }

  // --- APP BAR METE A JOUR AVEC L'ADRESSE ---
  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(110), // Légèrement agrandi pour le sous-titre
      child: DelayedAnimation(
        delay: 0,
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white, size: 28),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              color: bleuNuit,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(35),
                bottomRight: Radius.circular(35),
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 5),
                  Text(
                    widget.magasinNom.toUpperCase(),
                    style: TextStyle(
                      color: orangeMax,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on, color: Colors.white70, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        widget.magasinAdresse,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white70),
              onPressed: _refreshDashboard,
            )
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
      drawer: _buildDrawer(),
      body: FutureBuilder<List<Produit>>(
        future: futureProduits,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: orangeMax));
          }
          final produits = snapshot.data ?? [];

          return RefreshIndicator(
            onRefresh: () async => _refreshDashboard(),
            color: orangeMax,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildWelcomeSection(),
                  _buildStatsGrid(produits),
                  const SizedBox(height: 30),
                  _buildMainActions(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- SECTION BIENVENUE DYNAMIQUE ---
  Widget _buildWelcomeSection() {
    return DelayedAnimation(
      delay: 300,
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Gestionnaire,", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                Text(
                    widget.nomUtilisateur ?? "Utilisateur",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: bleuNuit)
                ),
              ],
            ),
            const Spacer(),
            CircleAvatar(backgroundColor: orangeMax.withOpacity(0.1), child: Icon(Icons.notifications_none, color: orangeMax)),
          ],
        ),
      ),
    );
  }

  // --- GRILLE DE STATISTIQUES ---
  Widget _buildStatsGrid(List<Produit> produits) {
    final stockTotal = produits.fold<int>(0, (sum, p) => sum + p.quantiteActuelle);
    final alertesStock = produits.where((p) => p.quantiteActuelle <= p.seuilAlerte).length;
    final rayons = produits.map((p) => p.rayonId.id).toSet().length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _statCard("Stock Global", "$stockTotal", Icons.inventory_2, 400)),
              const SizedBox(width: 15),
              Expanded(child: _statCard("Alertes", "$alertesStock", Icons.warning_amber_rounded, 500, isAlert: alertesStock > 0)),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: _statCard("Rayons", "$rayons", Icons.account_tree_outlined, 600)),
              const SizedBox(width: 15),
              Expanded(child: _statCard("Guichet", "Actif", Icons.point_of_sale, 700)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, int delay, {bool isAlert = false}) {
    return DelayedAnimation(
      delay: delay,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: isAlert ? Colors.red : orangeMax, size: 28),
            const SizedBox(height: 15),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: bleuNuit)),
            Text(title, style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  // --- BOUTONS D'ACTION XL ---
  Widget _buildMainActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _actionButton(
              "FAIRE UNE VENTE",
              Icons.shopping_cart_checkout,
              orangeMax,
              800,
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => VentePage(
                magasinId: widget.magasinId,
                magasinNom: widget.magasinNom,
                token: widget.token,
                guichetId: widget.guichetId,
                utilisateurId: widget.utilisateurId,
              )))
          ),
          const SizedBox(height: 15),
          _actionButton(
              "GÉRER L'INVENTAIRE",
              Icons.list_alt_rounded,
              bleuNuit,
              900,
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => ListeProduitsPage(
                magasinId: widget.magasinId,
                magasinNom: widget.magasinNom,
                token: widget.token,
                guichetId: widget.guichetId,
                utilisateurId: widget.utilisateurId,
                nomUtilisateur: widget.nomUtilisateur,
              )))
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String label, IconData icon, Color color, int delay, VoidCallback onTap) {
    return DelayedAnimation(
      delay: delay,
      child: SizedBox(
        width: double.infinity,
        height: 65,
        child: ElevatedButton.icon(
          onPressed: () {
            HapticFeedback.mediumImpact();
            onTap();
          },
          icon: Icon(icon, color: Colors.white),
          label: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            elevation: 3,
          ),
        ),
      ),
    );
  }

  // --- DRAWER ---
  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 30, left: 20, right: 20),
            decoration: BoxDecoration(
              color: bleuNuit,
              borderRadius: const BorderRadius.only(bottomRight: Radius.circular(50)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Color(0xFF0D084B)),
                ),
                const SizedBox(height: 15),
                Text(
                  widget.nomUtilisateur ?? "Utilisateur",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: orangeMax, borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    widget.magasinNom.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(10),
              children: [
                _drawerSectionTitle("OPÉRATIONS"),
                _drawerTile(Icons.shopping_basket_rounded, "Ventes directes", () {
                  Navigator.pop(context);
                }),
                _drawerTile(Icons.history_edu_rounded, "Historique des ventes", () {
                  Navigator.pop(context);
                }),
                const Divider(height: 30),
                _drawerSectionTitle("STOCK & INVENTAIRE"),
                _drawerTile(Icons.inventory_rounded, "Gestion des articles", () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ListeProduitsPage(
                      magasinId: widget.magasinId,
                      magasinNom: widget.magasinNom,
                      token: widget.token,
                      guichetId: widget.guichetId,
                      utilisateurId: widget.utilisateurId,
                      nomUtilisateur: widget.nomUtilisateur
                  )));
                }),
                _drawerTile(Icons.grid_view_rounded, "Stock par rayons", () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => StockParRayonPage(
                    magasinId: widget.magasinId,
                    magasinNom: widget.magasinNom,
                    token: widget.token,
                  )));
                }),
                _drawerTile(Icons.move_to_inbox_rounded, "Réceptions de stock", () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ListeReceptionsPage(
                      magasinId: widget.magasinId,
                      token: widget.token
                  )));
                }),
                const Divider(height: 30),
                _drawerSectionTitle("ADMINISTRATION"),
                _drawerTile(Icons.bar_chart_rounded, "Rapports & Recettes", () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => RapportVentePage(
                    magasinId: widget.magasinId,
                    token: widget.token,
                  )));
                }),
                _drawerTile(Icons.settings_suggest_rounded, "Paramètres guichet", () {
                  Navigator.pop(context);
                }),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            title: const Text("Déconnexion", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const WelcomePage()), (r) => false);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _drawerSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, bottom: 10, top: 5),
      child: Text(
          title,
          style: TextStyle(
              color: Colors.grey[400],
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2
          )
      ),
    );
  }

  Widget _drawerTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: orangeMax, size: 24),
      title: Text(
          title,
          style: TextStyle(color: bleuNuit, fontWeight: FontWeight.w600, fontSize: 14)
      ),
      trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey[300]),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    );
  }
}

// --- PAGE DU STOCK PAR RAYONS ---
class StockParRayonPage extends StatefulWidget {
  final String magasinId;
  final String magasinNom;
  final String token;

  const StockParRayonPage({
    Key? key,
    required this.magasinId,
    required this.magasinNom,
    required this.token,
  }) : super(key: key);

  @override
  State<StockParRayonPage> createState() => _StockParRayonPageState();
}

class _StockParRayonPageState extends State<StockParRayonPage> {
  late Future<List<Produit>> futureProduits;
  final Color orangeMax = const Color(0xFFFF7900);
  final Color bleuNuit = const Color(0xFF0D084B);

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  void _fetchProducts() {
    setState(() {
      futureProduits = ProduitService.getProduits(widget.magasinId, widget.token);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        backgroundColor: bleuNuit,
        title: const Text(
          "STOCK PAR RAYONS",
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchProducts,
          )
        ],
      ),
      body: FutureBuilder<List<Produit>>(
        future: futureProduits,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: orangeMax));
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Une erreur s'est produite lors du chargement des données."));
          }

          final produits = snapshot.data ?? [];
          if (produits.isEmpty) {
            return const Center(child: Text("Aucun article disponible."));
          }

          final Map<String, List<Produit>> produitsParRayon = {};
          for (var p in produits) {
            String rayonNom = "Rayon indéfini";
            try {
              final dynamic rayon = p.rayonId;
              rayonNom = rayon.nom ?? rayon.libelle ?? "Rayon ${rayon.id}";
            } catch (_) {
              try {
                rayonNom = "Rayon ${p.rayonId.id}";
              } catch (_) {}
            }
            produitsParRayon.putIfAbsent(rayonNom, () => []).add(p);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: produitsParRayon.keys.length,
            itemBuilder: (context, index) {
              final rayonNom = produitsParRayon.keys.elementAt(index);
              final listeProduitsRayon = produitsParRayon[rayonNom]!;
              final int totalStockRayon = listeProduitsRayon.fold(0, (sum, p) => sum + p.quantiteActuelle);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 1,
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: orangeMax.withOpacity(0.1),
                    child: Icon(Icons.grid_view_rounded, color: orangeMax, size: 20),
                  ),
                  title: Text(
                    rayonNom.toUpperCase(),
                    style: TextStyle(color: bleuNuit, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  subtitle: Text(
                    "${listeProduitsRayon.length} articles • Stock total: $totalStockRayon",
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  childrenPadding: const EdgeInsets.only(bottom: 10),
                  children: listeProduitsRayon.map((p) {
                    final isLowStock = p.quantiteActuelle <= p.seuilAlerte;
                    return Column(
                      children: [
                        const Divider(height: 1),
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                          title: Text(
                            p.designation ?? "Article sans nom",
                            style: TextStyle(color: bleuNuit, fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          subtitle: Text(
                            "Seuil d'alerte : ${p.seuilAlerte}",
                            style: TextStyle(color: Colors.grey[500], fontSize: 11),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: isLowStock ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "${p.quantiteActuelle} en stock",
                              style: TextStyle(
                                color: isLowStock ? Colors.red : Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}