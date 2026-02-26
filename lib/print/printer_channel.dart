import 'package:flutter/services.dart';

class PrinterChannel {
  static const platform = MethodChannel('sunmi_printer');

  static Future<void> printText(String text) async {
    try {
      await platform.invokeMethod('printText', {"text": text});
    } catch (e) {
      print("Erreur lors de l'impression : $e");
    }
  }
}
