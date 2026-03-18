import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';

import '../../models/type_rayon_model.dart';
import '../../service/produit_service.dart';

class AjoutProduitPage extends StatefulWidget {
  final String magasinId;
  final String magasinNom;
  final String token;

  const AjoutProduitPage({
    Key? key,
    required this.magasinId,
    required this.magasinNom,
    required this.token,
  }) : super(key: key);

  @override
  State<AjoutProduitPage> createState() => _AjoutProduitPageState();
}

class _AjoutProduitPageState extends State<AjoutProduitPage> {
  final _formKey = GlobalKey<FormState>();

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

  bool isLoading = true;
  bool isSubmitting = false; // ⏳ Ajout de l'état de soumission

  @override
  void initState() {
    super.initState();
    chargerDonnees();
  }

  Future<void> chargerDonnees() async {
    print('🔄 Chargement pour magasin: ${widget.magasinId}');

    final types = await ProduitService.getTypesProduits(widget.magasinId, widget.token);
    final rayons = await ProduitService.getRayons(widget.magasinId, widget.token);

    if (mounted) {
      setState(() {
        typesProduits = types;
        tousRayons = rayons;
        rayonsFiltres = rayons;
        isLoading = false;
      });
    }
  }

  void onTypeChange(TypeProduitSimple? type) {
    setState(() {
      typeSelectionne = type;
      rayonSelectionne = null;

      if (type != null) {
        rayonsFiltres = tousRayons.where((rayon) => true).toList();
      } else {
        rayonsFiltres = tousRayons;
      }
    });
  }

  void onRayonChange(RayonSimple? rayon) {
    setState(() => rayonSelectionne = rayon);
  }

