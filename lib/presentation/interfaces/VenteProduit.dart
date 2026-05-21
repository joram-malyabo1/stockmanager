import 'package:flutter/material.dart';
import '../../models/reception_model.dart';
import '../../models/TicketItem.dart';
import '../../models/produit_model.dart';
import '../../models/type_rayon_model.dart';
import '../../service/produit_service.dart';
import 'ticket.dart';

class VentePage extends StatefulWidget {
  final String magasinId;
  final String magasinNom;
  final String token;
  final String guichetId;
  final String utilisateurId;
  final String? nomUtilisateur;

  const VentePage({
    Key? key,
    required this.magasinId,
    required this.magasinNom,
    required this.token,
    required this.guichetId,
    required this.utilisateurId,
    this.nomUtilisateur = "Utilisateur",
  }) : super(key: key);

  @override
  _VentePageState createState() => _VentePageState();
}

class _VentePageState extends State<VentePage> with TickerProviderStateMixin {
  List<Reception> allReceptions = [];
  List<Reception> filteredReceptions = [];
  List<TicketItem> ticket = [];
  bool isLoading = true;

  final Color orangeMax = const Color(0xFFFF7900);
  final Color bleuNuit = const Color(0xFF0D084B);

  final GlobalKey _cartKey = GlobalKey();

  // Filtres
  List<String> typesList = ["Tous les types"];
  List<String> rayonsList = ["Tous les rayons"];
  String selectedType = "Tous les types";
  String selectedRayon = "Tous les rayons";
  final TextEditingController _searchController = TextEditingController();

  // Animations
  late AnimationController _cartAnimationController;
  late Animation<double> _cartScaleAnimation;

