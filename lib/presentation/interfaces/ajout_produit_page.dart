import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';

import '../../core/delayed_animation.dart';
import '../../models/type_rayon_model.dart';
import '../../service/produit_service.dart';
import 'ListProduit.dart';
import 'welcome_page.dart';
import 'liste_receptions_page.dart';

class AjoutProduitPage extends StatefulWidget {
  final String magasinId;
  final String magasinNom;
  final String token;
  final String? guichetId;
  final String? utilisateurId;
  final String? nomUtilisateur;

  const AjoutProduitPage({
    Key? key,
    required this.magasinId,
    required this.magasinNom,
    required this.token,
    this.guichetId,
    this.utilisateurId,
    this.nomUtilisateur = "Utilisateur",
  }) : super(key: key);

  @override
  State<AjoutProduitPage> createState() => _AjoutProduitPageState();
}

class _AjoutProduitPageState extends State<AjoutProduitPage> {
  final _formKey = GlobalKey<FormState>();

  final Color orangeMax = const Color(0xFFFF7900);
  final Color bleuNuit = const Color(0xFF0D084B);

  final _refController = TextEditingController();
  final _nomController = TextEditingController();
  final _prixController = TextEditingController();
  final _qteController = TextEditingController();
  final _seuilController = TextEditingController();
  final _notesController = TextEditingController();

  TypeProduitSimple? typeSelectionne;
  RayonSimple? rayonSelectionne;
  List<TypeProduitSimple> typesProduits = [];
  List<RayonSimple> tousRayons = [];
  List<RayonSimple> rayonsFiltres = [];

  File? imageFichier;
  final ImagePicker _picker = ImagePicker();

