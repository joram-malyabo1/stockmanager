import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Pour limiter la saisie aux nombres
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
  late TextEditingController _qtyController;

  final Color orangeMax = const Color(0xFFFF7900);
  final Color bleuNuit = const Color(0xFF0D084B);

  @override
  void initState() {
    super.initState();
    quantity = widget.item.quantite;
    _qtyController = TextEditingController(text: quantity.toString());
  }

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  double get currentTotal => widget.item.prixApplique * quantity;

  // Mise à jour synchrone du texte et de la variable
  void _updateQty(int newQty) {
    if (newQty < 1) return;
    setState(() {
      quantity = newQty;
      _qtyController.text = newQty.toString();
    });
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(90),
      child: Container(
        decoration: BoxDecoration(
          color: bleuNuit,
          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(35), bottomRight: Radius.circular(35)),
        ),
        child: SafeArea(
          child: Center(
            child: Text(
              "MODIFIER LA QUANTITÉ",
              style: TextStyle(color: orangeMax, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.2),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLot = widget.item.typeVente == "entier";

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: _buildAppBar(),
      body: SingleChildScrollView( // Ajout du scroll pour éviter les erreurs quand le clavier sort
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
        child: Column(
          children: [
            Text(
              widget.item.produit.designation,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: bleuNuit),
            ),
            const SizedBox(height: 10),
            _buildBadge(isLot),
            const SizedBox(height: 30),

            // CARTE DU TOTAL
            _buildTotalCard(),

            const SizedBox(height: 50),

            const Text("SAISISSEZ OU AJUSTEZ LA QUANTITÉ",
                style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),

            const SizedBox(height: 30),

            // ZONE DE SAISIE AVEC + ET -
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _qtyActionBtn(Icons.remove, Colors.red, () => _updateQty(quantity - 1)),

                // ✅ CHAMP DE SAISIE DIRECTE
                Container(
                  width: 150,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: _qtyController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 45, fontWeight: FontWeight.w900, color: bleuNuit),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Uniquement des chiffres
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "0",
                    ),
                    onChanged: (val) {
                      if (val.isNotEmpty) {
                        setState(() {
                          quantity = int.parse(val);
                        });
                      }
                    },
                  ),
                ),

                _qtyActionBtn(Icons.add, Colors.green, () => _updateQty(quantity + 1)),
              ],
            ),

            const SizedBox(height: 60),

            // BOUTON VALIDER
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: orangeMax,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 3,
                ),
                onPressed: () => Navigator.pop(context, {"remove": false, "quantity": quantity}),
                child: const Text("ENREGISTRER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),

            TextButton.icon(
              onPressed: () => Navigator.pop(context, {"remove": true}),
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              label: const Text("SUPPRIMER DE LA LISTE", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(bool isLot) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isLot ? Colors.purple.withOpacity(0.1) : bleuNuit.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isLot ? Colors.purple : bleuNuit),
      ),
      child: Text(
        isLot ? "VENTE EN GROS" : "VENTE AU DÉTAIL",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: isLot ? Colors.purple : bleuNuit),
      ),
    );
  }

  Widget _buildTotalCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          const Text("PRIX TOTAL CALCULÉ", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text("${currentTotal.toStringAsFixed(0)} FG",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: orangeMax)),
        ],
      ),
    );
  }

  Widget _qtyActionBtn(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.1),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(icon, size: 30, color: color),
      ),
    );
  }
}