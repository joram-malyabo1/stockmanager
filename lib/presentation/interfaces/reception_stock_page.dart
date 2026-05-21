import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/delayed_animation.dart';
import '../../service/produit_service.dart';
import '../../models/produit_model.dart';
import '../../models/reception_model.dart';
import 'liste_receptions_page.dart';

class ReceptionStockPage extends StatefulWidget {
  final String magasinId;
  final String magasinNom;
  final String token;
  final Produit? produitInitial;
  final Reception? receptionInitiale;

  const ReceptionStockPage({
    Key? key,
    required this.magasinId,
    required this.magasinNom,
    required this.token,
    this.produitInitial,
    this.receptionInitiale,
  }) : super(key: key);

  @override
  State<ReceptionStockPage> createState() => _ReceptionStockPageState();
}

class _ReceptionStockPageState extends State<ReceptionStockPage> {
  int _currentStep = 0;
  final int _totalSteps = 6;
  final GlobalKey<AnimatedTicketCounterState> _stepCounterKey = GlobalKey();

  final Color orangeMax = const Color(0xFFFF7900);
  final Color bleuNuit = const Color(0xFF0D084B);

  bool isLoading = true;
  bool _isSubmitting = false;

  List<Produit> produits = [];
  Produit? produitSelectionne;
  List<String> unitesDisponibles = [];
  String? selectedUniteVente;

  // --- VARIABLES POUR LES RECOMMANDATIONS ---
  String? selectedRayonId;
  double stockActuelDuProduit = 0;

  final _fournisseurController = TextEditingController();
  final _marqueController = TextEditingController();
  final _numLotController = TextEditingController();
  final _rayonDestController = TextEditingController();
  final _prixAchatController = TextEditingController();
  final _observationsController = TextEditingController();

  final _qteSimpleController = TextEditingController();
  final _lotNbPiecesController = TextEditingController();
  final _lotQteParPieceController = TextEditingController();

  DateTime dateReception = DateTime.now();
  DateTime? dateFabrication;
  DateTime? datePeremption;
  DateTime? dateExpiration;

  String selectedStatut = 'Stocker';
  String selectedPriorite = 'Normale';

  final List<String> listeStatuts = ['A contrôler', 'Stocker', 'Rejetter'];
  final List<String> listePriorites = ['Normale', 'Urgent'];

  File? _photoReception;
  final ImagePicker _picker = ImagePicker();

  bool get isLotSelectionne {
    if (produitSelectionne == null) return false;
    String type = produitSelectionne!.typeProduitId.nomType.toLowerCase();
    return produitSelectionne!.typeProduitId.typeStockage == "lot" ||
        type.contains("rouleau") ||
        type.contains("lot");
  }

  // Extrait uniquement les rayons qui acceptent ce type de produit
  List<dynamic> obtenirRayonsCompatibles(Produit? produit) {
    if (produit == null) return [];
    final Map<String, dynamic> rayonsMap = {};

    if (produit.rayonId != null) {
      rayonsMap[produit.rayonId.id] = produit.rayonId;
    }

    for (var p in produits) {
      if (p.rayonId != null && p.typeProduitId.id == produit.typeProduitId.id) {
        rayonsMap[p.rayonId.id] = p.rayonId;
      }
    }
    return rayonsMap.values.toList();
  }

  @override
  void initState() {
    super.initState();
    _chargerDonnees();
  }

