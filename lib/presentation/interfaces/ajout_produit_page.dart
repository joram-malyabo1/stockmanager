import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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

  TypeProduitSimple? typeSelectionne;
  RayonSimple? rayonSelectionne;
  List<TypeProduitSimple> typesProduits = [];
  List<RayonSimple> tousRayons = [];
  List<RayonSimple> rayonsFiltres = [];
  File? imageFichier;
  bool isLoading = true;
  Map<String, String> champsExtra = {};

  @override
  void initState() {
    super.initState();
    chargerDonnees();
  }


  Future<void> chargerDonnees() async {
    print('🔄 Chargement pour magasin: ${widget.magasinId}');

    final types = await ProduitService.getTypesProduits(widget.magasinId, widget.token);
    final rayons = await ProduitService.getRayons(widget.magasinId, widget.token);

    print('📊 TYPES: ${types.length} → ${types.map((t) => "${t.nomType}").join(", ")}');
    print('📊 RAYONS: ${rayons.length} → ${rayons.map((r) => r.nomRayon).join(", ")}');

    setState(() {
      typesProduits = types;
      tousRayons = rayons;
      rayonsFiltres = rayons;  // Tous au début
      isLoading = false;
    });
  }



  void onTypeChange(TypeProduitSimple? type) {
    setState(() {
      typeSelectionne = type;
      rayonSelectionne = null;

      if (type != null) {
        // ✅ Filtre rayons qui acceptent ce type (depuis doc API: rayon.typesProduitsAutorises)
        rayonsFiltres = tousRayons.where((rayon) {
          // Mapper IDs types autorisés (à implémenter si backend les renvoie)
          return true;  // Temporaire: tous rayons → Filtrez par rayon.typesProduitsAutorises[]
        }).toList();
        print('🔍 Rayons filtrés pour ${type.nomType}: ${rayonsFiltres.length}');
      } else {
        rayonsFiltres = tousRayons;
      }
    });
  }


  void onRayonChange(RayonSimple? rayon) {
    setState(() => rayonSelectionne = rayon);
  }

  Future<void> choisirPhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => imageFichier = File(pickedFile.path));
    }
  }

  Future<void> soumettre() async {
    if (!_formKey.currentState!.validate()) return;
    if (typeSelectionne == null || rayonSelectionne == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Type et rayon obligatoires'))
      );
      return;
    }

    final success = await ProduitService.creerProduit(
      magasinId: widget.magasinId,
      token: widget.token,
      // ✅ AJOUTEZ ÇA
      reference: _refController.text,
      designation: _nomController.text,
      typeProduitId: typeSelectionne!.id,
      rayonId: rayonSelectionne!.id,
      prixUnitaire: double.parse(_prixController.text),
      quantiteEntree: double.parse(_qteController.text),
      seuilAlerte: double.parse(_seuilController.text),
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('✅ Produit créé !'), backgroundColor: Colors.green)
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('❌ Erreur création'), backgroundColor: Colors.red)
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouveau Produit'),
        backgroundColor: Color(0xFF1E6FD9),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: ConstrainedBox(  // ✅ SOLUTION
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 200,  // ✅ Hauteur fixe
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Référence
                  TextFormField(
                    controller: _refController,
                    decoration: InputDecoration(
                      labelText: 'Référence *',
                      prefixIcon: Icon(Icons.label),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
                  ),
                  const SizedBox(height: 16),

                  // Designation
                  TextFormField(
                    controller: _nomController,
                    decoration: InputDecoration(
                      labelText: 'Nom produit *',
                      prefixIcon: Icon(Icons.inventory_2),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
                  ),
                  const SizedBox(height: 16),

                  // Type Produit
                  DropdownButtonFormField<TypeProduitSimple>(
                    value: typeSelectionne,
                    decoration: InputDecoration(
                      labelText: 'Type Produit *',
                      prefixIcon: Icon(Icons.category),
                      border: OutlineInputBorder(),
                    ),
                    items: typesProduits.map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type.nomType),  // ✅ NOM SEUL
                    )).toList(),
                    onChanged: onTypeChange,
                    validator: (value) => value == null ? 'Type obligatoire' : null,
                  ),

                  const SizedBox(height: 16),

                  // Rayon (filtré)
                  DropdownButtonFormField<RayonSimple>(
                    value: rayonSelectionne,
                    decoration: InputDecoration(
                      labelText: 'Rayon *',
                      prefixIcon: Icon(Icons.shelves),
                      border: OutlineInputBorder(),
                    ),
                    items: rayonsFiltres.map((rayon) => DropdownMenuItem(
                      value: rayon,
                      child: Text(rayon.nomRayon),
                    )).toList(),
                    onChanged: onRayonChange,
                    validator: (value) => value == null ? 'Choisissez un rayon' : null,
                  ),
                  const SizedBox(height: 16),

                  // Prix et Quantité
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _prixController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Prix Unitaire *',
                            prefixIcon: Icon(Icons.attach_money),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'Requis';
                            if (double.tryParse(value!) == null) return 'Nombre valide';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _qteController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Qté Entrée *',
                            prefixIcon: Icon(Icons.add),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'Requis';
                            if (double.tryParse(value!) == null) return 'Nombre valide';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Seuil alerte
                  TextFormField(
                    controller: _seuilController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Seuil Alerte',
                      prefixIcon: Icon(Icons.warning),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) return null;
                      if (double.tryParse(value!) == null) return 'Nombre valide';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Bouton Créer
                  ElevatedButton(
                    onPressed: soumettre,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1E6FD9),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Créer Produit',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}