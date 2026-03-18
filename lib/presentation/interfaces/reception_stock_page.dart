import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stockmanager/presentation/interfaces/liste_receptions_page.dart';

// ASSUREZ-VOUS QUE CES IMPORTS CORRESPONDENT À VOS VRAIS FICHIERS
import '../../core/delayed_animation.dart';
import '../../service/produit_service.dart';
import '../../models/produit_model.dart';
import '../../models/Produit_Detail_Model.dart' as detail;

class ReceptionStockPage extends StatefulWidget {
  final String magasinId;
  final String magasinNom;
  final String token;

  const ReceptionStockPage({
    Key? key,
    required this.magasinId,
    required this.magasinNom,
    required this.token,
  }) : super(key: key);

  @override
  State<ReceptionStockPage> createState() => _ReceptionStockPageState();
}

class _ReceptionStockPageState extends State<ReceptionStockPage> {
  int _currentStep = 0;
  final int _totalSteps = 6;

  // --- CLE POUR LE COMPTEUR ANIME ---
  final GlobalKey<AnimatedTicketCounterState> _stepCounterKey = GlobalKey();

  // --- GESTION DES DONNÉES ET CHARGEMENT ---
  bool isLoading = true;
  List<Produit> produits = [];
  Produit? produitSelectionne;
  bool estCommande = false;

  // 🔍 DÉTECTION AUTOMATIQUE DU TYPE (LOT OU SIMPLE)
  bool get isLotSelectionne =>
      produitSelectionne?.typeProduitId.nomType.toLowerCase().contains("lot") ?? false;

  // --- CONTROLEURS DE TEXTE ---
  final _fournisseurController = TextEditingController();
  final _marqueController = TextEditingController();
  final _numLotController = TextEditingController();
  final _rayonDestController = TextEditingController();

  final _qteSimpleController = TextEditingController();
  final _lotNbPiecesController = TextEditingController();
  final _lotQteParPieceController = TextEditingController();

  final _prixAchatController = TextEditingController();

  // --- DATES ET STATUTS ---
  DateTime dateReception = DateTime.now();
  DateTime? datePeremption;
  DateTime? dateFabrication;

  String selectedStatut = 'A contrôler';
  String selectedPriorite = 'Normale';

  final List<String> listeStatuts = ['A contrôler', 'Stocker', 'Rejetter'];
  final List<String> listePriorites = ['Normale', 'Urgent'];

