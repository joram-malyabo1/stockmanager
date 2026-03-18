class Reception {
  final String id;
  final String produitNom;
  final String produitRef;
  final String rayonNom;
  final double quantite;
  final double prixTotal;
  final String fournisseur;
  final String photoUrl;
  final DateTime? dateReception;
  final String statutReception; // ex: EN_ATTENTE, VALIDÉ
  final String statut; // ex: controle, stocke

  // Champs pour les LOTS
  final int? nombrePieces;
  final double? quantiteParPiece;
  final String? uniteDetail;

  Reception({
    required this.id,
    required this.produitNom,
    required this.produitRef,
    required this.rayonNom,
    required this.quantite,
    required this.prixTotal,
    required this.fournisseur,
    required this.photoUrl,
    this.dateReception,
    required this.statutReception,
    required this.statut,
    this.nombrePieces,
    this.quantiteParPiece,
    this.uniteDetail,
  });

  factory Reception.fromJson(Map<String, dynamic> json) {
    // Extraction sécurisée des sous-objets
    final produit = json['produitId'] ?? {};
    final rayon = json['rayonId'] ?? {};

    return Reception(
      id: json['_id'] ?? '',
      produitNom: produit['designation'] ?? 'Produit inconnu',
      produitRef: produit['reference'] ?? '',
      rayonNom: rayon['nomRayon'] ?? 'Rayon inconnu',
      quantite: (json['quantite'] ?? 0).toDouble(),
      prixTotal: (json['prixTotal'] ?? 0).toDouble(),
      fournisseur: json['fournisseur'] ?? 'Inconnu',
      photoUrl: json['photoUrl'] ?? '',
      dateReception: json['dateReception'] != null ? DateTime.tryParse(json['dateReception']) : null,
      statutReception: json['statutReception'] ?? 'Inconnu',
      statut: json['statut'] ?? 'Inconnu',
      nombrePieces: json['nombrePieces'],
      quantiteParPiece: json['quantiteParPiece'] != null ? json['quantiteParPiece'].toDouble() : null,
      uniteDetail: json['uniteDetail'],
    );
  }
}