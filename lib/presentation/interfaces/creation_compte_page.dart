import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../core/delayed_animation.dart';
import 'welcome_page.dart';

class CreationComptePage extends StatefulWidget {
  @override
  _CreationComptePageState createState() => _CreationComptePageState();
}

class _CreationComptePageState extends State<CreationComptePage> {
  final formKey = GlobalKey<FormState>();
  String? userType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              color: AppColors.green,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back, color: AppColors.green),
                        onPressed: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => WelcomePage()),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "Création Compte",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 60),
                ],
              ),
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 40),

              DelayedAnimation(
                delay: 500,
                child: Text("Vous êtes", style: TextStyle(fontSize: 30, color: Colors.black)),
              ),
              DelayedAnimation(
                delay: 1000,
                child: Text("Le Bienvenu", style: TextStyle(fontSize: 30, color: Colors.black)),
              ),
              SizedBox(height: 30),

              // Boutons radio verticaux
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRadioOption("personne", Icons.person, "Personne Physique"),
                  SizedBox(height: 10),
                  _buildRadioOption("entreprise", Icons.business, "Entreprise"),
                ],
              ),

              SizedBox(height: 30),

              // Affichage dynamique du formulaire
              AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                child: userType == null
                    ? SizedBox.shrink()
                    : Column(
                  key: ValueKey(userType),
                  children: [
                    _buildCommonFields(),
                    SizedBox(height: 20),
                    if (userType == 'personne') _buildPersonneFields(),
                    if (userType == 'entreprise') _buildEntrepriseFields(),
                    SizedBox(height: 30),
                    DelayedAnimation(
                      delay: 2000,
                      child: _buildSubmitButton(),
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadioOption(String value, IconData icon, String label) {
    final isSelected = userType == value;

    return InkWell(
      onTap: () => setState(() => userType = value),
      child: Row(
        children: [
          Radio<String>(
            value: value,
            groupValue: userType,
            onChanged: (val) => setState(() => userType = val!),
            activeColor: AppColors.green,
          ),
          Icon(icon, color: AppColors.green),
          SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.green : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommonFields() {
    return Column(
      children: [
        _inputField("Nom", Icons.person, delay: 1100),
        SizedBox(height: 20),
        _inputField("Numéro de téléphone", Icons.phone, delay: 1200),
        SizedBox(height: 20),
        _inputField("Email", Icons.email, delay: 1300),
        SizedBox(height: 20),
        _inputField("Adresse physique", Icons.location_city, delay: 1400),
      ],
    );
  }

  Widget _buildPersonneFields() {
    return Column(
      children: [

      ],
    );
  }

  Widget _buildEntrepriseFields() {
    return Column(
      children: [
        _inputField("Raison sociale", Icons.business_center, delay: 1500),
        SizedBox(height: 20),
        _inputField("Numéro NIF", Icons.confirmation_number, delay: 1600),
      ],
    );
  }

  Widget _inputField(String label, IconData icon, {int delay = 0}) {
    return DelayedAnimation(
      delay: delay,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: TextFormField(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: AppColors.iconColor),
            border: InputBorder.none,
            floatingLabelBehavior: FloatingLabelBehavior.auto,
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: () {
        if (formKey.currentState!.validate()) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Compte enregistré !")),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        shape: StadiumBorder(),
        backgroundColor: AppColors.green,
        padding: EdgeInsets.all(13),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.save, color: Colors.white),
          SizedBox(width: 10),
          Text(
            'ENREGISTRER',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
