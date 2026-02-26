class Vente {
  int? id;
  int articleId;
  int quantite;
  double montantTotal;
  String devise; // USD ou FC
  String? date;
  String? utilisateurNom;
  String? magasinNom;
  String? guichetNom;

  Vente({
    this.id,
    required this.articleId,
    required this.quantite,
    required this.montantTotal,
    this.devise = 'USD',
    this.date,
    this.utilisateurNom,
    this.magasinNom,
    this.guichetNom,
  });

  factory Vente.fromMap(Map<String, dynamic> map) {
    return Vente(
      id: map['id'],
      articleId: map['article_id'],
      quantite: map['quantite'],
      montantTotal: map['montant_total'],
      devise: map['devise'] ?? 'USD',
      date: map['date'],
      utilisateurNom: map['utilisateur_nom'],
      magasinNom: map['magasin_nom'],
      guichetNom: map['guichet_nom'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'article_id': articleId,
      'quantite': quantite,
      'montant_total': montantTotal,
      'devise': devise,
      'date': date,
      'utilisateur_nom': utilisateurNom,
      'magasin_nom': magasinNom,
      'guichet_nom': guichetNom,
    };
  }
}
