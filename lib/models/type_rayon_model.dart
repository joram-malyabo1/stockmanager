// models/type_rayon_model.dart
class TypeProduitSimple {
  final String id;
  final String nomType;  // ✅ UNIQUEMENT ça pour dropdown

  TypeProduitSimple({
    required this.id,
    required this.nomType,
  });

  factory TypeProduitSimple.fromJson(Map<String, dynamic> json) {
    return TypeProduitSimple(
      id: json['_id']?.toString() ?? '',
      nomType: json['nomType']?.toString() ?? 'Inconnu',
    );
  }
}


class RayonSimple {
  final String id;
  final String nomRayon;
  final String iconeRayon;
  final List<TypeProduitSimple> typesAutorises;  // Types acceptés

  RayonSimple({
    required this.id,
    required this.nomRayon,
    required this.iconeRayon,
    this.typesAutorises = const [],
  });

  factory RayonSimple.fromJson(Map<String, dynamic> json) {
    return RayonSimple(
      id: json['_id'],
      nomRayon: json['nomRayon'] ?? 'Inconnu',
      iconeRayon: json['iconeRayon'] ?? '🏪',
      typesAutorises: [],  // Mapper depuis typesProduitsAutorises
    );
  }
}






// class TypeProduitSimple {
//   final String id;
//   final String nomType;
//   final String icone;
//   final List<ChampExtra> champsExtra;
//
//   TypeProduitSimple({
//     required this.id,
//     required this.nomType,
//     required this.icone,
//     this.champsExtra = const [],
//   });
//
//   factory TypeProduitSimple.fromJson(Map<String, dynamic> json) {
//     return TypeProduitSimple(
//       id: json['_id'] ?? '',
//       nomType: json['nomType'] ?? '',
//       icone: json['icone'] ?? '',
//       champsExtra: (json['champsSupplementaires'] as List<dynamic>?)
//           ?.map((e) => ChampExtra.fromJson(e))
//           .toList() ?? [],
//     );
//   }
// }
//
// class ChampExtra {
//   final String nomChamp;
//   final List<String> options;
//
//   ChampExtra({
//     required this.nomChamp,
//     this.options = const [],
//   });
//
//   factory ChampExtra.fromJson(Map<String, dynamic> json) {
//     return ChampExtra(
//       nomChamp: json['nomChamp'] ?? '',
//       options: List<String>.from(json['optionsChamp'] ?? []),
//     );
//   }
// }
//
// class RayonSimple {
//   final String id;
//   final String nomRayon;
//   final List<TypeProduitMini> typesAutorises;
//
//   RayonSimple({
//     required this.id,
//     required this.nomRayon,
//     this.typesAutorises = const [],
//   });
//
//   factory RayonSimple.fromJson(Map<String, dynamic> json) {
//     return RayonSimple(
//       id: json['_id'] ?? '',
//       nomRayon: json['nomRayon'] ?? '',
//       typesAutorises: (json['typesProduitsAutorises'] as List<dynamic>?)
//           ?.map((t) => TypeProduitMini.fromJson(t))
//           .toList() ?? [],
//     );
//   }
// }
//
// class TypeProduitMini {
//   final String id;
//   final String nomType;
//
//   TypeProduitMini({required this.id, required this.nomType});
//
//   factory TypeProduitMini.fromJson(Map<String, dynamic> json) {
//     return TypeProduitMini(
//       id: json['_id'] ?? '',
//       nomType: json['nomType'] ?? '',
//     );
//   }
// }




