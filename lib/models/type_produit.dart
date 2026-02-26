class TypeProduit {
  final String id;
  final String magasinId;
  final String nomType;
  final String unitePrincipale;
  final String code;
  final String icone;
  final String couleur;
  final List<ChampSupplementaire> champsSupplementaires;
  final int seuilAlerte;
  final int capaciteMax;
  final bool photoRequise;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Produit> produits;
  final Stats stats;

  TypeProduit({
    required this.id,
    required this.magasinId,
    required this.nomType,
    required this.unitePrincipale,
    required this.code,
    required this.icone,
    required this.couleur,
    required this.champsSupplementaires,
    required this.seuilAlerte,
    required this.capaciteMax,
    required this.photoRequise,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.produits,
    required this.stats,
  });

  factory TypeProduit.fromJson(Map<String, dynamic> json) {
    return TypeProduit(
      id: json['_id'] ?? '',
      magasinId: json['magasinId'] ?? '',
      nomType: json['nomType'] ?? '',
      unitePrincipale: json['unitePrincipale'] ?? '',
      code: json['code'] ?? '',
      icone: json['icone'] ?? '📦',
      couleur: json['couleur'] ?? '#10b981',
      champsSupplementaires: (json['champsSupplementaires'] as List<dynamic>?)
          ?.map((c) => ChampSupplementaire.fromJson(c))
          .toList() ?? [],
      seuilAlerte: json['seuilAlerte'] ?? 0,
      capaciteMax: json['capaciteMax'] ?? 0,
      photoRequise: json['photoRequise'] ?? false,
      status: json['status'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      produits: (json['produits'] as List<dynamic>?)
          ?.map((p) => Produit.fromJson(p))
          .toList() ?? [],
      stats: Stats.fromJson(json['stats'] ?? {}),
    );
  }
}

class ChampSupplementaire {
  final String nomChamp;
  final String typeChamp;
  final List<String> optionsChamp;
  final String id;

  ChampSupplementaire({
    required this.nomChamp,
    required this.typeChamp,
    required this.optionsChamp,
    required this.id,
  });

  factory ChampSupplementaire.fromJson(Map<String, dynamic> json) {
    return ChampSupplementaire(
      id: json['_id'] ?? '',
      nomChamp: json['nomChamp'] ?? '',
      typeChamp: json['typeChamp'] ?? '',
      optionsChamp: (json['optionsChamp'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }
}

class Produit {
  final String id;
  final String reference;
  final String designation;
  final RayonId rayonId;
  final int quantiteActuelle;
  final double prixUnitaire;
  final int seuilAlerte;
  final String? photoUrl;
  final int nombreAlertes;

  Produit({
    required this.id,
    required this.reference,
    required this.designation,
    required this.rayonId,
    required this.quantiteActuelle,
    required this.prixUnitaire,
    required this.seuilAlerte,
    this.photoUrl,
    required this.nombreAlertes,
  });

  factory Produit.fromJson(Map<String, dynamic> json) {
    return Produit(
      id: json['_id'] ?? '',
      reference: json['reference'] ?? '',
      designation: json['designation'] ?? '',
      rayonId: RayonId.fromJson(json['rayonId'] ?? {}),
      quantiteActuelle: json['quantiteActuelle'] ?? 0,
      prixUnitaire: double.tryParse(json['prixUnitaire']?.toString() ?? '0') ?? 0.0,
      seuilAlerte: json['seuilAlerte'] ?? 0,
      photoUrl: json['photoUrl'],
      nombreAlertes: json['nombreAlertes'] ?? 0,
    );
  }
}

class RayonId {
  final String id;
  final String codeRayon;
  final String nomRayon;

  RayonId({required this.id, required this.codeRayon, required this.nomRayon});

  factory RayonId.fromJson(Map<String, dynamic> json) {
    return RayonId(
      id: json['_id'] ?? '',
      codeRayon: json['codeRayon'] ?? '',
      nomRayon: json['nomRayon'] ?? '',
    );
  }
}

class Stats {
  final String enStock;
  final int articles;
  final int alertes;
  final String valeur;

  Stats({
    required this.enStock,
    required this.articles,
    required this.alertes,
    required this.valeur,
  });

  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      enStock: json['enStock'] ?? '0',
      articles: json['articles'] ?? 0,
      alertes: json['alertes'] ?? 0,
      valeur: json['valeur'] ?? '0',
    );
  }
}
