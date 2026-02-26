

import 'package:stockmanager/models/produit.dart';

class TicketItem {
  Article article;
  int quantite;

  TicketItem({required this.article, this.quantite = 1});

  double get total => quantite * article.prix;
}
