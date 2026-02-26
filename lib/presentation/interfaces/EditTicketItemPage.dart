import 'package:flutter/material.dart';
import '../../models/TicketItem.dart';
import '../../core/delayed_animation.dart';

class EditItemPage extends StatefulWidget {
  final TicketItem item;

  const EditItemPage({Key? key, required this.item}) : super(key: key);

  @override
  _EditItemPageState createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  late int quantity;
  late double unitPrice; // ✅ double (prix)
  late String devise;

  @override
  void initState() {
    super.initState();
    quantity = widget.item.quantite;
    unitPrice = widget.item.article.prix; // ✅ plus de cast
    devise = widget.item.article.devise;
  }

  String formatPrice(double value) {
    return "${value.toStringAsFixed(2)} $devise";
  }

  @override
  Widget build(BuildContext context) {
    final double total = quantity * unitPrice;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "${widget.item.article.nom} — ${formatPrice(unitPrice)}",
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, {
                "quantity": quantity,
                "remove": false,
              });
            },
            child: const Text(
              "ENREGISTRER",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 8),

            // ---- TITRE QUANTITÉ ----
            DelayedAnimation(
              delay: 100,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Quantité",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ---- CONTROLE QUANTITÉ ----
            DelayedAnimation(
              delay: 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 40,
                    onPressed: quantity > 1
                        ? () {
                      setState(() {
                        quantity--;
                      });
                    }
                        : null,
                    icon: const Icon(Icons.remove),
                  ),
                  const SizedBox(width: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      quantity.toString(),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  IconButton(
                    iconSize: 40,
                    onPressed: () {
                      setState(() {
                        quantity++;
                      });
                    },
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ---- PRIX UNITAIRE ----
            DelayedAnimation(
              delay: 300,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Prix unitaire",
                      style: TextStyle(fontSize: 16)),
                  Text(
                    formatPrice(unitPrice),
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ---- TOTAL ----
            DelayedAnimation(
              delay: 400,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total",
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    formatPrice(total),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // ---- BOUTON RETIRER ----
            DelayedAnimation(
              delay: 500,
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.pop(context, {"remove": true});
                  },
                  child: const Text(
                    "RETIRER DU TICKET",
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