  // --- Choix entre Caméra et Galerie ---
  Future<void> choisirPhoto(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 80);
    if (pickedFile != null) {
      setState(() => imageFichier = File(pickedFile.path));
    }
  }

  void afficherMenuPhoto() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Color(0xFF1E6FD9)),
                  title: const Text('Choisir depuis la galerie'),
                  onTap: () {
                    Navigator.pop(context);
                    choisirPhoto(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Color(0xFF1E6FD9)),
                  title: const Text('Prendre une photo'),
                  onTap: () {
                    Navigator.pop(context);
                    choisirPhoto(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- NOUVELLE LOGIQUE DE SOUMISSION (EN 2 ÉTAPES) ---
  Future<void> soumettre() async {
    if (!_formKey.currentState!.validate()) return;
    if (typeSelectionne == null || rayonSelectionne == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Type et rayon obligatoires'))
      );
      return;
    }

    setState(() => isSubmitting = true); // Affiche le chargement sur le bouton

    String uploadedPhotoUrl = '';

    // 📸 ÉTAPE 1 : Si une image est sélectionnée, on l'upload d'abord au backend
    if (imageFichier != null) {
      print('⏳ Upload de l\'image en cours...');
      final String? url = await ProduitService.uploadImageProduit(imageFichier!, widget.token);

      if (url != null && url.isNotEmpty) {
        uploadedPhotoUrl = url;
        print('✅ Image uploadée avec succès : $uploadedPhotoUrl');
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('⚠️ L\'upload de l\'image a échoué. Produit créé sans photo.'),
                backgroundColor: Colors.orange,
              )
          );
        }
      }
    }

    // 📦 ÉTAPE 2 : Création du produit avec l'URL récupérée (ou vide si pas de photo/échec)
    final success = await ProduitService.creerProduit(
      magasinId: widget.magasinId,
      token: widget.token,
      reference: _refController.text,
      designation: _nomController.text,
      typeProduitId: typeSelectionne!.id,
      rayonId: rayonSelectionne!.id,
      prixUnitaire: double.parse(_prixController.text),
      quantiteEntree: double.parse(_qteController.text),
      seuilAlerte: double.parse(_seuilController.text.isEmpty ? '10' : _seuilController.text),
      photoUrl: uploadedPhotoUrl, // ✅ C'est ici que l'URL est envoyée au backend !
      notes: _notesController.text,
    );

    if (mounted) {
      setState(() => isSubmitting = false); // Arrête le chargement

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Produit créé avec succès !'), backgroundColor: Colors.green)
        );
        Navigator.pop(context, true); // Retourne à la liste des produits
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('❌ Erreur lors de la création'), backgroundColor: Colors.red)
        );
      }
    }
  }

  // --- Style des champs de texte (Design "Réception") ---
  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[600]),
      prefixIcon: Icon(icon, color: const Color(0xFF1E6FD9)),
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFF1E6FD9), width: 2),
      ),
    );
  }

  @override
  void dispose() {
    _refController.dispose();
    _nomController.dispose();
    _prixController.dispose();
    _qteController.dispose();
    _seuilController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Nouveau Produit', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E6FD9),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1E6FD9)))
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DelayedAnimation(
                delay: 100,
                child: TextFormField(
                  controller: _refController,
                  decoration: _buildInputDecoration('Référence *', Icons.label),
                  validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
                ),
              ),
              const SizedBox(height: 16),

              DelayedAnimation(
                delay: 200,
                child: TextFormField(
                  controller: _nomController,
                  decoration: _buildInputDecoration('Nom produit *', Icons.inventory_2),
                  validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
                ),
              ),
              const SizedBox(height: 16),

              DelayedAnimation(
                delay: 300,
                child: DropdownButtonFormField<TypeProduitSimple>(
                  value: typeSelectionne,
                  decoration: _buildInputDecoration('Type Produit *', Icons.category),
                  icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF1E6FD9)),
                  items: typesProduits.map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type.nomType),
                  )).toList(),
                  onChanged: isSubmitting ? null : onTypeChange,
                  validator: (value) => value == null ? 'Type obligatoire' : null,
                ),
              ),
              const SizedBox(height: 16),

              DelayedAnimation(
                delay: 400,
                child: DropdownButtonFormField<RayonSimple>(
                  value: rayonSelectionne,
                  decoration: _buildInputDecoration('Rayon *', Icons.shelves),
                  icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF1E6FD9)),
                  items: rayonsFiltres.map((rayon) => DropdownMenuItem(
                    value: rayon,
                    child: Text(rayon.nomRayon),
                  )).toList(),
                  onChanged: isSubmitting ? null : onRayonChange,
                  validator: (value) => value == null ? 'Choisissez un rayon' : null,
                ),
              ),
              const SizedBox(height: 16),

              DelayedAnimation(
                delay: 500,
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _prixController,
                        keyboardType: TextInputType.number,
                        decoration: _buildInputDecoration('Prix Unit. *', Icons.attach_money),
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Requis';
                          if (double.tryParse(value!) == null) return 'Invalide';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _qteController,
                        keyboardType: TextInputType.number,
                        decoration: _buildInputDecoration('Qté Entrée *', Icons.add),
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Requis';
                          if (double.tryParse(value!) == null) return 'Invalide';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              DelayedAnimation(
                delay: 600,
                child: TextFormField(
                  controller: _seuilController,
                  keyboardType: TextInputType.number,
                  decoration: _buildInputDecoration('Seuil Alerte', Icons.warning),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return null;
                    if (double.tryParse(value!) == null) return 'Invalide';
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),

              // --- SECTION PHOTO ---
              DelayedAnimation(
                delay: 700,
                child: GestureDetector(
                  onTap: isSubmitting ? null : afficherMenuPhoto,
                  child: Container(
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      border: Border.all(color: Colors.grey[300]!, width: 1.5, strokeAlign: BorderSide.strokeAlignInside),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: imageFichier == null
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E6FD9).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add_a_photo, size: 30, color: Color(0xFF1E6FD9)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ajouter une photo',
                          style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
                        ),
                      ],
                    )
                        : Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: SizedBox(
                            width: double.infinity,
                            child: Image.file(imageFichier!, fit: BoxFit.cover),
                          ),
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: CircleAvatar(
                            backgroundColor: Colors.white70,
                            child: IconButton(
                              icon: const Icon(Icons.edit, color: Colors.black),
                              onPressed: isSubmitting ? null : afficherMenuPhoto,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              DelayedAnimation(
                delay: 800,
                child: TextFormField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: _buildInputDecoration('Notes (optionnel)', Icons.note),
                ),
              ),
              const SizedBox(height: 30),

              // --- BOUTON DE SOUMISSION AVEC CHARGEMENT ---
              DelayedAnimation(
                delay: 900,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : soumettre,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E6FD9),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 4,
                    shadowColor: const Color(0xFF1E6FD9).withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: isSubmitting
                      ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      ),
                      SizedBox(width: 10),
                      Text('Création en cours...', style: TextStyle(fontSize: 16, color: Colors.white)),
                    ],
                  )
                      : const Text(
                    'Créer le Produit',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// CLASSES D'ANIMATIONS
// ============================================================================

/// Animation avec fade + slide
class DelayedAnimation extends StatefulWidget {
  final Widget child;
  final int delay;

  const DelayedAnimation({Key? key, required this.delay, required this.child}) : super(key: key);

  @override
  _DelayedAnimationState createState() => _DelayedAnimationState();
}

class _DelayedAnimationState extends State<DelayedAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animOffset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    final curve = CurvedAnimation(parent: _controller, curve: Curves.decelerate);

    _animOffset = Tween<Offset>(
      begin: const Offset(0.0, -0.35),
      end: Offset.zero,
    ).animate(curve);

    Timer(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: SlideTransition(position: _animOffset, child: widget.child),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// Animation fly to ticket
class AnimatedImageFly extends StatefulWidget {
  final Offset startOffset;
  final Offset endOffset;
  final Size size;
  final String image;
  final VoidCallback onEnd;

  const AnimatedImageFly({
    Key? key,
    required this.startOffset,
    required this.endOffset,
    required this.size,
    required this.image,
    required this.onEnd,
  }) : super(key: key);

  @override
  _AnimatedImageFlyState createState() => _AnimatedImageFlyState();
}

class _AnimatedImageFlyState extends State<AnimatedImageFly>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _position;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

    _position = Tween<Offset>(
      begin: widget.startOffset,
      end: widget.endOffset,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward().whenComplete(widget.onEnd);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _position,
      builder: (context, child) {
        return Positioned(
          top: _position.value.dy,
          left: _position.value.dx,
          child: SizedBox(
            width: widget.size.width,
            height: widget.size.height,
            child: Image.asset(widget.image),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// Widget compteur avec pulse
class AnimatedTicketCounter extends StatefulWidget {
  final int count;
  final GlobalKey keyCounter;

  const AnimatedTicketCounter({required this.count, required this.keyCounter, Key? key})
      : super(key: key);

  @override
  AnimatedTicketCounterState createState() => AnimatedTicketCounterState();
}

class AnimatedTicketCounterState extends State<AnimatedTicketCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _animation = Tween<double>(begin: 1.0, end: 1.4)
        .chain(CurveTween(curve: Curves.elasticOut))
        .animate(_controller);
  }

  void pop() {
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Container(
        key: widget.keyCounter,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          widget.count.toString(),
          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}