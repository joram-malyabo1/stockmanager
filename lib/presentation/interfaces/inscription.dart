import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../service/db_helper.dart';

class InscriptionUtilisateur extends StatefulWidget {
  @override
  State<InscriptionUtilisateur> createState() => _InscriptionUtilisateurState();
}

class _InscriptionUtilisateurState extends State<InscriptionUtilisateur> {
  final _nomCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  String role = "VENDEUR";
  bool accepted = false;
  bool loading = true;

  Map<String, dynamic>? contexte;

  @override
  void initState() {
    super.initState();
    initContexte();
  }

  Future<void> initContexte() async {
    // S'assure qu'un contexte existe
    await DBHelper().insertContexteParDefaut();

    contexte = await DBHelper().getContexteActif();

    setState(() {
      loading = false;
    });
  }

  Future<void> saveUser() async {
    if (!accepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Veuillez accepter les conditions")),
      );
      return;
    }

    if (_nomCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Nom et mot de passe obligatoires")),
      );
      return;
    }

    await DBHelper().insertUtilisateur({
      'nom': _nomCtrl.text,
      'telephone': _phoneCtrl.text,
      'email': _emailCtrl.text,
      'password': _passwordCtrl.text,
      'role': role,
      'entreprise_nom': contexte!['entreprise_nom'],
      'magasin_nom': contexte!['magasin_nom'],
      'guichet_nom': contexte!['guichet_nom'],
      'profil': null,
      'actif': 1,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Utilisateur créé avec succès")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (contexte == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Créer utilisateur")),
        body: Center(
          child: Text(
            "Aucun contexte entreprise trouvé.\nVeuillez synchroniser.",
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Créer utilisateur"),
        backgroundColor: AppColors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [

            // ===== CONTEXTE =====
            Text("Entreprise : ${contexte!['entreprise_nom']}"),
            Text("Magasin : ${contexte!['magasin_nom']}"),
            Text("Guichet : ${contexte!['guichet_nom']}"),
            Divider(height: 30),

            // ===== FORMULAIRE =====
            TextField(
              controller: _nomCtrl,
              decoration: InputDecoration(
                labelText: "Nom complet",
                prefixIcon: Icon(Icons.person),
              ),
            ),

            TextField(
              controller: _emailCtrl,
              decoration: InputDecoration(
                labelText: "Email",
                prefixIcon: Icon(Icons.email),
              ),
            ),

            TextField(
              controller: _phoneCtrl,
              decoration: InputDecoration(
                labelText: "Téléphone",
                prefixIcon: Icon(Icons.phone),
              ),
            ),

            TextField(
              controller: _passwordCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Mot de passe",
                prefixIcon: Icon(Icons.lock),
              ),
            ),

            SizedBox(height: 15),

            DropdownButtonFormField<String>(
              value: role,
              decoration: InputDecoration(
                labelText: "Rôle",
                prefixIcon: Icon(Icons.security),
              ),
              items: ["ADMIN", "GERANT", "VENDEUR"]
                  .map(
                    (r) => DropdownMenuItem(
                  value: r,
                  child: Text(r),
                ),
              )
                  .toList(),
              onChanged: (v) => setState(() => role = v!),
            ),

            CheckboxListTile(
              value: accepted,
              onChanged: (v) => setState(() => accepted = v!),
              title: Text("J'accepte les conditions"),
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: saveUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                padding: EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                "ENREGISTRER",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            )
          ],
        ),
      ),
    );
  }
}
