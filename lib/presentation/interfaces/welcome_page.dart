import 'package:flutter/material.dart';
import 'dashboard.dart';
import '../../core/delayed_animation.dart';
import '../../service/local_storage_service.dart';
import '../../service/auth_service.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final TextEditingController identifierController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  // Couleur Orange Pro (Max it)
  final Color orangeMax = const Color(0xFFFF7900);
  final Color noirProfond = const Color(0xFF1A1A1A);

  @override
  void dispose() {
    identifierController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool _validateFields() {
    if (identifierController.text.trim().isEmpty || passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir vos identifiants")),
      );
      return false;
    }
    return true;
  }

  Future<void> _loginOnline() async {
    if (!_validateFields()) return;

    setState(() => _isLoading = true);

    try {
      final response = await AuthService.login(
        identifier: identifierController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (response['token'] == null || response['user'] == null) {
        throw Exception("Erreur de réponse serveur");
      }

      await LocalStorageService.saveLoginData(
        identifier: identifierController.text.trim(),
        password: passwordController.text.trim(),
        token: response['token'],
        user: response['user'],
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => Dashboard(
            utilisateur: response['user'],
            token: response['token'],
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Identifiants incorrects ou problème réseau"),
          backgroundColor: Colors.red[700],
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER IMPRESSIONNANT ---
            _buildHeader(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // CHAMP IDENTIFIANT
                  DelayedAnimation(
                    delay: 500,
                    child: _buildInputField(
                      controller: identifierController,
                      label: "Identifiant",
                      hint: "Ex: 622 00 00 00 ou admin@mail.com",
                      icon: Icons.person_outline,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // CHAMP MOT DE PASSE
                  DelayedAnimation(
                    delay: 700,
                    child: _buildInputField(
                      controller: passwordController,
                      label: "Mot de passe",
                      hint: "Entrez votre mot de passe secret",
                      icon: Icons.lock_outline,
                      isPassword: true,
                    ),
                  ),

                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text("Mot de passe oublié ?", style: TextStyle(color: orangeMax, fontSize: 13)),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // BOUTON DE CONNEXION DE PRO
                  DelayedAnimation(
                    delay: 900,
                    child: SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _loginOnline,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: orangeMax,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          elevation: 4,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text("SE CONNECTER", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                            SizedBox(width: 10),
                            Icon(Icons.arrow_forward, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // FOOTER
                  const DelayedAnimation(
                    delay: 1100,
                    child: Text("StockManager v2.1.0 • Orange Max it", style: TextStyle(color: Colors.grey, fontSize: 11)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET POUR L'EN-TETE
  Widget _buildHeader() {
    return Stack(
      children: [
        Container(
          height: 320,
          decoration: BoxDecoration(
            color: orangeMax,
            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(80)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [orangeMax, orangeMax.withOpacity(0.8)],
            ),
          ),
        ),
        Positioned(
          bottom: 40,
          left: 40,
          child: DelayedAnimation(
            delay: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                  child: Icon(Icons.storefront_rounded, size: 50, color: orangeMax),
                ),
                const SizedBox(height: 20),
                const Text("Bienvenue sur", style: TextStyle(color: Colors.white70, fontSize: 18)),
                const Text("StockManager", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // WIDGET POUR LES CHAMPS DE SAISIE
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5, bottom: 8),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blueGrey)),
        ),
        TextField(
          controller: controller,
          obscureText: isPassword ? _obscurePassword : false,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
            prefixIcon: Icon(icon, color: orangeMax),
            suffixIcon: isPassword
                ? IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            )
                : null,
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: orangeMax, width: 1.5)),
          ),
        ),
      ],
    );
  }
}