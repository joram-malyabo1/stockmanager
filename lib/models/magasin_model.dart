class Magasin {
  final String id;
  final BusinessId businessId;
  final String nomMagasin;
  final String adresse;
  final String telephone;
  final double latitude;
  final double longitude;
  final String? photoUrl;
  final ManagerId managerId;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Guichet> guichets;
  final int vendeursCount;

  Magasin({
    required this.id,
    required this.businessId,
    required this.nomMagasin,
    required this.adresse,
    required this.telephone,
    required this.latitude,
    required this.longitude,
    this.photoUrl,
    required this.managerId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.guichets,
    required this.vendeursCount,
  });

  factory Magasin.fromJson(Map<String, dynamic> json) {
    return Magasin(
      id: json['_id']?.toString() ?? '',
      businessId: BusinessId.fromJson(json['businessId'] ?? {}),
      nomMagasin: json['nom_magasin']?.toString() ?? '',
      adresse: json['adresse']?.toString() ?? '',
      telephone: json['telephone']?.toString() ?? '',
      latitude: double.tryParse(json['latitude']?.toString() ?? '0') ?? 0.0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '0') ?? 0.0,
      photoUrl: json['photoUrl']?.toString(),
      managerId: ManagerId.fromJson(json['managerId'] ?? {}),
      status: json['status'] ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      guichets: (json['guichets'] as List<dynamic>?)?.map((g) => Guichet.fromJson(g)).toList() ?? [],
      vendeursCount: json['vendeursCount'] ?? 0,
    );
  }

  String get nom => nomMagasin;
}

class BusinessId {
  final String id;
  final String nomEntreprise;
  final int budget;
  final String devise;

  BusinessId({required this.id, required this.nomEntreprise, required this.budget, required this.devise});

  factory BusinessId.fromJson(Map<String, dynamic> json) {
    return BusinessId(
      id: json['_id']?.toString() ?? '',
      nomEntreprise: json['nomEntreprise']?.toString() ?? '',
      budget: json['budget'] ?? 0,
      devise: json['devise']?.toString() ?? '',
    );
  }
}

class ManagerId {
  final String id;
  final String nom;
  final String email;
  final String prenom;

  ManagerId({required this.id, required this.nom, required this.email, required this.prenom});

  factory ManagerId.fromJson(Map<String, dynamic> json) {
    return ManagerId(
      id: json['_id']?.toString() ?? '',
      nom: json['nom']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      prenom: json['prenom']?.toString() ?? '',
    );
  }
}

class Guichet {
  final String id;
  final String nomGuichet;
  final String code;
  final int status;
  final VendeurPrincipal vendeurPrincipal;
  final int objectifJournalier;
  final int stockMax;

  Guichet({
    required this.id,
    required this.nomGuichet,
    required this.code,
    required this.status,
    required this.vendeurPrincipal,
    required this.objectifJournalier,
    required this.stockMax,
  });

  factory Guichet.fromJson(Map<String, dynamic> json) {
    return Guichet(
      id: json['_id'] ?? '',
      nomGuichet: json['nom_guichet'] ?? '',
      code: json['code'] ?? '',
      status: json['status'] ?? 0,
      vendeurPrincipal: VendeurPrincipal.fromJson(json['vendeurPrincipal'] ?? {}),
      objectifJournalier: json['objectifJournalier'] ?? 0,
      stockMax: json['stockMax'] ?? 0,
    );
  }
}

class VendeurPrincipal {
  final String id;
  final String nom;
  final String prenom;
  final String email;

  VendeurPrincipal({required this.id, required this.nom, required this.prenom, required this.email});

  factory VendeurPrincipal.fromJson(Map<String, dynamic> json) {
    return VendeurPrincipal(
      id: json['_id'] ?? '',
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      email: json['email'] ?? '',
    );
  }
}
