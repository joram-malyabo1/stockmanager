class Article {
  int? id;
  String nom;
  int? categorieId;
  int quantite;
  double prix;
  String devise;
  String? image;
  String? couleur;
  DateTime? dateAjout;
  String? etatEmplacement;
  String? rayon;
  int? stockMin;
  DateTime? dateExpiration;

  Article({
    this.id,
    required this.nom,
    this.categorieId,
    required this.quantite,
    required this.prix,
    required this.devise,
    this.image,
    this.couleur,
    this.dateAjout,
    this.etatEmplacement,
    this.rayon,
    this.stockMin,
    this.dateExpiration,
  });

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'categorie_id': categorieId,
      'quantite': quantite,
      'prix': prix,
      'devise': devise,
      'image': image,
      'couleur': couleur,
      'date_ajout': dateAjout?.toIso8601String(),
      'etat_emplacement': etatEmplacement,
      'rayon': rayon,
      'stock_min': stockMin,
      'date_expiration': dateExpiration?.toIso8601String(),
    };
  }
}
