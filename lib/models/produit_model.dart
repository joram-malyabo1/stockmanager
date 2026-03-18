// models/produit_model.dart - VERSION CORRIGÉE
class Produit {
  final String id;
  final String magasinId;
  final String reference;
  final String designation;
  final TypeProduitId typeProduitId;
  final RayonId rayonId;
  final int quantiteActuelle;
  final int quantiteEntree;
  final int quantiteSortie;
  final double prixUnitaire;
  final double prixTotal;
  final String etat;
  final String? dateEntree;
  final String? dateReception;
  final String? dateFabrication;
  final String? dateExpiration;
  final String? datePeremption;
  final int seuilAlerte;
  final String? photoUrl;
  final String notes;
  final String statut;
  final String priorite;
  final int status;
  final bool estSupprime;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<dynamic> alertes;

  Produit({
    required this.id, required this.magasinId, required this.reference,
    required this.designation, required this.typeProduitId, required this.rayonId,
    required this.quantiteActuelle, required this.quantiteEntree, required this.quantiteSortie,
    required this.prixUnitaire, required this.prixTotal, required this.etat,
    this.dateEntree, this.dateReception, this.dateFabrication,
    this.dateExpiration, this.datePeremption, required this.seuilAlerte,
    this.photoUrl, required this.notes, required this.statut,
    required this.priorite, required this.status, required this.estSupprime,
    required this.createdAt, required this.updatedAt, required this.alertes,
  });

  // ✅ FIX COMPLET : TOUS les int/double convertis String→Number
  factory Produit.fromJson(Map<String, dynamic> json) {
    return Produit(
      id: json['_id']?.toString() ?? '',
      magasinId: json['magasinId']?.toString() ?? '',
      reference: json['reference']?.toString() ?? '',
      designation: json['designation']?.toString() ?? '',
      typeProduitId: TypeProduitId.fromJson(json['typeProduitId'] ?? {}),
      rayonId: RayonId.fromJson(json['rayonId'] ?? {}),

      // ✅ FIX INT (String → int)
      quantiteActuelle: int.tryParse(json['quantiteActuelle']?.toString() ?? '0') ?? 0,
      quantiteEntree: int.tryParse(json['quantiteEntree']?.toString() ?? '0') ?? 0,
      quantiteSortie: int.tryParse(json['quantiteSortie']?.toString() ?? '0') ?? 0,

      // ✅ DOUBLE (déjà bon)
      prixUnitaire: double.tryParse(json['prixUnitaire']?.toString() ?? '0') ?? 0.0,
      prixTotal: double.tryParse(json['prixTotal']?.toString() ?? '0') ?? 0.0,

      etat: json['etat']?.toString() ?? '',
      dateEntree: json['dateEntree']?.toString(),
      dateReception: json['dateReception']?.toString(),
      dateFabrication: json['dateFabrication']?.toString(),
      dateExpiration: json['dateExpiration']?.toString(),
      datePeremption: json['datePeremption']?.toString(),

      // ✅ FIX INT
      seuilAlerte: int.tryParse(json['seuilAlerte']?.toString() ?? '0') ?? 0,

      photoUrl: json['photoUrl']?.toString(),
      notes: json['notes']?.toString() ?? '',
      statut: json['statut']?.toString() ?? '',
      priorite: json['priorite']?.toString() ?? '',

      // ✅ FIX INT
      status: int.tryParse(json['status']?.toString() ?? '0') ?? 0,

      // ✅ FIX BOOL
      estSupprime: json['estSupprime']?.toString().toLowerCase() == 'true',

      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
      alertes: json['alertes'] ?? [],
    );
  }
}

class TypeProduitId {
  final String id;
  final String nomType;
  final String unitePrincipale;
  final String code;
  final String icone;
  final int seuilAlerte;
  final int capaciteMax;

  TypeProduitId({
    required this.id, required this.nomType, required this.unitePrincipale,
    required this.code, required this.icone, required this.seuilAlerte,
    required this.capaciteMax,
  });

  // ✅ FIX TypeProduitId
  factory TypeProduitId.fromJson(Map<String, dynamic> json) {
    return TypeProduitId(
      id: json['_id']?.toString() ?? '',
      nomType: json['nomType']?.toString() ?? '',
      unitePrincipale: json['unitePrincipale']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      icone: json['icone']?.toString() ?? '',
      // ✅ FIX INT
      seuilAlerte: int.tryParse(json['seuilAlerte']?.toString() ?? '0') ?? 0,
      capaciteMax: int.tryParse(json['capaciteMax']?.toString() ?? '0') ?? 0,
    );
  }
}

class RayonId {
  final String id;
  final String codeRayon;
  final String nomRayon;
  final String typeRayon;
  final int capaciteMax;
  final String iconeRayon;
  final int quantiteActuelle;

  RayonId({
    required this.id, required this.codeRayon, required this.nomRayon,
    required this.typeRayon, required this.capaciteMax, required this.iconeRayon,
    required this.quantiteActuelle,
  });

  // ✅ FIX RayonId
  factory RayonId.fromJson(Map<String, dynamic> json) {
    return RayonId(
      id: json['_id']?.toString() ?? '',
      codeRayon: json['codeRayon']?.toString() ?? '',
      nomRayon: json['nomRayon']?.toString() ?? '',
      typeRayon: json['typeRayon']?.toString() ?? '',
      // ✅ FIX INT
      capaciteMax: int.tryParse(json['capaciteMax']?.toString() ?? '0') ?? 0,
      iconeRayon: json['iconeRayon']?.toString() ?? '',
      quantiteActuelle: int.tryParse(json['quantiteActuelle']?.toString() ?? '0') ?? 0,
    );
  }
}
