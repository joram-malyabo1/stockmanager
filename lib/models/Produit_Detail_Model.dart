// models/details_produit_model.dart

class DetailProduit {
  final String id;
  final String reference;
  final String designation;
  final TypeProduit typeProduit;  // Rouleau/Papier
  final Rayon rayon;
  final double quantiteActuelle;
  final double prixUnitaire;
  final String etat;
  final String? photoUrl;
  final Alertes alertes;
  final List<Mouvement> mouvements;
  final List<Reception> receptions;

  DetailProduit({
    required this.id,
    required this.reference,
    required this.designation,
    required this.typeProduit,
    required this.rayon,
    required this.quantiteActuelle,
    required this.prixUnitaire,
    required this.etat,
    this.photoUrl,
    required this.alertes,
    required this.mouvements,
    required this.receptions,
  });

  factory DetailProduit.fromJson(Map<String, dynamic> json) {  // ← json DIRECT
    final data = json['data'];  // ← Extraire data du wrapper
    if (data == null) throw Exception('Pas de data dans réponse API');

    return DetailProduit(
      id: data['_id'] ?? '',
      reference: data['reference'] ?? '',
      designation: data['designation'] ?? '',
      typeProduit: TypeProduit.fromJson(data['typeProduitId'] ?? {}),
      rayon: Rayon.fromJson(data['rayonId'] ?? {}),
      quantiteActuelle: (data['quantiteActuelle'] ?? 0).toDouble(),
      prixUnitaire: (data['prixUnitaire'] ?? 0).toDouble(),
      etat: data['etat'] ?? '',
      photoUrl: data['photoUrl'],
      alertes: Alertes.fromJson(data['alertes'] ?? {}),
      mouvements: (data['mouvements'] as List<dynamic>?)
          ?.map((m) => Mouvement.fromJson(m))
          .toList() ?? [],
      receptions: (data['receptions'] as List<dynamic>?)
          ?.map((r) => Reception.fromJson(r))
          .toList() ?? [],
    );
  }

}

// Classes nested
class TypeProduit {
  final String nomType;
  final String typeStockage;

  // ✅ CONSTRUCTEUR AJOUTÉ
  TypeProduit({
    required this.nomType,
    required this.typeStockage,
  });

  factory TypeProduit.fromJson(Map<String, dynamic> json) => TypeProduit(
    nomType: json['nomType'] ?? '',
    typeStockage: json['typeStockage'] ?? '',
  );
}

class Rayon {
  final String codeRayon;
  final String nomRayon;
  final int quantiteActuelle;

  // ✅ CONSTRUCTEUR AJOUTÉ
  Rayon({
    required this.codeRayon,
    required this.nomRayon,
    required this.quantiteActuelle,
  });

  factory Rayon.fromJson(Map<String, dynamic> json) => Rayon(
    codeRayon: json['codeRayon'] ?? '',
    nomRayon: json['nomRayon'] ?? '',
    quantiteActuelle: json['quantiteActuelle'] ?? 0,
  );
}

class Alertes {
  final bool stockBas;
  final String niveau;

  // ✅ CONSTRUCTEUR AJOUTÉ
  Alertes({
    required this.stockBas,
    required this.niveau,
  });

  factory Alertes.fromJson(Map<String, dynamic> json) => Alertes(
    stockBas: json['stockBas'] ?? false,
    niveau: json['niveau'] ?? '',
  );
}

class Mouvement {
  final String type;
  final double quantite;
  final String fournisseur;

  // ✅ CONSTRUCTEUR AJOUTÉ
  Mouvement({
    required this.type,
    required this.quantite,
    required this.fournisseur,
  });

  factory Mouvement.fromJson(Map<String, dynamic> json) => Mouvement(
    type: json['type'] ?? '',
    quantite: (json['quantite'] ?? 0).toDouble(),
    fournisseur: json['fournisseur'] ?? '',
  );
}

class Reception {
  final double quantite;
  final String fournisseur;
  final String lotNumber;
  final List<Lot> lots;

  // ✅ CONSTRUCTEUR AJOUTÉ
  Reception({
    required this.quantite,
    required this.fournisseur,
    required this.lotNumber,
    required this.lots,
  });

  factory Reception.fromJson(Map<String, dynamic> json) => Reception(
    quantite: (json['quantite'] ?? 0).toDouble(),
    fournisseur: json['fournisseur'] ?? '',
    lotNumber: json['lotNumber'] ?? '',
    lots: (json['lots'] as List?)?.map((l) => Lot.fromJson(l)).toList() ?? [],
  );
}

class Lot {
  final double quantiteRestante;
  final String uniteDetail;

  // ✅ CONSTRUCTEUR AJOUTÉ
  Lot({
    required this.quantiteRestante,
    required this.uniteDetail,
  });

  factory Lot.fromJson(Map<String, dynamic> json) => Lot(
    quantiteRestante: (json['quantiteRestante'] ?? 0).toDouble(),
    uniteDetail: json['uniteDetail'] ?? '',
  );
}

