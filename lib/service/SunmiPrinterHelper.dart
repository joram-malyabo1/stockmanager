import 'package:sunmi_printer_plus/enums.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';

class SunmiPrinterHelper {
  static Future<void> printTicket({
    required String magasinNom,
    required List<dynamic> items,
    required double total,
  }) async {
    try {
      // 1. Liaison avec l'imprimante
      bool? isBound = await SunmiPrinter.bindingPrinter();

      if (isBound != true) {
        print("❌ Impossible de se lier à l'imprimante Sunmi");
        return;
      }

      // 2. Initialisation
      await SunmiPrinter.initPrinter();
      await SunmiPrinter.startTransactionPrint(true);

      // 3. En-tête
      await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
      // await SunmiPrinter.printText("$magasinNom\n", style: SunmiTextStyle(bold: true, fontSize: SunmiFontSize.XL));
      await SunmiPrinter.printText("REÇU DE VENTE\n");
      await SunmiPrinter.printText("--------------------------------\n");

      // 4. Liste des articles
      await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT);
      for (var item in items) {
        // Format: Désignation
        await SunmiPrinter.printText("${item.produit.designation}\n");
        // Format: Qté x Prix = Total
        await SunmiPrinter.printText("${item.quantite} x ${item.produit.prixUnitaire} = ${item.total.toStringAsFixed(0)} FG\n");
      }

      // 5. Total
      await SunmiPrinter.printText("--------------------------------\n");
      await SunmiPrinter.setAlignment(SunmiPrintAlign.RIGHT);
      // await SunmiPrinter.printText("TOTAL: ${total.toStringAsFixed(0)} FG\n", style: SunmiTextStyle(bold: true, fontSize: SunmiFontSize.LG));

      // 6. Pied de page
      await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
      await SunmiPrinter.printText("\nMerci de votre confiance !\n");
      await SunmiPrinter.printText("A bientôt\n\n");

      // 7. Sortie papier
      await SunmiPrinter.lineWrap(4); // Avancer le papier pour pouvoir déchirer
      await SunmiPrinter.exitTransactionPrint(true);

      // 8. Libérer l'imprimante
      await SunmiPrinter.unbindingPrinter();

    } catch (e) {
      print("💥 ERREUR IMPRESSION : $e");
    }
  }
}