  Future<void> _chargerDonnees() async {
    try {
      final liste = await ProduitService.getProduits(widget.magasinId, widget.token);
      if (mounted) {
        setState(() {
          produits = liste.where((p) => !p.estSupprime).toList();

          if (widget.receptionInitiale != null) {
            final r = widget.receptionInitiale!;
            produitSelectionne = produits.firstWhere((p) => p.id == r.produitId, orElse: () => produits.first);

            _fournisseurController.text = r.fournisseur;
            _prixAchatController.text = r.prixTotal.toStringAsFixed(0);
            _observationsController.text = r.observations ?? "";

            _rayonDestController.text = produitSelectionne?.rayonId.nomRayon ?? "";
            selectedRayonId = produitSelectionne?.rayonId.id;
            stockActuelDuProduit = produitSelectionne?.quantiteActuelle.toDouble() ?? 0;

            if (r.nombrePieces != null && r.nombrePieces! > 1) {
              _lotNbPiecesController.text = r.nombrePieces.toString();
              _lotQteParPieceController.text = (r.quantite / r.nombrePieces!).toStringAsFixed(0);
            } else {
              _qteSimpleController.text = r.quantite.toStringAsFixed(0);
            }
            _initialiserUnites(produitSelectionne!);
          }
          else if (widget.produitInitial != null) {
            produitSelectionne = produits.firstWhere((e) => e.id == widget.produitInitial!.id, orElse: () => widget.produitInitial!);

            _rayonDestController.text = produitSelectionne!.rayonId.nomRayon;
            selectedRayonId = produitSelectionne!.rayonId.id;
            stockActuelDuProduit = produitSelectionne!.quantiteActuelle.toDouble() ?? 0;

            _initialiserUnites(produitSelectionne!);
          }

          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _initialiserUnites(Produit p) {
    unitesDisponibles = [p.typeProduitId.unitePrincipale, ...(p.typeProduitId.unitesVente ?? [])];
    selectedUniteVente = unitesDisponibles.isNotEmpty ? unitesDisponibles.first : "unité";
  }

  Future<void> _soumettre() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => WillPopScope(onWillPop: () async => false, child: Center(child: CircularProgressIndicator(color: orangeMax)))
    );

    try {
      String finalPhotoUrl = widget.receptionInitiale?.photoUrl ?? "";
      if (_photoReception != null) {
        final url = await ProduitService.uploadImageProduit(_photoReception!, widget.token);
        if (url != null) finalPhotoUrl = url;
      }

      double nbPieces = double.tryParse(_lotNbPiecesController.text) ?? 1;
      double qteParP = double.tryParse(_lotQteParPieceController.text) ?? 0;
      double qteSimple = double.tryParse(_qteSimpleController.text) ?? 0;
      double qteFinale = isLotSelectionne ? (nbPieces * qteParP) : qteSimple;
      double prixAchatTotal = double.tryParse(_prixAchatController.text) ?? 0;
      double prixUnitaireCalcule = (qteFinale > 0) ? (prixAchatTotal / qteFinale) : 0;

      final Map<String, dynamic> data = {
        "magasinId": widget.magasinId,
        "produitId": produitSelectionne!.id,
        "rayonId": selectedRayonId ?? produitSelectionne!.rayonId.id,
        "typeProduitId": produitSelectionne!.typeProduitId.id,
        "quantite": qteFinale,
        "prixAchat": prixAchatTotal,
        "fournisseur": _fournisseurController.text.isEmpty ? "Inconnu" : _fournisseurController.text,
        "dateReception": DateFormat('yyyy-MM-dd').format(dateReception),
        "photoUrl": finalPhotoUrl,
        "observations": _observationsController.text,
        "nombrePieces": isLotSelectionne ? nbPieces.toInt() : 1,
        "quantiteParPiece": isLotSelectionne ? qteParP : qteFinale,
        "uniteDetail": selectedUniteVente ?? "unité",
        "prixParUnite": prixUnitaireCalcule,
        "statut": selectedStatut,
        "priorite": selectedPriorite
      };

      Map<String, dynamic> result;
      if (widget.receptionInitiale != null) {
        result = await ProduitService.modifierReception(token: widget.token, receptionId: widget.receptionInitiale!.id, data: data);
      } else {
        result = await ProduitService.creerReception(
          token: widget.token, magasinId: widget.magasinId, produitId: produitSelectionne!.id,
          rayonId: selectedRayonId ?? produitSelectionne!.rayonId.id,
          typeProduitId: produitSelectionne!.typeProduitId.id, quantite: qteFinale,
          prixAchat: prixAchatTotal, fournisseur: _fournisseurController.text,
          dateReception: DateFormat('yyyy-MM-dd').format(dateReception), photoUrl: finalPhotoUrl,
          observations: _observationsController.text, isLot: isLotSelectionne,
          nombrePieces: isLotSelectionne ? nbPieces.toInt() : null, quantiteParPiece: isLotSelectionne ? qteParP : null,
          uniteDetail: selectedUniteVente, prixParUnite: prixUnitaireCalcule,
        );
      }

      Navigator.of(context, rootNavigator: true).pop();

      if (result['success'] == true) {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => ListeReceptionsPage(magasinId: widget.magasinId, token: widget.token)), (route) => false);
      } else {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: ${result['message']}"), backgroundColor: Colors.red));
      }
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur application: $e"), backgroundColor: Colors.red));
    }
  }

  void _showRecapitulation() {
    double totalQte = isLotSelectionne
        ? (double.tryParse(_lotNbPiecesController.text) ?? 0) * (double.tryParse(_lotQteParPieceController.text) ?? 0)
        : (double.tryParse(_qteSimpleController.text) ?? 0);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Row(children: [Icon(Icons.assignment_turned_in, color: orangeMax), const SizedBox(width: 10), Text(widget.receptionInitiale != null ? "MODIFIER" : "VÉRIFICATION")]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _recapItem("Article", produitSelectionne?.designation ?? "", 1),
            _recapItem("Quantité Totale", "$totalQte $selectedUniteVente", 2),
            _recapItem("Total GNF", "${_prixAchatController.text} FG", 3),
            _recapItem("Rayon Cible", _rayonDestController.text, 4),
            const Divider(height: 30),
            Text(widget.receptionInitiale != null ? "Confirmer les modifications ?" : "Enregistrer cette réception ?", style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("ANNULER")),
          ElevatedButton(
            onPressed: () { Navigator.pop(context); _soumettre(); },
            style: ElevatedButton.styleFrom(backgroundColor: orangeMax, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text("CONFIRMER", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _recapItem(String label, String val, int index) {
    return DelayedAnimation(
      delay: 100 * index,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text("$label:", style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
          Text(val, style: TextStyle(color: bleuNuit, fontWeight: FontWeight.bold, fontSize: 13)),
        ]),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(100),
      child: Container(
        decoration: BoxDecoration(color: bleuNuit, borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(35), bottomRight: Radius.circular(35))),
        child: SafeArea(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(widget.receptionInitiale != null ? 'MODIFIER RÉCEPTION' : 'NOUVELLE RÉCEPTION', style: TextStyle(color: orangeMax, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.5)),
            const SizedBox(height: 5),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text("Étape ", style: TextStyle(color: Colors.white70, fontSize: 12)),
              AnimatedTicketCounter(keyCounter: _stepCounterKey, count: _currentStep + 1),
              const Text(" / 6", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ]),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: orangeMax))
          : Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepTapped: (step) => setState(() => _currentStep = step),
        onStepContinue: () {
          // ✅ VALIDATION DE CAPACITÉ LOCALE À L'ÉTAPE 3 (Quantités)
          if (_currentStep == 2) {
            double nbPieces = double.tryParse(_lotNbPiecesController.text) ?? 1;
            double qteParP = double.tryParse(_lotQteParPieceController.text) ?? 0;
            double qteSimple = double.tryParse(_qteSimpleController.text) ?? 0;
            double qteFinale = isLotSelectionne ? (nbPieces * qteParP) : qteSimple;

            final listRayons = obtenirRayonsCompatibles(produitSelectionne);
            final chosenRayon = listRayons.firstWhere((r) => r.id == selectedRayonId, orElse: () => null);
            if (chosenRayon != null) {
              double capaciteMax = (chosenRayon.capaciteMax ?? 0).toDouble();
              double quantiteActuelle = (chosenRayon.quantiteActuelle ?? 0).toDouble();
              double espaceDisponible = capaciteMax - quantiteActuelle;

              if (qteFinale > espaceDisponible) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("Capacité du rayon dépassée. Il ne reste que ${espaceDisponible.toInt()} place(s) disponible(s) dans le rayon '${chosenRayon.nomRayon}' (Quantité saisie: ${qteFinale.toInt()})."),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 4),
                ));
                return; // Bloque le passage à l'étape suivante si le rayon est plein
              }
            }
          }

          if (_currentStep < _totalSteps - 1) {
            setState(() => _currentStep++);
          } else {
            _showRecapitulation();
          }
        },
        onStepCancel: () => _currentStep > 0 ? setState(() => _currentStep--) : Navigator.pop(context),
        controlsBuilder: _buildStepControls,
        steps: _buildSteps(),
      ),
    );
  }

  List<Step> _buildSteps() {
    final listRayonsCompatibles = obtenirRayonsCompatibles(produitSelectionne);

    return [
      _stepItem("Identification", [
        DropdownButtonFormField<Produit>(
          value: produitSelectionne, isExpanded: true,
          decoration: _inputDeco("Article *", Icons.inventory),
          items: produits.map((p) => DropdownMenuItem(value: p, child: Text(p.designation))).toList(),
          onChanged: widget.receptionInitiale != null ? null : (val) {
            if (val != null) setState(() {
              produitSelectionne = val;
              _rayonDestController.text = val.rayonId.nomRayon;
              selectedRayonId = val.rayonId.id;
              stockActuelDuProduit = val.quantiteActuelle.toDouble();
              _initialiserUnites(val);
            });
          },
        ),
        if (produitSelectionne != null) ...[
          const SizedBox(height: 10),
          _buildDropdown(selectedUniteVente ?? "", unitesDisponibles, "Unité", (v) => setState(() => selectedUniteVente = v)),
        ]
      ]),
      _stepItem("Origine", [
        _buildTextField(_fournisseurController, "Fournisseur", Icons.business, "Ex: Global Trading"),
        _buildTextField(_marqueController, "Marque", Icons.branding_watermark, "Ex: Samsung"),
      ]),
      _stepItem("Quantités", [
        if (isLotSelectionne) ...[
          _buildTextField(_lotNbPiecesController, "Nombre de Rouleaux / Lots *", Icons.grid_view, "Ex: 10", keyboard: TextInputType.number),
          _buildTextField(_lotQteParPieceController, "Qté par Unité ($selectedUniteVente) *", Icons.straighten, "Ex: 50", keyboard: TextInputType.number),
        ] else ...[
          _buildTextField(_qteSimpleController, "Nombre total de pièces ($selectedUniteVente) *", Icons.exposure_plus_1, "Ex: 500", keyboard: TextInputType.number),
        ],
        const SizedBox(height: 20),

        const Text("Rayon de destination", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 10),

        if (produitSelectionne != null)
          DropdownButtonFormField<String>(
            value: listRayonsCompatibles.any((r) => r.id == selectedRayonId) ? selectedRayonId : null,
            isExpanded: true,
            decoration: _inputDeco("Changer de rayon si plein", Icons.place),
            items: listRayonsCompatibles.map<DropdownMenuItem<String>>((rayon) {
              final double qte = (rayon.quantiteActuelle ?? 0).toDouble();
              final double maxCap = (rayon.capaciteMax ?? 1.0).toDouble();
              final double ratio = maxCap > 0 ? (qte / maxCap) : 0;
              final int pourcentage = (ratio * 100).toInt();

              Color statusColor = Colors.green;
              if (ratio > 0.8) {
                statusColor = Colors.red;
              } else if (ratio > 0.5) {
                statusColor = Colors.orange;
              }

              return DropdownMenuItem<String>(
                value: rayon.id,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        rayon.nomRayon ?? "Rayon",
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Text(
                      " (État: $pourcentage% Plein)",
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                selectedRayonId = val;
                final rayonTrouve = listRayonsCompatibles.firstWhere((r) => r.id == val, orElse: () => null);
                if (rayonTrouve != null) {
                  _rayonDestController.text = rayonTrouve.nomRayon;
                }
              });
            },
          ),

        // ✅ AFFICHAGE CONSTANT DE L'ESPACE RESTANT DANS LE RAYON SÉLECTIONNÉ
        if (selectedRayonId != null) ...[
          const SizedBox(height: 12),
          Builder(builder: (context) {
            final chosenRayon = listRayonsCompatibles.firstWhere((r) => r.id == selectedRayonId, orElse: () => null);
            if (chosenRayon != null) {
              final double qte = (chosenRayon.quantiteActuelle ?? 0).toDouble();
              final double maxCap = (chosenRayon.capaciteMax ?? 0).toDouble();
              final double reste = maxCap - qte;
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: orangeMax.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: orangeMax.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: orangeMax, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Espace restant dans le rayon : ${reste.toInt()} / ${maxCap.toInt()} emplacements libres.",
                        style: TextStyle(color: bleuNuit, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ]
      ]),
      _stepItem("Traçabilité", [
        _buildDateField("Date de Fabrication", dateFabrication, (d) => setState(() => dateFabrication = d)),
        _buildDateField("Date de Péremption (DLC) *", datePeremption, (d) => setState(() => datePeremption = d)),
        _buildDateField("Date d'Expiration (DLUO)", dateExpiration, (d) => setState(() => dateExpiration = d)),
      ]),
      _stepItem("Coût", [
        _buildTextField(_prixAchatController, isLotSelectionne ? "Prix d'achat TOTAL LOTS (GNF)" : "Prix d'achat TOTAL (GNF)", Icons.payments, "Ex: 150000", keyboard: TextInputType.number),
      ]),
      _stepItem("Action Finale", [
        _buildDropdown(selectedStatut, listeStatuts, "Statut", (v) => setState(() => selectedStatut = v!)),

        // ✅ RECOMMANDATION 3 MISE À JOUR : Clarification du stock de sécurité disponible
        if (selectedStatut == 'Rejetter')
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.3))
              ),
              child: Row(children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.red),
                const SizedBox(width: 10),
                Expanded(
                    child: Text(
                        "Attention : En cas de refus, la réception est annulée. Le stock disponible réel de cet article restera inchangé à : ${stockActuelDuProduit.toInt()} $selectedUniteVente.",
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)
                    )
                ),
              ]),
            ),
          ),

        _buildDropdown(selectedPriorite, listePriorites, "Priorité", (v) => setState(() => selectedPriorite = v!)),
        _buildTextField(_observationsController, "Observations", Icons.note, "Note libre", maxLines: 2),
        const SizedBox(height: 15),
        _buildPhotoSection(),
      ]),
    ];
  }

  Widget _buildPhotoSection() {
    return Column(children: [
      const Text("PHOTO DU BON OU PRODUIT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
      const SizedBox(height: 15),
      _photoReception == null
          ? Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _photoActionBtn(Icons.camera_alt, "Caméra", ImageSource.camera),
        _photoActionBtn(Icons.image, "Galerie", ImageSource.gallery),
      ])
          : Stack(children: [
        ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.file(_photoReception!, height: 120, width: double.infinity, fit: BoxFit.cover)),
        Positioned(right: 5, top: 5, child: InkWell(onTap: () => setState(() => _photoReception = null), child: const CircleAvatar(backgroundColor: Colors.red, radius: 15, child: Icon(Icons.close, color: Colors.white, size: 18)))),
      ]),
    ]);
  }

  Widget _photoActionBtn(IconData icon, String label, ImageSource src) {
    return ElevatedButton.icon(
      onPressed: () async {
        final img = await _picker.pickImage(source: src, imageQuality: 50);
        if (img != null) setState(() => _photoReception = File(img.path));
      },
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(backgroundColor: bleuNuit, foregroundColor: Colors.white),
    );
  }

  Step _stepItem(String title, List<Widget> content) {
    return Step(
      isActive: true,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      content: DelayedAnimation(delay: 100, child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: content),
      )),
    );
  }

  Widget _buildStepControls(context, details) {
    return Padding(
      padding: const EdgeInsets.only(top: 25),
      child: Row(children: [
        if (_currentStep > 0) Expanded(child: SizedBox(height: 55, child: OutlinedButton(onPressed: details.onStepCancel, style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: const Text("RETOUR", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))))),
        if (_currentStep > 0) const SizedBox(width: 15),
        Expanded(child: SizedBox(height: 55, child: ElevatedButton(onPressed: details.onStepContinue, style: ElevatedButton.styleFrom(backgroundColor: orangeMax, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: Text(_currentStep == _totalSteps - 1 ? (widget.receptionInitiale != null ? "MODIFIER" : "VÉRIFIER") : "CONTINUER", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))),
      ]),
    );
  }

  InputDecoration _inputDeco(String label, IconData icon) => InputDecoration(labelText: label, prefixIcon: Icon(icon, color: orangeMax, size: 20), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)));
  Widget _buildTextField(TextEditingController ctrl, String label, IconData icon, String hint, {TextInputType keyboard = TextInputType.text, bool readOnly = false, int maxLines = 1}) => Padding(padding: const EdgeInsets.only(top: 15), child: TextFormField(controller: ctrl, keyboardType: keyboard, readOnly: readOnly, maxLines: maxLines, decoration: _inputDeco(label, icon).copyWith(hintText: hint)));
  Widget _buildDropdown(String val, List<String> items, String label, ValueChanged<String?> onChanged) => Padding(padding: const EdgeInsets.only(top: 15), child: DropdownButtonFormField<String>(value: items.contains(val) ? val : items.first, decoration: _inputDeco(label, Icons.list), items: items.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: onChanged));
  Widget _buildDateField(String label, DateTime? date, Function(DateTime) onPicked) => Padding(padding: const EdgeInsets.only(top: 15), child: InkWell(onTap: () async {
    final p = await showDatePicker(context: context, initialDate: date ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2045));
    if (p != null) onPicked(p);
  }, child: InputDecorator(decoration: _inputDeco(label, Icons.calendar_today), child: Text(date == null ? "Cliquer pour choisir" : DateFormat('dd/MM/yyyy').format(date)))));
}