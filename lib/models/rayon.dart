class Rayon {
  final String id;
  final String magasinId;
  final String codeRayon;
  final String nomRayon;
  final String typeRayon;
  final int capaciteMax;
  final String couleurRayon;
  final String iconeRayon;
  final List<TypeProduit> typesProduitsAutorises;
  final int quantiteActuelle;
  final String description;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int occupation;
  final int articles;
  final int capaciteOccupee;
  final int alertes;
  final Stocks stocks;

  Rayon({
    required this.id,
    required this.magasinId,
    required this.codeRayon,
    required this.nomRayon,
    required this.typeRayon,
    required this.capaciteMax,
    required this.couleurRayon,
    required this.iconeRayon,
    required this.typesProduitsAutorises,
    required this.quantiteActuelle,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.occupation,
    required this.articles,
    required this.capaciteOccupee,
    required this.alertes,
    required this.stocks,
  });

  factory Rayon.fromJson(Map<String, dynamic> json) {
    return Rayon(
      id: json['_id'] ?? '',
      magasinId: json['magasinId'] ?? '',
      codeRayon: json['codeRayon'] ?? '',
      nomRayon: json['nomRayon'] ?? '',
      typeRayon: json['typeRayon'] ?? '',
      capaciteMax: json['capaciteMax'] ?? 0,
      couleurRayon: json['couleurRayon'] ?? '#10b981',
      iconeRayon: json['iconeRayon'] ?? '📦',
      typesProduitsAutorises: (json['typesProduitsAutorises'] as List<dynamic>?)
          ?.map((t) => TypeProduit.fromJson(t))
          .toList() ?? [],
      quantiteActuelle: json['quantiteActuelle'] ?? 0,
      description: json['description'] ?? '',
      status: json['status'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      occupation: json['occupation'] ?? 0,
      articles: json['articles'] ?? 0,
      capaciteOccupee: json['capaciteOccupee'] ?? 0,
      alertes: json['alertes'] ?? 0,
      stocks: Stocks.fromJson(json['stocks'] ?? {}),
    );
  }
}

class TypeProduit {
  final String id;
  final String nomType;

  var icone;

  TypeProduit({required this.id, required this.nomType});

  factory TypeProduit.fromJson(Map<String, dynamic> json) {
    return TypeProduit(
      id: json['_id'] ?? '',
      nomType: json['nomType'] ?? '',
    );
  }

  get stats => null;

  get produits => null;
  

  get unitePrincipale => null;
}

class Stocks {
  final int occupation;
  final String articles;
  final int quantiteTotale;
  final String alertes;
  final int capacite;

  Stocks({
    required this.occupation,
    required this.articles,
    required this.quantiteTotale,
    required this.alertes,
    required this.capacite,
  });

  factory Stocks.fromJson(Map<String, dynamic> json) {
    return Stocks(
      occupation: json['occupation'] ?? 0,
      articles: json['articles'] ?? '0/0',
      quantiteTotale: json['quantiteTotale'] ?? 0,
      alertes: json['alertes'] ?? '0/0',
      capacite: json['capacite'] ?? 0,
    );
  }
}
