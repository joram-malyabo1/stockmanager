import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/delayed_animation.dart';
import '../../models/magasin_model.dart';
import '../../service/MagasinService.dart';
import '../blocs/theme_bloc.dart';
import '../blocs/theme_event.dart';
import '../blocs/theme_state.dart';
import 'details_magasin_page.dart';
import 'welcome_page.dart';


class Dashboard extends StatefulWidget {
  final Map<String, dynamic> utilisateur;
  final String? token;

  const Dashboard({
    Key? key,
    required this.utilisateur,
    this.token,
  }) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late Future<List<Magasin>> _magasinsFuture;

  // Couleurs du projet
  final Color orangeMax = const Color(0xFFFF7900);
  final Color bleuNuit = const Color(0xFF0D084B);

  @override
  void initState() {
    super.initState();
    _initializeMagasinsFuture();
  }

  void _initializeMagasinsFuture() {
    if (widget.token != null) {
      _magasinsFuture = MagasinService.fetchMagasins(widget.token!);
    } else {
      _magasinsFuture = Future.value([]);
    }
  }

  Future<void> _refreshMagasins() async {
    setState(() {
      _initializeMagasinsFuture();
    });
  }

  @override
  Widget build(BuildContext context) {
    String nomUtilisateur = widget.utilisateur['nom'] ?? "Administrateur";

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: _buildAppBar(),
      drawer: _buildDrawer(nomUtilisateur),
      body: RefreshIndicator(
        onRefresh: _refreshMagasins,
        color: orangeMax,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Aligne les éléments à gauche
          children: [
            _buildWelcomeHeader(nomUtilisateur),
            _buildSectionTitle("Mes Magasins"), // Titre ajouté ici
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  // --- APP BAR ---
  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: DelayedAnimation(
        delay: 0,
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              color: bleuNuit,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(35),
                bottomRight: Radius.circular(35),
              ),
            ),
            child: SafeArea(
              child: Center(
                child: Text(
                  "STOCK MANAGER",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: orangeMax,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.sync, color: Colors.white70),
              onPressed: _refreshMagasins,
            ),
          ],
        ),
      ),
    );
  }

  // --- HEADER DE BIENVENUE ---
  Widget _buildWelcomeHeader(String nom) {
    return DelayedAnimation(
      delay: 300,
      child: Container(
        padding: const EdgeInsets.only(left: 25, right: 25, top: 25, bottom: 10),
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Bonjour,", style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            Text(
              nom,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: bleuNuit),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.circle, size: 10, color: widget.token != null ? Colors.green : Colors.orange),
                const SizedBox(width: 8),
                Text(
                  widget.token != null ? "Mode Online • Connecté" : "Mode Offline",
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- TITRE DE LA SECTION ---
  Widget _buildSectionTitle(String titre) {
    return DelayedAnimation(
      delay: 350,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        child: Text(
          titre,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: bleuNuit,
          ),
        ),
      ),
    );
  }

  // --- LISTE DES MAGASINS (BODY) ---
  Widget _buildBody() {
    return FutureBuilder<List<Magasin>>(
      future: _magasinsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: orangeMax));
        }

        if (snapshot.hasError) {
          return const Center(child: Text("Erreur de connexion au serveur"));
        }

        final magasins = snapshot.data ?? [];
        if (magasins.isEmpty) {
          return const Center(child: Text("Aucun magasin disponible"));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: magasins.length,
          itemBuilder: (context, index) {
            final m = magasins[index];
            return DelayedAnimation(
              delay: 400 + (index * 100),
              child: _buildMagasinCard(m),
            );
          },
        );
      },
    );
  }

  Widget _buildMagasinCard(Magasin m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: bleuNuit.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: InkWell(
        onTap: () => _navigateToMagasin(m),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              // Image ou Initiale
              Container(
                width: 70, height: 70,
                decoration: BoxDecoration(
                  color: bleuNuit.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: m.photoUrl != null && m.photoUrl!.isNotEmpty
                      ? Image.network(m.photoUrl!, fit: BoxFit.cover)
                      : Icon(Icons.storefront, color: bleuNuit, size: 35),
                ),
              ),
              const SizedBox(width: 15),
              // Infos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(m.nomMagasin, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(m.adresse, style: TextStyle(color: Colors.grey[500], fontSize: 12), maxLines: 1),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildBadge("${m.guichets.length} Guichets"),
                        const SizedBox(width: 5),
                        _buildBadge("${m.vendeursCount} Vendeurs"),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: orangeMax),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: orangeMax.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(color: orangeMax, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  // --- DRAWER ---
  Widget _buildDrawer(String nom) {
    return Drawer(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 60, bottom: 30, left: 20, right: 20),
            width: double.infinity,
            decoration: BoxDecoration(color: bleuNuit),
            child: Column(
              children: [
                const CircleAvatar(radius: 40, backgroundColor: Colors.white, child: Icon(Icons.person, size: 40)),
                const SizedBox(height: 15),
                Text(nom, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                Text(widget.utilisateur['role'] ?? "Utilisateur", style: TextStyle(color: orangeMax, fontSize: 12)),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard, color: bleuNuit),
            title: const Text("Tableau de Bord"),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(Icons.settings, color: bleuNuit),
            title: const Text("Paramètres"),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Déconnexion", style: TextStyle(color: Colors.red)),
            onTap: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const WelcomePage()), (r) => false),
          ),
        ],
      ),
    );
  }


  void _navigateToMagasin(Magasin magasin) {
    final String currentUserId = widget.utilisateur['id'] ?? "";
    // Récupère le nom de l'utilisateur actuel (ex: "kakule")
    final String currentUserName = widget.utilisateur['nom'] ?? "Utilisateur";

    String targetGuichetId = "";

    for (var guichet in magasin.guichets) {
      if (guichet.vendeurPrincipal.id == currentUserId) {
        targetGuichetId = guichet.id;
        break;
      }
    }

    if (targetGuichetId.isEmpty && magasin.guichets.isNotEmpty) {
      targetGuichetId = magasin.guichets.first.id;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DashboardMagasinPage(
          magasinId: magasin.id,
          magasinNom: magasin.nomMagasin,
          magasinAdresse: magasin.adresse, // ✅ Ajout de l'adresse
          token: widget.token!,
          guichetId: targetGuichetId,
          utilisateurId: currentUserId,
          nomUtilisateur: currentUserName, // ✅ Ajout du nom d'utilisateur
        ),
      ),
    );
  }

}