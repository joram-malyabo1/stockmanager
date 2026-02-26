import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'inscription.dart';
import '../../core/colors.dart';
import '../../core/delayed_animation.dart';
import '../../service/db_helper.dart';
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

  @override
  void dispose() {
    identifierController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ============================
  // VALIDATION
  // ============================
  bool _validateFields() {
    if (identifierController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs")),
      );
      return false;
    }
    return true;
  }

  // ============================
  // LOGIN OFFLINE
  // ============================
  Future<void> _loginOffline() async {
    if (!_validateFields()) return;

    setState(() => _isLoading = true);

    try {
      final userMap = await DBHelper().login(
        identifierController.text.trim(),
        passwordController.text.trim(),
      );

      if (userMap == null) {
        throw Exception("Utilisateur non trouvé ou inactif");
      }

      await LocalStorageService.saveLoginData(
        identifier: identifierController.text.trim(),
        password: passwordController.text.trim(),
        token: null, // IMPORTANT
        user: userMap,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => Dashboard(
            utilisateur: userMap,
            token: null, // OFFLINE
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Connexion offline échouée")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ============================
  // LOGIN ONLINE
  // ============================
  Future<void> _loginOnline() async {
    if (!_validateFields()) return;

    setState(() => _isLoading = true);

    try {
      final response = await AuthService.login(
        identifier: identifierController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (response['token'] == null || response['user'] == null) {
        throw Exception("Token ou utilisateur invalide");
      }

      final userMap = response['user'];

      await LocalStorageService.saveLoginData(
        identifier: identifierController.text.trim(),
        password: passwordController.text.trim(),
        token: response['token'],
        user: userMap,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => Dashboard(
            utilisateur: userMap,
            token: response['token'], // ONLINE
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Connexion online échouée")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ============================
  // UI
  // ============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 80, horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DelayedAnimation(
                delay: 300,
                child: Column(
                  children: [
                    Icon(Icons.store, size: 80, color: AppColors.green),
                    const SizedBox(height: 10),
                    const Text(
                      'Stock Manager',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    const Text('Connectez-vous pour continuer'),
                  ],
                ),
              ),
              const SizedBox(height: 50),

              TextField(
                controller: identifierController,
                decoration: InputDecoration(
                  labelText: 'Téléphone ou Email',
                  prefixIcon: Icon(Icons.person, color: AppColors.iconColor),
                ),
              ),
              const SizedBox(height: 25),

              TextField(
                controller: passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  prefixIcon: Icon(Icons.lock, color: AppColors.iconColor),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 35),

              ElevatedButton(
                onPressed: _isLoading ? null : _loginOffline,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("SE CONNECTER (Offline)",
                    style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 15),

              ElevatedButton(
                onPressed: _isLoading ? null : _loginOnline,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("SE CONNECTER (Online)",
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
