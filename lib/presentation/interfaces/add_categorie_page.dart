import 'package:flutter/material.dart';
import '../../models/categorie.dart';
import '../../service/db_helper.dart';

class AddCategoriePage extends StatefulWidget {
  const AddCategoriePage({Key? key}) : super(key: key);

  @override
  State<AddCategoriePage> createState() => _AddCategoriePageState();
}

class _AddCategoriePageState extends State<AddCategoriePage> {
  final TextEditingController nomController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> saveCategorie() async {
    if (!_formKey.currentState!.validate()) return;

    final categorie = Categorie(
      nom: nomController.text.trim(),
    );

    await DBHelper().insertCategorie(categorie);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Catégorie enregistrée')),
    );

    nomController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter une catégorie')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nomController,
                decoration: const InputDecoration(
                  labelText: 'Nom de la catégorie',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Champ obligatoire' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveCategorie,
                child: const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
