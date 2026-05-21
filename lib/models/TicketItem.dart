import 'produit_model.dart';

class TicketItem {
  final Produit produit;
  int quantite;
  String typeVente; // "partiel" (unité) ou "entier" (lot)

  TicketItem({
    required this.produit,
    this.quantite = 1,
    this.typeVente = "partiel"
  });

  // Choisit le bon prix selon le type de vente
  double get prixApplique => typeVente == "entier" ? produit.prixLot : produit.prixUnitaire;

  double get total => prixApplique * quantite;
}