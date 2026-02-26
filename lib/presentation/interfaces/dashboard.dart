import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stockmanager/models/utilisateur.dart';
import '../../core/colors.dart';
import '../../core/delayed_animation.dart';
import '../../models/magasin_model.dart';
import '../../service/MagasinService.dart';
import '../blocs/theme_bloc.dart';
import '../blocs/theme_event.dart';
import '../blocs/theme_state.dart';
import 'details_magasin_page.dart';
import 'vente.dart';
import 'articles.dart';
import 'ListRecuPage.dart';
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

  @override
  void initState() {
    super.initState();
    _initializeMagasinsFuture();
  }

  void _initializeMagasinsFuture() {
    if (widget.token != null) {
      _magasinsFuture = MagasinService.fetchMagasins(widget.token!); // ✅ ERREUR 1 CORRIGÉE
    } else {
      _magasinsFuture = Future.value([]); // Offline
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
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _refreshMagasins,
        child: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: DelayedAnimation(
        delay: 0,
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              color: AppColors.green,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),

                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Tableau de bord",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (widget.token != null)
                            Text(
                              "${widget.utilisateur['role'] ?? 'User'} • Online",
                              style: TextStyle(fontSize: 12, color: Colors.white70),
                            )
                          else
                            Text(
                              "Mode Offline",
                              style: TextStyle(fontSize: 12, color: Colors.orange[300]),
                            ),
                        ],
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white, size: 20),
                    itemBuilder: (context) => [
                      if (widget.token != null)
                        const PopupMenuItem(value: 'sync', child: Text('🔄 Synchroniser')),
                      const PopupMenuItem(value: 'settings', child: Text('⚙️ Paramètres')),
                      const PopupMenuItem(value: 'help', child: Text('❓ Aide')),
                    ],
                    onSelected: (value) {
                      if (value == 'sync') _refreshMagasins();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(String nomUtilisateur) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: AppColors.green),
            child: FutureBuilder<List<Magasin>>(
              future: _magasinsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                }

                if (widget.token == null || snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.store_outlined, size: 30, color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        nomUtilisateur,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        widget.token == null ? "Mode Offline" : "Aucun magasin",
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                    ],
                  );
                }

                final magasin = snapshot.data!.first;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      backgroundImage: magasin.photoUrl != null ? NetworkImage(magasin.photoUrl!) : null,
                      child: magasin.photoUrl == null
                          ? Icon(Icons.store, size: 30, color: AppColors.green)
                          : null,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      nomUtilisateur,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      "${magasin.nomMagasin} • ${magasin.guichets.length} guichets",
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ],
                );
              },
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // ✅ ERREUR 2 CORRIGÉE - Named parameters
                _drawerItem(Icons.shopping_basket, "Ventes", onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => VentePage()));
                }),
                _drawerItem(Icons.receipt_long, "Recettes"),
                _drawerItem(Icons.access_time, "Reçus", onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => RapportRecuPage()));
                }),
                _drawerItem(Icons.list, "Articles", onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ItemsPage()));
                }),
                _themeSwitcher(),
                _drawerItem(Icons.logout, "Déconnexion", color: Colors.red, onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const WelcomePage()),
                        (route) => false,
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ ERREUR 2 CORRIGÉE - Signature correcte
  Widget _drawerItem(IconData icon, String title, {VoidCallback? onTap, Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.grey[700]),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, color: color ?? Colors.black),
      ),
      trailing: onTap != null ? const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey) : null,
      onTap: onTap,
    );
  }

  Widget _themeSwitcher() {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final isDark = state.themeData.brightness == Brightness.dark;
        return SwitchListTile(
          title: const Text("Mode sombre", style: TextStyle(fontWeight: FontWeight.bold)),
          value: isDark,
          activeColor: AppColors.green,
          onChanged: (_) => context.read<ThemeBloc>().add(ToggleThemeEvent()),
        );
      },
    );
  }

  Widget _buildBody() {
    return FutureBuilder<List<Magasin>>(
      future: _magasinsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Chargement des magasins..."),
              ],
            ),
          );
        }

        if (widget.token == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_off, size: 80, color: Colors.grey),
                const SizedBox(height: 16),
                const Text("Mode Offline", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  "Connectez-vous en ligne pour voir vos magasins",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 80, color: Colors.red),
                const SizedBox(height: 16),
                Text("Erreur: ${snapshot.error}", style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refreshMagasins,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.green),
                  child: const Text("Réessayer"),
                ),
              ],
            ),
          );
        }

        final magasins = snapshot.data ?? [];
        if (magasins.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.storefront_outlined, size: 80, color: Colors.grey),
                const SizedBox(height: 16),
                const Text("Aucun magasin trouvé", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text("Tous vos magasins apparaîtront ici", style: TextStyle(fontSize: 16, color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: magasins.length,
          itemBuilder: (context, index) {
            final magasin = magasins[index];
            return Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: magasin.photoUrl != null && magasin.photoUrl!.isNotEmpty
                    ? CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(magasin.photoUrl!),
                  onBackgroundImageError: (exception, stackTrace) => CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.green,
                    child: Text(
                      magasin.nomMagasin.isNotEmpty ? magasin.nomMagasin[0].toUpperCase() : 'M',
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                )
                    : CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.green,
                  child: Text(
                    magasin.nomMagasin.isNotEmpty ? magasin.nomMagasin[0].toUpperCase() : 'M',
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                title: Text(magasin.nomMagasin, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(magasin.adresse),
                    Text('${magasin.guichets.length} guichets • ${magasin.vendeursCount} vendeurs',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                    Text(magasin.telephone, style: TextStyle(fontSize: 12, color: Colors.green[700])),
                  ],
                ),
                trailing: Column( // ✅ ERREUR 3 CORRIGÉE
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      magasin.businessId.nomEntreprise, // ✅ CORRECT
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    if (magasin.status == 1) const Icon(Icons.verified, color: Colors.green, size: 20),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DashboardMagasinPage(
                        magasinId: magasin.id,
                        magasinNom: magasin.nom,
                        token: widget.token!,
                         // ✅ AJOUTEZ (nom fixe ou variable)
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
