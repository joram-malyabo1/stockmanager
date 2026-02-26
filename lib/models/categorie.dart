class Categorie {
  final int? id;
  final String nom;

  Categorie({this.id, required this.nom});

  factory Categorie.fromMap(Map<String, dynamic> map) {
    return Categorie(
      id: map['id'],
      nom: map['nom'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
    };
  }
}
