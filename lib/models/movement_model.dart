class StockMovement {
  final String id;
  final String designation;
  final String reference;
  final String type; // SORTIE, RECEPTION, ENTREE_INITIALE
  final double quantite;
  final String utilisateur;
  final String observations;
  final String statut;
  final DateTime date;

  StockMovement({
    required this.id,
    required this.designation,
    required this.reference,
    required this.type,
    required this.quantite,
    required this.utilisateur,
    required this.observations,
    required this.statut,
    required this.date,
  });

  factory StockMovement.fromJson(Map<String, dynamic> json) {
    return StockMovement(
      id: json['_id'],
      designation: json['produitId']['designation'] ?? 'Inconnu',
      reference: json['produitId']['reference'] ?? '-',
      type: json['type'],
      quantite: json['quantite'].toDouble(),
      utilisateur: "${json['utilisateurId']['prenom']} ${json['utilisateurId']['nom']}",
      observations: json['observations'] ?? '',
      statut: json['statut'] ?? '',
      date: DateTime.parse(json['dateDocument']),
    );
  }
}