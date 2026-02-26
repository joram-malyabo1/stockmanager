import 'package:flutter/material.dart';
import '../../models/TicketItem.dart';
import '../../core/delayed_animation.dart';
import 'package:sunmi_printer_plus/enums.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';
import '../interfaces/EditTicketItemPage.dart';

// Helper pour l'impression
class SunmiPrinterHelper {
  static Future<void> printTicket({
    required List<Map<String, dynamic>> articles,
    required double total, // ✅ doit être double
    required String devise,
  }) async {
    try {
      bool? connected = await SunmiPrinter.bindingPrinter();
      if (connected != true) {
        print("Erreur : imprimante non connectée !");
        return;
      }

      await SunmiPrinter.initPrinter();
      await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
      await SunmiPrinter.printText("REÇU DE VENTE\n");
      await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT);
      await SunmiPrinter.printText("----------------------------\n");

      for (var article in articles) {
        await SunmiPrinter.printText(
            "${article['nom']} x ${article['quantite']} : ${article['total']} $devise\n");
      }

      await SunmiPrinter.printText("----------------------------\n");
      await SunmiPrinter.printText("Total : $total $devise\n");
      await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
      await SunmiPrinter.printText("Merci pour votre achat !\n\n");
      await SunmiPrinter.lineWrap(3);
      await SunmiPrinter.unbindingPrinter();
    } catch (e) {
      print("Erreur impression: $e");
    }
  }
}

class TicketPage extends StatefulWidget {
  final List<TicketItem> ticketItems;

  TicketPage({required this.ticketItems});

  @override
  State<TicketPage> createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  // Regrouper les articles par devise
  Map<String, List<TicketItem>> get groupedByCurrency {
    Map<String, List<TicketItem>> grouped = {};
    for (var item in widget.ticketItems) {
      final devise = item.article.devise;
      if (!grouped.containsKey(devise)) grouped[devise] = [];
      final existIndex =
      grouped[devise]!.indexWhere((e) => e.article.id == item.article.id);
      if (existIndex >= 0) {
        grouped[devise]![existIndex].quantite += item.quantite;
      } else {
        grouped[devise]!.add(TicketItem(
          article: item.article,
          quantite: item.quantite,
        ));
      }
    }
    return grouped;
  }

  // Total par devise
  double totalByCurrency(String devise) {
    double total = 0.0;
    if (groupedByCurrency.containsKey(devise)) {
      for (var item in groupedByCurrency[devise]!) {
        total += item.total;
      }
    }
    return total;
  }

  // Fonction pour enregistrer et imprimer le ticket
  void _saveAndPrint() async {
    print("Ticket enregistré : ${widget.ticketItems.length} articles");

    final grouped = groupedByCurrency;

    for (var entry in grouped.entries) {
      String devise = entry.key;
      List<TicketItem> items = entry.value;

      List<Map<String, dynamic>> articlesPourImpression = items.map((e) {
        return { 
          'nom': e.article.nom,
          'quantite': e.quantite,
          'total': e.total,
        };
      }).toList();

      double total = totalByCurrency(devise);

      await SunmiPrinterHelper.printTicket(
        articles: articlesPourImpression,
        total: total,
        devise: devise,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Ticket enregistré et imprimé !")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final grouped = groupedByCurrency;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: DelayedAnimation(
          delay: 0,
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon:
                          Icon(Icons.arrow_back, color: Colors.green, size: 28),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          "Ticket",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(width: 50),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),

      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 70),
            child: ListView(
              children: grouped.entries.map((entry) {
                final devise = entry.key;
                final items = entry.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DelayedAnimation(
                      delay: 100,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          "Articles en $devise",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Divider(thickness: 1),
                    ...items.asMap().entries.map((mapEntry) {
                      final item = mapEntry.value;
                      final index = mapEntry.key;
                      return DelayedAnimation(
                        delay: 200 + index * 100,
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditItemPage(item: item),
                                  ),
                                );

                                if (result != null) {
                                  setState(() {
                                    if (result["remove"] == true) {
                                      widget.ticketItems.removeWhere(
                                              (t) => t.article.id == item.article.id);
                                    } else if (result["quantity"] != null) {
                                      item.quantite = result["quantity"];
                                    }
                                  });
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 6),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("${item.article.nom} x ${item.quantite}"),
                                    Text("${item.total} $devise"),
                                  ],
                                ),
                              ),
                            ),
                            if (index != items.length - 1)
                              Divider(
                                  thickness: 1,
                                  color: Colors.grey.shade300,
                                  indent: 16,
                                  endIndent: 16),
                          ],
                        ),
                      );
                    }).toList(),
                    DelayedAnimation(
                      delay: 400,
                      child: Column(
                        children: [
                          Divider(thickness: 2),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Total $devise",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Text(
                                  "${totalByCurrency(devise)} $devise",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: 60,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveAndPrint,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade300,
                ),
                child: Text(
                  "ENREGISTRER",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