  // Animation pour le clignotement du nombre d'articles
  late AnimationController _blinkAnimationController;
  late Animation<double> _blinkOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _cartAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _cartScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0), weight: 50),
    ]).animate(_cartAnimationController);

    // Initialisation du contrôleur de clignotement d'une seconde (1000 ms)
    _blinkAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _blinkOpacityAnimation = Tween<double>(begin: 1.0, end: 0.2).animate(
      CurvedAnimation(parent: _blinkAnimationController, curve: Curves.easeInOut),
    );

    _chargerDonnees();
  }

  @override
  void dispose() {
    _cartAnimationController.dispose();
    _blinkAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Fonction utilitaire pour le formatage simple en Francs Guinéens (FG)
  String _formaterPrix(double montant) {
    return "${montant.toStringAsFixed(0)} FG";
  }

  // --- CHARGEMENT DU STOCK ---
  Future<void> _chargerDonnees() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final list = await ProduitService.getReceptions(widget.magasinId, widget.token);

      Set<String> types = {"Tous les types"};
      Set<String> rayons = {"Tous les rayons"};

      for (var r in list) {
        if (r.produitNom.isNotEmpty) types.add(r.produitNom);
        if (r.rayonNom != null) rayons.add(r.rayonNom!);
      }

      if (mounted) {
        setState(() {
          allReceptions = list;
          typesList = types.toList();
          rayonsList = rayons.toList();
          _appliquerFiltres();
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
      debugPrint("Erreur chargement stock: $e");
    }
  }

  void _appliquerFiltres() {
    setState(() {
      filteredReceptions = allReceptions.where((r) {
        final matchSearch = r.produitNom.toLowerCase().contains(_searchController.text.toLowerCase());
        final matchType = selectedType == "Tous les types" || r.produitNom == selectedType;
        final matchRayon = selectedRayon == "Tous les rayons" || r.rayonNom == selectedRayon;
        return matchSearch && matchType && matchRayon;
      }).toList();
    });
  }

  // --- NAVIGATION ET ACTUALISATION SYNCHRONISÉE ---
  void _goToTicket() async {
    if (ticket.isEmpty) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TicketPage(
          ticketItems: ticket,
          magasinId: widget.magasinId,
          token: widget.token,
          guichetId: widget.guichetId,
          utilisateurId: widget.utilisateurId,
        ),
      ),
    );

    // Si la vente est validée
    if (result == true) {
      setState(() {
        ticket.clear();      // Vider le panier
        _blinkAnimationController.stop(); // Arrêter le clignotement
      });

      await Future.delayed(const Duration(milliseconds: 600));
      _chargerDonnees();
    }
  }

  double get totalPanier => ticket.fold(0, (sum, item) => sum + item.total);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: bleuNuit, elevation: 0, toolbarHeight: 45,
        title: Text("VENTE : ${widget.magasinNom.toUpperCase()}",
            style: TextStyle(color: orangeMax, fontSize: 13, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          _buildTopPaymentInfo(),
          _buildFilterSection(),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: orangeMax))
                : RefreshIndicator(
                onRefresh: _chargerDonnees,
                color: orangeMax,
                child: _buildProductList()
            ),
          ),
        ],
      ),
      floatingActionButton: _buildCartButton(),
    );
  }

  Widget _buildTopPaymentInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      color: bleuNuit,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("PANIER", style: TextStyle(color: Colors.white54, fontSize: 10)),
            Text("${ticket.length} Produit(s)", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          ]),
          Expanded(
            child: InkWell(
              onTap: _goToTicket,
              child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                const Text("TOTAL À PAYER", style: TextStyle(color: Colors.white54, fontSize: 10)),
                Text(_formaterPrix(totalPanier),
                    style: TextStyle(color: orangeMax, fontWeight: FontWeight.bold, fontSize: 18),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 15),
      color: bleuNuit,
      child: Column(
        children: [
          SizedBox(
            height: 45,
            child: TextField(
              controller: _searchController,
              onChanged: (v) => _appliquerFiltres(),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: "Rechercher un produit...",
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
                prefixIcon: Icon(Icons.search, color: orangeMax, size: 22),
                filled: true, fillColor: Colors.white.withOpacity(0.1),
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _combo(selectedType, typesList, (v) { setState(() => selectedType = v!); _appliquerFiltres(); })),
              const SizedBox(width: 10),
              Expanded(child: _combo(selectedRayon, rayonsList, (v) { setState(() => selectedRayon = v!); _appliquerFiltres(); })),
            ],
          ),
        ],
      ),
    );
  }

  Widget _combo(String val, List<String> items, ValueChanged<String?> onChange) {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white24)
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(val) ? val : items.first,
          dropdownColor: bleuNuit,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: orangeMax),
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))).toList(),
          onChanged: onChange,
        ),
      ),
    );
  }

  Widget _buildProductList() {
    if (filteredReceptions.isEmpty) {
      return const Center(child: Text("Aucun produit trouvé", style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: filteredReceptions.length,
      itemBuilder: (context, index) {
        final r = filteredReceptions[index];
        final GlobalKey imageKey = GlobalKey();

        final bool isLot = (r.nombrePieces != null && r.nombrePieces! > 1);
        double totalPcsRestantes = r.quantite.toDouble();
        double pcsParLotOriginal = (r.quantiteParPiece != null && r.quantiteParPiece! > 0)
            ? r.quantiteParPiece!
            : (isLot ? (totalPcsRestantes / r.nombrePieces!) : 1);

        int lotsComplets = isLot ? (totalPcsRestantes ~/ pcsParLotOriginal) : 0;
        int piecesRestantesHorsLot = isLot ? (totalPcsRestantes % pcsParLotOriginal).toInt() : 0;
        double pUnit = (totalPcsRestantes > 0) ? (r.prixTotal / totalPcsRestantes) : 0;
        double pLot = pUnit * pcsParLotOriginal;

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: Colors.grey[200]!)),
          child: InkWell(
            onTap: () {
              _runFlyAnimation(imageKey);
              _gererSelection(r, isLot, pUnit, pcsParLotOriginal, pLot);
            },
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Container(
                    key: imageKey,
                    width: 50, height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[100], borderRadius: BorderRadius.circular(8),
                      image: r.photoUrl != null && r.photoUrl.isNotEmpty
                          ? DecorationImage(image: NetworkImage(r.photoUrl), fit: BoxFit.cover)
                          : null,
                    ),
                    child: r.photoUrl == null || r.photoUrl.isEmpty ? Icon(Icons.image, size: 24, color: Colors.grey[300]) : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.produitNom.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: bleuNuit), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text(
                          isLot ? "$lotsComplets Lots + $piecesRestantesHorsLot pcs" : "${totalPcsRestantes.toInt()} pièces en stock",
                          style: TextStyle(fontSize: 10, color: isLot ? Colors.purple : Colors.grey[600], fontWeight: isLot ? FontWeight.bold : FontWeight.normal),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(_formaterPrix(pUnit), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: orangeMax)),
                      if(isLot) const SizedBox(height: 2),
                      if(isLot) Text("Lot: ${_formaterPrix(pLot)}", style: TextStyle(fontSize: 9, color: bleuNuit, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Icon(Icons.add_circle, color: orangeMax.withOpacity(0.8), size: 26),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _runFlyAnimation(GlobalKey imageKey) {
    final RenderBox? renderBox = imageKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? cartBox = _cartKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || cartBox == null) return;

    final Offset startPosition = renderBox.localToGlobal(Offset.zero);
    final Offset endPosition = cartBox.localToGlobal(Offset.zero);

    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => TweenAnimationBuilder<Offset>(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
        tween: Tween(begin: startPosition, end: endPosition),
        onEnd: () {
          overlayEntry.remove();
          _cartAnimationController.forward(from: 0.0);
        },
        builder: (context, value, child) {
          return Positioned(
            left: value.dx, top: value.dy,
            child: Icon(Icons.add_shopping_cart, color: orangeMax, size: 20),
          );
        },
      ),
    );
    Overlay.of(context).insert(overlayEntry);
  }

  void _gererSelection(Reception r, bool isLot, double pUnit, double pcsLot, double pLot) {
    if (!isLot) {
      _addToTicket(r, "Détail", pUnit, 1, pUnit);
      return;
    }
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          ListTile(
            leading: Icon(Icons.sell, color: orangeMax),
            title: const Text("Vendre à l'Unité (1 pc)"),
            trailing: Text(_formaterPrix(pUnit), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            onTap: () { Navigator.pop(context); _addToTicket(r, "Détail", pUnit, 1, pUnit); },
          ),
          ListTile(
            leading: Icon(Icons.inventory_2, color: Colors.purple),
            title: Text("Vendre par Lot de ${pcsLot.toInt()} pcs"),
            trailing: Text(_formaterPrix(pLot), style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 12)),
            onTap: () { Navigator.pop(context); _addToTicket(r, "Lot", pUnit, pcsLot, pLot); },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _addToTicket(Reception r, String modeLabel, double pUnit, double qtePcs, double prixLigne) {
    setState(() {
      int idx = ticket.indexWhere((item) => item.produit.id == r.produitId && item.typeVente == modeLabel);
      if (idx != -1) {
        ticket[idx].quantite += 1;
      } else {
        Produit p = Produit(
          id: r.produitId, magasinId: widget.magasinId, reference: r.produitRef, designation: r.produitNom,
          typeProduitId: TypeProduitId(id: r.typeProduitId ?? "t", nomType: modeLabel, typeStockage: "simple", unitePrincipale: "pcs", code: "C", icone: "📦", seuilAlerte: 1, capaciteMax: 100),
          rayonId: RayonId(id: r.rayonId, nomRayon: r.rayonNom, codeRayon: "C", typeRayon: "S", capaciteMax: 100, iconeRayon: "📍", quantiteActuelle: r.quantite.toInt()),
          quantiteActuelle: r.quantite.toInt(), lotsDisponibles: r.nombrePieces ?? 0, quantiteEntree: r.quantite.toInt(), quantiteSortie: 0,
          prixUnitaire: pUnit, prixLot: prixLigne, prixTotal: r.prixTotal.toDouble(),
          seuilAlerte: 5, etat: "Neuf", photoUrl: r.photoUrl, notes: "", statut: "disponible", priorite: "normale", status: 1, estSupprime: false, createdAt: DateTime.now(), updatedAt: DateTime.now(), alertes: [],
        );
        ticket.add(TicketItem(produit: p, typeVente: modeLabel, quantite: 1));
      }

      // Clignotement du badge d'article si le panier contient un élément
      if (ticket.isNotEmpty && !_blinkAnimationController.isAnimating) {
        _blinkAnimationController.repeat(reverse: true);
      }
    });
  }

  Widget _buildCartButton() {
    return ScaleTransition(
      scale: _cartScaleAnimation,
      child: SizedBox(
        width: 68,  // Largeur augmentée du bouton panier
        height: 68, // Hauteur augmentée du bouton panier
        child: FloatingActionButton(
          key: _cartKey,
          backgroundColor: bleuNuit, // Fond du panier défini en bleu de nuit
          onPressed: _goToTicket,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none, // Permet au badge d'articles de dépasser légèrement
            children: [
              const Icon(Icons.shopping_basket, size: 34, color: Colors.white), // Icône du panier définie en blanc
              if (ticket.isNotEmpty)
                Positioned(
                  top: -6,
                  right: -6,
                  child: AnimatedBuilder(
                    animation: _blinkOpacityAnimation,
                    builder: (context, child) {
                      // Seul le badge rouge clignote à l'aide du changement d'opacité
                      return Opacity(
                        opacity: _blinkOpacityAnimation.value,
                        child: child,
                      );
                    },
                    child: CircleAvatar(
                      radius: 12, // Taille du badge rouge
                      backgroundColor: Colors.red, // Notification rouge
                      child: Text(
                        "${ticket.length}",
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}