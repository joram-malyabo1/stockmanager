import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../models/produit.dart';
import '../../models/categorie.dart';
import '../../service/db_helper.dart';

enum ImageChoice { image, couleur }

class AddArticlePage extends StatefulWidget {
  final String magasinId;
  final String magasinNom;
  final String token;

  const AddArticlePage({
    Key? key,
    required this.magasinId,
    required this.magasinNom,
    required this.token,
  }) : super(key: key);

  @override
  State<AddArticlePage> createState() => _AddArticlePageState();
}

class _AddArticlePageState extends State<AddArticlePage> {
  final _formKey = GlobalKey<FormState>();
  // ... reste du code identique jusqu'à build()

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nouveau Produit - ${widget.magasinNom}'), // ✅ Nom magasin
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(children: [
            // Tous les champs identiques...
            TextFormField(
              // controller: nomCtrl,
              decoration: const InputDecoration(labelText: 'Référence'),
              validator: (v) => v!.isEmpty ? 'Champ requis' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              // controller: nomCtrl, // designation
              decoration: const InputDecoration(labelText: 'Désignation'),
              maxLines: 2,
              validator: (v) => v!.isEmpty ? 'Champ requis' : null,
            ),
            // ... autres champs identiques
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('ENREGISTRER', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ]),
        ),
      ),
    );
  }
}