  bool isLoading = true;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    chargerDonnees();
  }

  Future<void> chargerDonnees() async {
    try {
      final types = await ProduitService.getTypesProduits(widget.magasinId, widget.token);
      final rayons = await ProduitService.getRayons(widget.magasinId, widget.token);
      if (mounted) {
        setState(() {
          typesProduits = types;
          tousRayons = rayons;
          rayonsFiltres = [];
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(110),
      child: Container(
        decoration: BoxDecoration(
          color: bleuNuit,
          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(35), bottomRight: Radius.circular(35)),
          boxShadow: [BoxShadow(color: bleuNuit.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: SafeArea(
          child: Center(
            child: Text(
              'NOUVEAU PRODUIT',
              style: TextStyle(color: orangeMax, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.5),
            ),
          ),
        ),
      ),
    );
  }

  void onTypeChange(TypeProduitSimple? type) {
    setState(() {
      typeSelectionne = type;
      rayonSelectionne = null;
      if (type == null) {
        rayonsFiltres = [];
        return;
      }
      String nomType = type.nomType.toLowerCase();
      if (nomType.contains('rouleau')) {
        rayonsFiltres = tousRayons.where((r) => r.nomRayon.toLowerCase().contains('depot') || r.nomRayon.toLowerCase().contains('rouleau')).toList();
      } else if (nomType.contains('papier')) {
        rayonsFiltres = tousRayons.where((r) => r.nomRayon.toLowerCase().contains('imprimerie') || r.nomRayon.toLowerCase().contains('depot')).toList();
      } else {
        rayonsFiltres = tousRayons;
      }
    });
  }

  void _choisirPhoto(ImageSource source) async {
    final img = await _picker.pickImage(source: source, imageQuality: 50, maxWidth: 1000);
    if (img != null) setState(() => imageFichier = File(img.path));
  }

  void afficherMenuPhoto() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Source de l'image", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _photoActionBtn(Icons.camera_alt, "Caméra", ImageSource.camera),
                _photoActionBtn(Icons.image, "Galerie", ImageSource.gallery),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _photoActionBtn(IconData icon, String label, ImageSource src) {
    return InkWell(
      onTap: () { Navigator.pop(context); _choisirPhoto(src); },
      child: Column(
        children: [
          CircleAvatar(radius: 30, backgroundColor: orangeMax.withOpacity(0.1), child: Icon(icon, color: orangeMax)),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ✅ Remplacez votre fonction soumettre() par celle-ci


  Future<void> soumettre() async {
    // 1. Valider les champs textes
    if (!_formKey.currentState!.validate()) return;

    // 2. Vérifier si l'image est sélectionnée localement
    if (imageFichier == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("⚠️ La photo est obligatoire pour créer un produit"),
              backgroundColor: Colors.red
          )
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      // 3. Tentative d'upload
      final photoUrl = await ProduitService.uploadImageProduit(imageFichier!, widget.token);

      // 4. Si l'upload échoue, on arrête tout
      if (photoUrl == null) {
        throw "Le serveur n'a pas pu enregistrer l'image. Vérifiez votre connexion.";
      }

      print("✅ Image reçue : $photoUrl");

      // 5. Création du produit final
      final resultat = await ProduitService.creerProduit(
        magasinId: widget.magasinId,
        token: widget.token,
        reference: _refController.text.trim(),
        designation: _nomController.text.trim(),
        typeProduitId: typeSelectionne!.id,
        rayonId: rayonSelectionne!.id,
        prixUnitaire: double.parse(_prixController.text),
        quantiteEntree: double.parse(_qteController.text),
        seuilAlerte: double.parse(_seuilController.text.isEmpty ? '10' : _seuilController.text),
        photoUrl: photoUrl,
        notes: _notesController.text.trim(),
      );

      if (resultat['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Produit créé avec succès !"), backgroundColor: Colors.green)
          );
          Navigator.pop(context, true);
        }
      } else {
        // Message d'erreur spécifique du backend (ex: Rayon plein)
        throw resultat['message'] ?? "Erreur lors de la création";
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("❌ Erreur : $e"),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            )
        );
      }
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: orangeMax))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildInputGroup([
                _buildTextField(_refController, 'Référence *', Icons.tag, 'Ex: ART-001'),
                _buildTextField(_nomController, 'Nom du produit *', Icons.inventory, 'Ex: Papier A4 80g'),
              ], 100),
              const SizedBox(height: 20),
              _buildInputGroup([
                _buildDropdownType(),
                const SizedBox(height: 15),
                _buildDropdownRayon(),
              ], 300),
              const SizedBox(height: 20),
              _buildInputGroup([
                Row(children: [
                  Expanded(child: _buildTextField(_prixController, 'Prix Unit. *', Icons.payments, 'Ex: 15000', keyboard: TextInputType.number)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildTextField(_qteController, 'Qté Initiale *', Icons.add_business, 'Ex: 50', keyboard: TextInputType.number)),
                ]),
                _buildTextField(_seuilController, 'Seuil Alerte', Icons.warning_amber, 'Ex: 10', keyboard: TextInputType.number),
              ], 500),
              const SizedBox(height: 20),
              _buildPhotoSection(),
              const SizedBox(height: 20),
              _buildTextField(_notesController, 'Notes (optionnel)', Icons.note_alt_outlined, 'Informations complémentaires'),
              const SizedBox(height: 30),
              _buildSubmitButton(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputGroup(List<Widget> children, int delay) {
    return DelayedAnimation(
      delay: delay,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, IconData icon, String hint, {TextInputType keyboard = TextInputType.text, bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, top: 5),
      child: TextFormField(
        controller: ctrl, keyboardType: keyboard, readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label, hintText: hint, prefixIcon: Icon(icon, color: orangeMax, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade200)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade100)),
        ),
        validator: (v) => v!.isEmpty && label.contains('*') ? 'Requis' : null,
      ),
    );
  }

  Widget _buildDropdownType() {
    return DropdownButtonFormField<TypeProduitSimple>(
      value: typeSelectionne,
      decoration: InputDecoration(labelText: 'Type Produit *', prefixIcon: Icon(Icons.category, color: orangeMax), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
      items: typesProduits.map((t) => DropdownMenuItem(value: t, child: Text(t.nomType))).toList(),
      onChanged: onTypeChange,
      validator: (v) => v == null ? 'Requis' : null,
    );
  }

  Widget _buildDropdownRayon() {
    return DropdownButtonFormField<RayonSimple>(
      value: rayonSelectionne,
      decoration: InputDecoration(labelText: 'Rayon de stockage *', prefixIcon: Icon(Icons.shelves, color: orangeMax), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
      items: rayonsFiltres.map((r) => DropdownMenuItem(value: r, child: Text(r.nomRayon))).toList(),
      onChanged: (v) => setState(() => rayonSelectionne = v),
      validator: (v) => v == null ? 'Requis' : null,
    );
  }

  Widget _buildPhotoSection() {
    return DelayedAnimation(
      delay: 700,
      child: GestureDetector(
        onTap: isSubmitting ? null : afficherMenuPhoto,
        child: Container(
          height: 160, width: double.infinity,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: orangeMax.withOpacity(0.5))),
          child: imageFichier == null
              ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo, size: 40, color: orangeMax), const SizedBox(height: 10), Text("Photo obligatoire (cliquer ici)", style: TextStyle(color: bleuNuit, fontWeight: FontWeight.bold))])
              : ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.file(imageFichier!, fit: BoxFit.cover)),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return DelayedAnimation(
      delay: 900,
      child: SizedBox(
        width: double.infinity, height: 65,
        child: ElevatedButton(
          onPressed: isSubmitting ? null : soumettre,
          style: ElevatedButton.styleFrom(backgroundColor: orangeMax, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
          child: isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text('CRÉER LE PRODUIT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
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
          ListTile(leading: Icon(Icons.move_to_inbox, color: orangeMax), title: const Text("Réceptions"), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => ListeReceptionsPage(magasinId: widget.magasinId, token: widget.token))); }),
          const Spacer(),
          const Divider(),
          ListTile(leading: const Icon(Icons.logout, color: Colors.red), title: const Text("Déconnexion", style: TextStyle(color: Colors.red)), onTap: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const WelcomePage()), (r) => false)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}