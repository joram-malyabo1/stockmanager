
class Utilisateur {
  int? id;
  String nom;
  String? telephone;
  String? email;
  String password;
  String role; // ADMIN, GERANT, VENDEUR
  String? entrepriseNom;
  String? magasinNom;
  String? guichetNom;
  String? profil;
  bool actif;

  Utilisateur({
    this.id,
    required this.nom,
    this.telephone,
    this.email,
    required this.password,
    required this.role,
    this.entrepriseNom,
    this.magasinNom,
    this.guichetNom,
    this.profil,
    this.actif = true,
  });

  factory Utilisateur.fromMap(Map<String, dynamic> map) {
    return Utilisateur(
      id: map['id'],
      nom: map['nom'],
      telephone: map['telephone'],
      email: map['email'],
      password: map['password'],
      role: map['role'],
      entrepriseNom: map['entreprise_nom'],
      magasinNom: map['magasin_nom'],
      guichetNom: map['guichet_nom'],
      profil: map['profil'],
      actif: map['actif'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'telephone': telephone,
      'email': email,
      'password': password,
      'role': role,
      'entreprise_nom': entrepriseNom,
      'magasin_nom': magasinNom,
      'guichet_nom': guichetNom,
      'profil': profil,
      'actif': actif ? 1 : 0,
    };
  }
}