// class AddArticlePage extends StatefulWidget {
//   @override
//   State<AddArticlePage> createState() => _AddArticlePageState();
// }
//
// class _AddArticlePageState extends State<AddArticlePage> {
//   final _formKey = GlobalKey<FormState>();
//
//   // Controllers
//   final nomCtrl = TextEditingController();
//   final quantiteCtrl = TextEditingController();
//   final prixCtrl = TextEditingController();
//   final rayonCtrl = TextEditingController();
//   final etatCtrl = TextEditingController();
//   final stockMinCtrl = TextEditingController();
//
//   DateTime? dateExpiration;
//
//   File? selectedImage;
//   Color selectedColor = Colors.grey;
//   String devise = 'USD';
//   ImageChoice imageChoice = ImageChoice.image;
//
//   List<Categorie> categories = [];
//   Categorie? selectedCategorie;
//
//   final picker = ImagePicker();
//
//   @override
//   void initState() {
//     super.initState();
//     loadCategories();
//   }
//
//   // 🔥 Charger catégories depuis DB
//   Future<void> loadCategories() async {
//     final categoriesList = await DBHelper().getCategories(); // List<String>
//     setState(() {
//       categories = categoriesList
//           .where((c) => c != null)
//           .map((c) => Categorie(nom: c.toString()))
//           .toList();
//     });
//   }
//
//   // 🔥 Choisir image
//   Future pickImage() async {
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() => selectedImage = File(pickedFile.path));
//     }
//   }
//
//   // 🔥 Choisir date expiration
//   Future pickDateExpiration() async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: DateTime(2100),
//     );
//     if (picked != null) setState(() => dateExpiration = picked);
//   }
//
//   // 🔥 Enregistrer article
//   Future saveArticle() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     final article = Article(
//       nom: nomCtrl.text.trim(),
//       quantite: int.tryParse(quantiteCtrl.text) ?? 0,
//       prix: double.tryParse(prixCtrl.text) ?? 0,
//       devise: devise,
//       categorie: selectedCategorie?.nom,
//       rayon: rayonCtrl.text.trim(),
//       etatEmplacement: etatCtrl.text.trim(),
//       stockMin: int.tryParse(stockMinCtrl.text),
//       dateExpiration: dateExpiration,
//       image: imageChoice == ImageChoice.image
//           ? (selectedImage?.path ?? 'assets/no_image.png')
//           : 'assets/no_image.png',
//       couleur: imageChoice == ImageChoice.couleur ? selectedColor.value : null,
//       dateAjout: DateTime.now(),
//     );
//
//     await DBHelper().insertArticle(article);
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Article enregistré avec succès !')),
//     );
//
//     // Réinitialiser le formulaire
//     _formKey.currentState!.reset();
//     setState(() {
//       selectedImage = null;
//       selectedColor = Colors.grey;
//       selectedCategorie = null;
//       dateExpiration = null;
//       imageChoice = ImageChoice.image;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Ajouter Article'),
//         backgroundColor: Colors.green,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               // Nom
//               TextFormField(
//                 controller: nomCtrl,
//                 decoration: const InputDecoration(labelText: 'Nom'),
//                 validator: (v) => v!.isEmpty ? 'Champ requis' : null,
//               ),
//               const SizedBox(height: 16),
//
//               // Quantité
//               TextFormField(
//                 controller: quantiteCtrl,
//                 decoration: const InputDecoration(labelText: 'Quantité'),
//                 keyboardType: TextInputType.number,
//                 validator: (v) => v!.isEmpty ? 'Champ requis' : null,
//               ),
//               const SizedBox(height: 16),
//
//               // Prix + Devise
//               Row(
//                 children: [
//                   Expanded(
//                     flex: 2,
//                     child: TextFormField(
//                       controller: prixCtrl,
//                       decoration: const InputDecoration(labelText: 'Prix'),
//                       keyboardType: TextInputType.number,
//                       validator: (v) => v!.isEmpty ? 'Champ requis' : null,
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     flex: 1,
//                     child: DropdownButtonFormField<String>(
//                       value: devise,
//                       decoration: const InputDecoration(labelText: 'Devise'),
//                       items: ['USD', 'EUR', 'CDF']
//                           .map((d) => DropdownMenuItem(value: d, child: Text(d)))
//                           .toList(),
//                       onChanged: (val) => setState(() => devise = val!),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//
//               // Catégorie
//               DropdownButtonFormField<Categorie>(
//                 value: selectedCategorie,
//                 decoration: const InputDecoration(labelText: 'Catégorie'),
//                 items: categories
//                     .map((c) => DropdownMenuItem(value: c, child: Text(c.nom)))
//                     .toList(),
//                 onChanged: (val) => setState(() => selectedCategorie = val),
//                 validator: (v) => v == null ? 'Champ requis' : null,
//               ),
//               const SizedBox(height: 16),
//
//               // Rayon
//               TextFormField(
//                 controller: rayonCtrl,
//                 decoration: const InputDecoration(labelText: 'Rayon'),
//               ),
//               const SizedBox(height: 16),
//
//               // Etat emplacement
//               TextFormField(
//                 controller: etatCtrl,
//                 decoration: const InputDecoration(labelText: 'État emplacement'),
//               ),
//               const SizedBox(height: 16),
//
//               // Stock min
//               TextFormField(
//                 controller: stockMinCtrl,
//                 decoration: const InputDecoration(labelText: 'Stock minimum'),
//                 keyboardType: TextInputType.number,
//               ),
//               const SizedBox(height: 16),
//
//               // Date expiration
//               Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       dateExpiration == null
//                           ? 'Date expiration'
//                           : dateExpiration!.toLocal().toString().split(' ')[0],
//                     ),
//                   ),
//                   TextButton(
//                     onPressed: pickDateExpiration,
//                     child: const Text('Choisir date'),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//
//               // Radio bouton Image / Couleur
//               Row(
//                 children: [
//                   Radio<ImageChoice>(
//                     value: ImageChoice.image,
//                     groupValue: imageChoice,
//                     onChanged: (val) => setState(() => imageChoice = val!),
//                   ),
//                   const Text('Image'),
//                   const SizedBox(width: 16),
//                   Radio<ImageChoice>(
//                     value: ImageChoice.couleur,
//                     groupValue: imageChoice,
//                     onChanged: (val) => setState(() => imageChoice = val!),
//                   ),
//                   const Text('Couleur'),
//                 ],
//               ),
//               const SizedBox(height: 16),
//
//               // Choisir Image ou Couleur
//               if (imageChoice == ImageChoice.image)
//                 GestureDetector(
//                   onTap: pickImage,
//                   child: Container(
//                     width: 80,
//                     height: 80,
//                     color: Colors.grey[300],
//                     child: selectedImage != null
//                         ? Image.file(selectedImage!, fit: BoxFit.cover)
//                         : const Icon(Icons.image),
//                   ),
//                 )
//               else
//                 GestureDetector(
//                   onTap: () {
//                     showDialog(
//                       context: context,
//                       builder: (_) => AlertDialog(
//                         title: const Text('Choisir couleur'),
//                         content: SingleChildScrollView(
//                           child: BlockPicker(
//                             pickerColor: selectedColor,
//                             onColorChanged: (color) {
//                               setState(() => selectedColor = color);
//                             },
//                           ),
//                         ),
//                         actions: [
//                           TextButton(
//                               onPressed: () => Navigator.pop(context),
//                               child: const Text('OK'))
//                         ],
//                       ),
//                     );
//                   },
//                   child: Container(
//                     width: 80,
//                     height: 80,
//                     color: selectedColor,
//                   ),
//                 ),
//               const SizedBox(height: 24),
//
//               ElevatedButton(
//                 onPressed: saveArticle,
//                 child: const Text('ENREGISTRER'),
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
