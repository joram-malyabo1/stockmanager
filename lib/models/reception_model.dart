class Reception {
  final String id;
  final String produitId;
  final String rayonId;
  final String? typeProduitId;
  final String produitNom;
  final String produitRef;
  final String rayonNom;
  final double quantite;
  final double prixTotal;
  final String fournisseur;
  final String photoUrl;
  final DateTime? dateReception;
  final String statutReception;
  final String statut;
  final String? observations; // ✅ AJOUTÉ ICI

  // Champs pour les LOTS
  final int? nombrePieces;
  final double? quantiteParPiece;
  final String? uniteDetail;

  Reception({
    required this.id,
    required this.produitId,
    required this.rayonId,
    this.typeProduitId,
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
    this.observations, // ✅ AJOUTÉ ICI
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
      produitId: produit['_id'] ?? '',
      rayonId: rayon['_id'] ?? '',
      typeProduitId: produit['typeProduitId'] is Map
          ? produit['typeProduitId']['_id']
          : produit['typeProduitId'],

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
      observations: json['observations'], // ✅ AJOUTÉ ICI
      nombrePieces: json['nombrePieces'],
      quantiteParPiece: json['quantiteParPiece'] != null ? (json['quantiteParPiece'] as num).toDouble() : null,
      uniteDetail: json['uniteDetail'],
    );
  }
}