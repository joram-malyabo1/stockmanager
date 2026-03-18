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