  // --- IMAGE ---
  File? _photoReception;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _chargerProduits();
  }

  Future<void> _chargerProduits() async {
    setState(() => isLoading = true);
    try {
      final liste = await ProduitService.getProduits(widget.magasinId, widget.token);
      if (mounted) {
        setState(() {
          produits = liste.where((p) => !p.estSupprime).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors du chargement des produits : $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _fournisseurController.dispose();
    _marqueController.dispose();
    _numLotController.dispose();
    _rayonDestController.dispose();
    _qteSimpleController.dispose();
    _lotNbPiecesController.dispose();
    _lotQteParPieceController.dispose();
    _prixAchatController.dispose();
    super.dispose();
  }

  // ==========================================
  // SOUMISSION DES DONNÉES À L'API
  // ==========================================
  Future<void> _soumettreReception() async {
    if (produitSelectionne == null) return;

    // 1. Fermer la boîte de dialogue du récapitulatif
    Navigator.pop(context);

    // 2. Afficher un indicateur de chargement global
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.green, backgroundColor: Colors.white),
      ),
    );

    try {
      String photoUrl = "";

      // 📸 ÉTAPE A : Upload de l'image si elle existe
      if (_photoReception != null) {
        print("⏳ Upload de la photo de réception...");
        final url = await ProduitService.uploadImageProduit(_photoReception!, widget.token);
        if (url != null && url.isNotEmpty) {
          photoUrl = url;
          print("✅ Photo réception uploadée : $photoUrl");
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("⚠️ Échec de l'upload de la photo"), backgroundColor: Colors.orange),
          );
        }
      }

      // 🧮 ÉTAPE B : Préparation des données (Calculs)
      double quantiteTotale = 0;
      double prixAchat = double.tryParse(_prixAchatController.text) ?? 0;

      int? nombrePieces;
      double? quantiteParPiece;
      double? prixParUnite;

      if (isLotSelectionne) {
        // --- CAS : PRODUIT LOT ---
        nombrePieces = int.tryParse(_lotNbPiecesController.text) ?? 0;
        quantiteParPiece = double.tryParse(_lotQteParPieceController.text) ?? 0;

        quantiteTotale = nombrePieces * quantiteParPiece; // La quantité totale
        prixParUnite = quantiteParPiece > 0 ? (prixAchat / quantiteParPiece) : 0;
      } else {
        // --- CAS : PRODUIT SIMPLE ---
        quantiteTotale = double.tryParse(_qteSimpleController.text) ?? 0;
      }

      // Formatage de la date (yyyy-MM-dd requis par l'API)
      String dateRecStr = DateFormat('yyyy-MM-dd').format(dateReception);

      // 🚀 ÉTAPE C : Envoi au Backend
      // On récupère le Map de la réponse (qui contient {success: true/false, message: "..."})
      final resultat = await ProduitService.creerReception(
        token: widget.token,
        magasinId: widget.magasinId,
        produitId: produitSelectionne!.id,
        rayonId: produitSelectionne!.rayonId.id,
        typeProduitId: produitSelectionne!.typeProduitId.id,
        quantite: quantiteTotale,
        prixAchat: prixAchat,
        fournisseur: _fournisseurController.text,
        dateReception: dateRecStr,
        photoUrl: photoUrl,
        observations: "Lot: ${_numLotController.text} | Statut: $selectedStatut | Priorité: $selectedPriorite",
        // Paramètres LOT
        isLot: isLotSelectionne,
        nombrePieces: nombrePieces,
        quantiteParPiece: quantiteParPiece,
        uniteDetail: "unité", // Modifiable selon vos besoins
        prixParUnite: prixParUnite,
      );

      // 3. Fermer l'indicateur de chargement global
      Navigator.pop(context);

      if (resultat["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Réception enregistrée avec succès !'), backgroundColor: Colors.green)
        );


        // Navigator.pop(context, true); // Retour à la page précédente

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ListeReceptionsPage(
              magasinId: widget.magasinId,
              token: widget.token,
            ),
          ),
        );



      } else {
        // 🔴 AFFICHE L'ERREUR EXACTE DU BACKEND (ex: "Capacité du rayon dépassée")
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${resultat["message"]}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5), // Affiche le message pendant 5 secondes
            )
        );
      }
    } catch (e) {
      Navigator.pop(context); // Fermer le chargement en cas d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erreur inattendue : $e'), backgroundColor: Colors.red)
      );
    }
  }

  // ==========================================
  // WIDGETS PERSONNALISÉS
  // ==========================================
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: icon != null ? Icon(icon, color: Colors.green) : null,
          filled: readOnly,
          fillColor: readOnly ? Colors.grey[200] : Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.green, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(String label, DateTime? dateValue, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 16.0),
      child: InkWell(
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: const Icon(Icons.calendar_today, color: Colors.green),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
          ),
          child: Text(
            dateValue == null ? "Appuyez pour sélectionner" : DateFormat('dd/MM/yyyy').format(dateValue),
            style: TextStyle(color: dateValue == null ? Colors.grey[600] : Colors.black, fontSize: 16),
          ),
        ),
      ),
    );
  }

  void _choisirSourceImage() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Ajouter une photo de réception", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.green),
              title: const Text('Prendre avec la Caméra'),
              onTap: () async {
                Navigator.pop(context);
                final img = await _picker.pickImage(source: ImageSource.camera);
                if (img != null) setState(() => _photoReception = File(img.path));
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text('Choisir dans la Galerie'),
              onTap: () async {
                Navigator.pop(context);
                final img = await _picker.pickImage(source: ImageSource.gallery);
                if (img != null) setState(() => _photoReception = File(img.path));
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Réception de Stock'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          // COMPTEUR ANIMÉ DANS L'APPBAR
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Row(
                children: [
                  const Text("Étape ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  AnimatedTicketCounter(
                    keyCounter: _stepCounterKey,
                    count: _currentStep + 1,
                  ),
                  Text(" / $_totalSteps", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6.0),
          child: LinearProgressIndicator(
            value: (_currentStep + 1) / _totalSteps,
            backgroundColor: Colors.red[100],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent[700]!),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        physics: const BouncingScrollPhysics(),

        stepIconBuilder: (int stepIndex, StepState stepState) {
          if (stepIndex < _currentStep) {
            return Container(
              decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
              child: const Center(child: Icon(Icons.check, color: Colors.white, size: 16)),
            );
          } else if (stepIndex == _currentStep) {
            return Container(
              decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
              child: Center(child: Text('${stepIndex + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            );
          } else {
            return Container(
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              child: const Center(child: Icon(Icons.close, color: Colors.white, size: 16)),
            );
          }
        },

        controlsBuilder: (context, details) {
          final isLast = _currentStep == _totalSteps - 1;
          return Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red, side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                      ),
                      onPressed: details.onStepCancel,
                      child: const Text('RETOUR', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                    ),
                    onPressed: details.onStepContinue,
                    child: Text(isLast ? 'VOIR LE RÉSUMÉ' : 'CONTINUER', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        },
        onStepContinue: () {
          if (_currentStep < _totalSteps - 1) {
            setState(() => _currentStep++);
            _stepCounterKey.currentState?.pop();
          } else {
            _showRecapitulation();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep--);
            _stepCounterKey.currentState?.pop();
          }
        },
        steps: _buildSteps(),
      ),
    );
  }

  List<Step> _buildSteps() {
    return [
      Step(
        isActive: _currentStep >= 0,
        title: const Text("1. Produit & Origine", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          children: [
            DelayedAnimation(
              key: ValueKey("step0_1_$_currentStep"),
              delay: 100,
              child: SwitchListTile(
                title: const Text("Est-ce une commande ?", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("Activez si vous réceptionnez un produit préalablement commandé."),
                activeColor: Colors.green,
                value: estCommande,
                onChanged: (val) => setState(() => estCommande = val),
              ),
            ),
            const SizedBox(height: 15),

            DelayedAnimation(
              key: ValueKey("step0_2_$_currentStep"),
              delay: 250,
              child: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: DropdownButtonFormField<Produit>(
                  value: produitSelectionne,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: "Sélectionnez le Produit *",
                    hintText: "Recherchez dans la liste",
                    prefixIcon: const Icon(Icons.inventory_2, color: Colors.green),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: produits.map((Produit p) {
                    return DropdownMenuItem<Produit>(
                      value: p,
                      child: Text(p.designation),
                    );
                  }).toList(),
                  onChanged: (Produit? val) {
                    setState(() {
                      produitSelectionne = val;
                      _rayonDestController.text = val?.rayonId.nomRayon ?? "Rayon non défini";
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),

      Step(
        isActive: _currentStep >= 1,
        title: const Text("2. Détails Commande", style: TextStyle(fontWeight: FontWeight.bold)),
        state: estCommande ? StepState.indexed : StepState.disabled,
        content: estCommande
            ? DelayedAnimation(
          key: ValueKey("step1_1_$_currentStep"),
          delay: 100,
          child: Container(
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.blue)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Rappel de ce qui a été commandé :", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[800])),
                const Divider(),
                if (!isLotSelectionne) ...const [
                  Text("• Quantité prévue : 500", style: TextStyle(fontSize: 15)),
                  Text("• Date prévue : 12/10/2023", style: TextStyle(fontSize: 15)),
                  Text("• Marque attendue : Air Force", style: TextStyle(fontSize: 15)),
                  Text("• État attendu : Neuf", style: TextStyle(fontSize: 15)),
                ] else ...const [
                  Text("• Nombre de pièces prévu : 10", style: TextStyle(fontSize: 15)),
                  Text("• Qté / pièce : 20", style: TextStyle(fontSize: 15)),
                  Text("• Marque attendue : Bazin Riche", style: TextStyle(fontSize: 15)),
                  Text("• Total prévu : 200", style: TextStyle(fontSize: 15)),
                  Text("• État attendu : Neuf", style: TextStyle(fontSize: 15)),
                ]
              ],
            ),
          ),
        )
            : DelayedAnimation(
            key: ValueKey("step1_disabled_$_currentStep"),
            delay: 100,
            child: const Text("Passez à l'étape suivante (Entrée libre).", style: TextStyle(color: Colors.grey))
        ),
      ),

      Step(
        isActive: _currentStep >= 2,
        title: const Text("3. Infos Générales", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          children: [
            DelayedAnimation(
              key: ValueKey("step2_1_$_currentStep"),
              delay: 100,
              child: _buildTextField(
                controller: _fournisseurController,
                label: "Fournisseur",
                hint: "Exemple: Fournisseur SARL...",
                icon: Icons.store,
              ),
            ),
            DelayedAnimation(
              key: ValueKey("step2_2_$_currentStep"),
              delay: 200,
              child: _buildTextField(
                controller: _marqueController,
                label: "Marque Reçue",
                hint: "Exemple: Air Force, Nike...",
                icon: Icons.branding_watermark,
              ),
            ),
            DelayedAnimation(
              key: ValueKey("step2_3_$_currentStep"),
              delay: 300,
              child: _buildTextField(
                controller: _numLotController,
                label: "Numéro de Lot",
                hint: "Exemple: LOT-2023-A001",
                icon: Icons.tag,
              ),
            ),
            DelayedAnimation(
              key: ValueKey("step2_4_$_currentStep"),
              delay: 400,
              child: _buildTextField(
                controller: _rayonDestController,
                label: "Rayon Destination",
                hint: "Le rayon s'affiche ici",
                icon: Icons.shelves,
                readOnly: true,
              ),
            ),
          ],
        ),
      ),

      Step(
        isActive: _currentStep >= 3,
        title: const Text("4. Quantités & Prix", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          children: [
            // 🔄 AFFICHAGE DYNAMIQUE SELON LE TYPE DE PRODUIT 🔄
            if (isLotSelectionne) ...[
              DelayedAnimation(
                key: ValueKey("step3_1_$_currentStep"),
                delay: 100,
                child: _buildTextField(
                  controller: _lotNbPiecesController,
                  label: "Nombre de pièces",
                  hint: "Ex: 10 (Cartons, Rouleaux...)",
                  keyboardType: TextInputType.number,
                  icon: Icons.view_in_ar,
                ),
              ),
              DelayedAnimation(
                key: ValueKey("step3_2_$_currentStep"),
                delay: 200,
                child: _buildTextField(
                  controller: _lotQteParPieceController,
                  label: "Quantité par pièce (Mètres, Litres...)",
                  hint: "Ex: 50",
                  keyboardType: TextInputType.number,
                  icon: Icons.straighten,
                ),
              ),
            ] else ...[
              DelayedAnimation(
                key: ValueKey("step3_1_bis_$_currentStep"),
                delay: 100,
                child: _buildTextField(
                  controller: _qteSimpleController,
                  label: "Quantité reçue",
                  hint: "Ex: 150",
                  keyboardType: TextInputType.number,
                  icon: Icons.numbers,
                ),
              ),
            ],
            DelayedAnimation(
              key: ValueKey("step3_3_$_currentStep"),
              delay: 300,
              child: _buildTextField(
                controller: _prixAchatController,
                label: "Prix d'achat unitaire",
                hint: "Ex: 50000",
                keyboardType: TextInputType.number,
                icon: Icons.money,
              ),
            ),
          ],
        ),
      ),

      Step(
        isActive: _currentStep >= 4,
        title: const Text("5. Dates", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          children: [
            DelayedAnimation(
              key: ValueKey("step4_1_$_currentStep"),
              delay: 100,
              child: _buildDateField("Date de Réception *", dateReception, () async {
                final picked = await showDatePicker(context: context, initialDate: dateReception, firstDate: DateTime(2000), lastDate: DateTime(2100));
                if (picked != null) setState(() => dateReception = picked);
              }),
            ),
            DelayedAnimation(
              key: ValueKey("step4_2_$_currentStep"),
              delay: 200,
              child: _buildDateField("Date de Fabrication (Optionnel)", dateFabrication, () async {
                final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                if (picked != null) setState(() => dateFabrication = picked);
              }),
            ),
            DelayedAnimation(
              key: ValueKey("step4_3_$_currentStep"),
              delay: 300,
              child: _buildDateField("Date de Péremption (Optionnel)", datePeremption, () async {
                final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2100));
                if (picked != null) setState(() => datePeremption = picked);
              }),
            ),
          ],
        ),
      ),

      Step(
        isActive: _currentStep >= 5,
        title: const Text("6. Finalisation", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          children: [
            DelayedAnimation(
              key: ValueKey("step5_1_$_currentStep"),
              delay: 100,
              child: Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 16.0),
                child: DropdownButtonFormField<String>(
                  value: selectedStatut,
                  decoration: InputDecoration(labelText: "Statut de réception", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                  items: listeStatuts.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (val) => setState(() => selectedStatut = val!),
                ),
              ),
            ),
            DelayedAnimation(
              key: ValueKey("step5_2_$_currentStep"),
              delay: 200,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: DropdownButtonFormField<String>(
                  value: selectedPriorite,
                  decoration: InputDecoration(labelText: "Priorité", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                  items: listePriorites.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (val) => setState(() => selectedPriorite = val!),
                ),
              ),
            ),
            DelayedAnimation(
              key: ValueKey("step5_3_$_currentStep"),
              delay: 300,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(border: Border.all(color: Colors.green), borderRadius: BorderRadius.circular(10), color: Colors.green[50]),
                child: Column(
                  children: [
                    Text("Photo de la réception", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[800])),
                    const SizedBox(height: 10),
                    _photoReception == null
                        ? IconButton(icon: const Icon(Icons.add_a_photo, size: 40, color: Colors.green), onPressed: _choisirSourceImage)
                        : Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                              _photoReception!,
                              height: 250,
                              width: double.infinity,
                              fit: BoxFit.contain
                          ),
                        ),
                        TextButton.icon(
                            onPressed: _choisirSourceImage,
                            icon: const Icon(Icons.edit),
                            label: const Text("Changer la photo")
                        )
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    ];
  }

  void _showRecapitulation() {
    double total = _calculerTotal();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.all(15),
        child: DelayedAnimation(
          delay: 100,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        const Icon(Icons.assignment_turned_in, size: 50, color: Colors.green),
                        const SizedBox(height: 5),
                        const Text("RÉCAPITULATIF", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                  ),
                  const Divider(thickness: 2, height: 30),

                  _ligneRecap("Produit", produitSelectionne?.designation ?? "Non défini", isBold: true),
                  _ligneRecap("Origine", estCommande ? "SUR COMMANDE" : "ENTRÉE LIBRE", color: Colors.blue),
                  _ligneRecap("Type", isLotSelectionne ? "PRODUIT LOT" : "PRODUIT SIMPLE"),
                  _ligneRecap("Fournisseur", _fournisseurController.text.isEmpty ? "Non défini" : _fournisseurController.text),
                  _ligneRecap("Marque", _marqueController.text.isEmpty ? "Non définie" : _marqueController.text),
                  _ligneRecap("Rayon", _rayonDestController.text),
                  _ligneRecap("N° Lot", _numLotController.text),

                  const Divider(height: 30),
                  Text("QUANTITÉS & FINANCES", style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 10),
                  if (isLotSelectionne) ...[
                    _ligneRecap("Nombre de pièces", _lotNbPiecesController.text),
                    _ligneRecap("Qté par pièce", _lotQteParPieceController.text),
                  ] else ...[
                    _ligneRecap("Quantité reçue", _qteSimpleController.text),
                  ],
                  _ligneRecap("Prix Unitaire", "${_prixAchatController.text} FG"),
                  _ligneRecap("PRIX TOTAL", "$total FG", isBold: true, color: Colors.red),

                  const Divider(height: 30),
                  Text("DATES & STATUT", style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 10),
                  _ligneRecap("Date Réception", DateFormat('dd/MM/yyyy').format(dateReception)),
                  _ligneRecap("Statut", selectedStatut, color: selectedStatut == 'Rejetter' ? Colors.red : Colors.green),
                  _ligneRecap("Priorité", selectedPriorite),

                  const SizedBox(height: 25),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), side: const BorderSide(color: Colors.red)),
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.edit, color: Colors.red),
                          label: const Text("MODIFIER", style: TextStyle(color: Colors.red)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 12)),
                          onPressed: _soumettreReception, // 🚀 Appel de la nouvelle fonction !
                          icon: const Icon(Icons.save, color: Colors.white),
                          label: const Text("ENREGISTRER", style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _ligneRecap(String label, String valeur, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text("$label :", style: TextStyle(color: Colors.grey[600], fontSize: 14))),
          Expanded(
              flex: 3,
              child: Text(
                  valeur,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                      color: color ?? Colors.black87,
                      fontSize: 15
                  )
              )
          ),
        ],
      ),
    );
  }

  double _calculerTotal() {
    double prix = double.tryParse(_prixAchatController.text) ?? 0;
    if (isLotSelectionne) {
      double nbPieces = double.tryParse(_lotNbPiecesController.text) ?? 0;
      return prix * nbPieces;
    }
    double qte = double.tryParse(_qteSimpleController.text) ?? 0;
    return prix * qte;
  }
}