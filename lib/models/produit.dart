

class Article {
  int? id;
  String nom;
  int quantite;
  double prix;
  String devise;
  String? categorie; // ⚠️ logique métier seulement (PAS en base)
  String? magasinNom;
  String image; // non null
  int? couleur; // Color.value
  DateTime? dateAjout;
  String? etatEmplacement;
  String? rayon;
  int? stockMin;
  DateTime? dateExpiration;

  Article({
    this.id,
    required this.nom,
    required this.quantite,
    required this.prix,
    required this.devise,
    this.categorie,
    this.magasinNom,
    required this.image,
    this.couleur,
    this.dateAjout,
    this.etatEmplacement,
    this.rayon,
    this.stockMin,
    this.dateExpiration,
  });

  /// 🔥 IMPORTANT : PAS DE 'categorie' ICI
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'quantite': quantite,
      'prix': prix,
      'devise': devise,
      'magasin_nom': magasinNom,
      'image': image,
      'couleur': couleur,
      'date_ajout': dateAjout?.toIso8601String(),
      'etat_emplacement': etatEmplacement,
      'rayon': rayon,
      'stock_min': stockMin,
      'date_expiration': dateExpiration?.toIso8601String(),
    };
  }

  factory Article.fromMap(Map<String, dynamic> map) {
    return Article(
      id: map['id'],
      nom: map['nom'],
      quantite: map['quantite'] ?? 0,
      prix: map['prix']?.toDouble() ?? 0.0,
      devise: map['devise'] ?? 'USD',
      magasinNom: map['magasin_nom'],
      image: map['image'] ?? 'assets/no_image.png',
      couleur: map['couleur'],
      dateAjout:
      map['date_ajout'] != null ? DateTime.parse(map['date_ajout']) : null,
      etatEmplacement: map['etat_emplacement'],
      rayon: map['rayon'],
      stockMin: map['stock_min'],
      dateExpiration: map['date_expiration'] != null
          ? DateTime.parse(map['date_expiration'])
          : null,
    );
  }
}
