class Recu {
  final String id;
  final String employe;
  final String pdv;
  final DateTime date;
  final double total;
  final List<RecuItem> items;

  Recu({
    required this.id,
    required this.employe,
    required this.pdv,
    required this.date,
    required this.total,
    required this.items,
  });
}

class RecuItem {
  final String produit;
  final int qty;
  final double prix;

  RecuItem({
    required this.produit,
    required this.qty,
    required this.prix,
  });
}

class RecuModel {
  static List<Recu> recuList = [
    Recu(
      id: 'R001',
      employe: 'Joram Malyabo',
      pdv: 'POS 03',
      date: DateTime.now(),
      total: 5000,
      items: [
        RecuItem(produit: 'Café', qty: 2, prix: 2000),
        RecuItem(produit: 'Croissant', qty: 1, prix: 1000),
      ],
    ),

    Recu(
      id: 'R005',
      employe: 'Akim Hank',
      pdv: 'POS 03',
      date: DateTime.now(),
      total: 5000,
      items: [
        RecuItem(produit: 'Café', qty: 2, prix: 2000),
        RecuItem(produit: 'Croissant', qty: 1, prix: 3000),
      ],
    ),

    Recu(
      id: 'R002',
      employe: 'Marie',
      pdv: 'POS 01',
      date: DateTime.now(),
      total: 3000,
      items: [
        RecuItem(produit: 'Thé', qty: 1, prix: 1000),
        RecuItem(produit: 'Pain au chocolat', qty: 2, prix: 1000),
      ],
    ),
  ];



  // Total du jour
  static double totalParJour() {
    final today = DateTime.now();
    return recuList
        .where((r) =>
    r.date.year == today.year &&
        r.date.month == today.month &&
        r.date.day == today.day)
        .fold(0.0, (sum, r) => sum + r.total);
  }

  // Total de la semaine
  static double totalParSemaine() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    return recuList
        .where((r) => r.date.isAfter(weekAgo) && r.date.isBefore(now))
        .fold(0.0, (sum, r) => sum + r.total);
  }

  // Total du mois
  static double totalParMois() {
    final now = DateTime.now();
    final monthAgo = now.subtract(const Duration(days: 30));

    return recuList
        .where((r) => r.date.isAfter(monthAgo) && r.date.isBefore(now))
        .fold(0.0, (sum, r) => sum + r.total);
  }

}
