import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sunmi_printer_plus/enums.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';
import '../../models/TicketItem.dart';
import '../../service/vente_service.dart';

class TicketPage extends StatefulWidget {
  final List<TicketItem> ticketItems;
  final String magasinId;
  final String token;
  final String guichetId;
  final String utilisateurId;

  const TicketPage({
    Key? key,
    required this.ticketItems,
    required this.magasinId,
    required this.token,
    required this.guichetId,
    required this.utilisateurId
  }) : super(key: key);

  @override
  State<TicketPage> createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  final TextEditingController _clientController = TextEditingController();
  final TextEditingController _obsController = TextEditingController();
  final TextEditingController _prixVenteController = TextEditingController();

  bool _estConfirme = false;
  bool _isProcessing = false;
  String _deviseSelectionnee = "FG"; // "FG" ou "USD"

  final Color orangeMax = const Color(0xFFFF7900);
  final Color bleuNuit = const Color(0xFF0D084B);

  @override
  void initState() {
    super.initState();
    _recalculerPrix();
  }

  @override
  void dispose() {
    _clientController.dispose();
    _obsController.dispose();
    _prixVenteController.dispose();
    super.dispose();
  }

  bool _isLotAction(TicketItem item) => item.typeVente.toLowerCase().contains("lot");

  double get totalTicket => widget.ticketItems.fold(0, (sum, item) => sum + item.total);

  double get totalLots => widget.ticketItems.where((i) => _isLotAction(i)).fold(0, (sum, item) => sum + item.total);

  double get totalUnits => widget.ticketItems.where((i) => !_isLotAction(i)).fold(0, (sum, item) => sum + item.total);

  bool get _formulaireValide =>
      _clientController.text.trim().isNotEmpty &&
          _obsController.text.trim().isNotEmpty &&
          _prixVenteController.text.trim().isNotEmpty &&
          _estConfirme &&
          widget.ticketItems.isNotEmpty;

  // Initialise ou réinitialise le prix de vente saisi avec la valeur par défaut du panier
  void _recalculerPrix() {
    _prixVenteController.text = totalTicket.toStringAsFixed(0);
  }

  // Change uniquement l'étiquette de la devise sans appliquer de conversion
  void _changerDevise(String nouvelleDevise) {
    if (_deviseSelectionnee == nouvelleDevise) return;
    setState(() {
      _deviseSelectionnee = nouvelleDevise;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: widget.ticketItems.isEmpty
                ? _buildEmptyState()
                : ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                _buildFormulaireSection(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: Text("ARTICLES À VALIDER",
                      style: TextStyle(color: bleuNuit, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                ...widget.ticketItems.asMap().entries.map((entry) => _itemCard(entry.value, entry.key)),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: _buildFooterActions(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(130),
      child: Container(
        padding: const EdgeInsets.only(top: 40),
        decoration: BoxDecoration(
          color: bleuNuit,
          borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30)
          ),
        ),
        child: Column(
          children: [
            Text("${widget.ticketItems.length} ARTICLE(S) AU PANIER",
                style: const TextStyle(color: Colors.white54, fontSize: 10)),
            const SizedBox(height: 4),
            Text("${totalTicket.toStringAsFixed(0)} FG",
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _subBadge("GROS", totalLots, Colors.purple),
                const SizedBox(width: 10),
                _subBadge("DÉTAIL", totalUnits, Colors.lightBlueAccent),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _subBadge(String title, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
      child: Text("$title: ${amount.toStringAsFixed(0)} FG",
          style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildEmptyState() {
    return Center(child: Text("Panier vide", style: TextStyle(color: Colors.grey[400])));
  }

  Widget _buildFormulaireSection() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          _customField(_clientController, "Nom du Client *", Icons.person),
          const SizedBox(height: 8),
          _customField(_obsController, "Observation / Note *", Icons.edit_note),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 45,
                  child: TextField(
                    controller: _prixVenteController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: "Prix de Vente Saisi *",
                      prefixIcon: Icon(Icons.payments, color: orangeMax, size: 18),
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      _deviseButton("FG"),
                      _deviseButton("USD"),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _deviseButton(String label) {
    bool isSelected = (_deviseSelectionnee == "FG" && label == "FG") ||
        (_deviseSelectionnee == "USD" && label == "USD");
    return Expanded(
      child: InkWell(
        onTap: () => _changerDevise(label == "FG" ? "FG" : "USD"),
        child: Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: isSelected ? orangeMax : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : bleuNuit,
            ),
          ),
        ),
      ),
    );
  }

  Widget _customField(TextEditingController ctrl, String label, IconData icon) {
    return SizedBox(
      height: 45,
      child: TextField(
        controller: ctrl,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: orangeMax, size: 18),
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _itemCard(TicketItem item, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[100], borderRadius: BorderRadius.circular(8),
                image: item.produit.photoUrl != null
                    ? DecorationImage(image: NetworkImage(item.produit.photoUrl!), fit: BoxFit.cover)
                    : null,
              ),
              child: item.produit.photoUrl == null ? const Icon(Icons.image, color: Colors.grey) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.produit.designation, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, overflow: TextOverflow.ellipsis)),
                  Text(item.typeVente, style: TextStyle(color: orangeMax, fontSize: 10, fontWeight: FontWeight.bold)),
                  Text("${item.total.toStringAsFixed(0)} FG", style: TextStyle(fontWeight: FontWeight.w900, color: bleuNuit, fontSize: 12)),
                ],
              ),
            ),
            Row(
              children: [
                _qtyBtn(Icons.remove, () {
                  setState(() {
                    if (item.quantite > 1) {
                      item.quantite--;
                      _recalculerPrix();
                    }
                  });
                }),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text("${item.quantite.toInt()}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
                _qtyBtn(Icons.add, () {
                  setState(() {
                    item.quantite++;
                    _recalculerPrix();
                  });
                }),
              ],
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
              onPressed: () => setState(() {
                widget.ticketItems.removeAt(index);
                _recalculerPrix();
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: bleuNuit.withOpacity(0.05), borderRadius: BorderRadius.circular(6)),
        child: Icon(icon, size: 18, color: bleuNuit),
      ),
    );
  }

  Widget _buildFooterActions() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Checkbox(
                  value: _estConfirme,
                  activeColor: orangeMax,
                  onChanged: (v) => setState(() => _estConfirme = v!)
              ),
              const Text("Je confirme les informations ci-dessus", style: TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 5),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _formulaireValide ? orangeMax : Colors.grey[300],
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: (_formulaireValide && !_isProcessing) ? _processVente : null,
            child: _isProcessing
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text("VALIDER LA VENTE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- LOGIQUE DE VALIDATION ET RETOUR (MISE À JOUR) ---
  Future<void> _processVente() async {
    setState(() => _isProcessing = true);

    double prixSaisi = double.tryParse(_prixVenteController.text) ?? totalTicket;

    // On ajoute la mention de la devise choisie dans l'observation pour l'enregistrement en BDD
    String observationFinale = "${_obsController.text.trim()} (Payé en $_deviseSelectionnee)";

    try {
      // 1. Appel API pour enregistrer la vente avec le prix final saisi par l'utilisateur
      await VenteService.creerVente(
        token: widget.token,
        magasinId: widget.magasinId,
        guichetId: widget.guichetId,
        utilisateurId: widget.utilisateurId,
        client: _clientController.text.trim(),
        items: widget.ticketItems,
        montantTotal: prixSaisi, // Envoi du montant saisi (qu'il soit en FG ou en USD)
      );

      // 2. Impression du ticket Sunmi
      await _printSunmi();

      // 3. Message de succès
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Vente réussie ! Stock mis à jour."),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      // 🚀 4. RETOUR À LA PAGE PRÉCÉDENTE AVEC 'TRUE'
      Navigator.pop(context, true);

    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Erreur lors de la vente : $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _printSunmi() async {
    try {
      bool? isBound = await SunmiPrinter.bindingPrinter();
      if (isBound != true) return;
      await SunmiPrinter.initPrinter();

      await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
      await SunmiPrinter.printText("RECU DE VENTE\n", );
      await SunmiPrinter.printText("--------------------------------\n");

      await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT);
      await SunmiPrinter.printText("Client : ${_clientController.text}\n");
      await SunmiPrinter.printText("Date   : ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}\n");
      await SunmiPrinter.printText("--------------------------------\n");

      for (var item in widget.ticketItems) {
        double unitPrice = item.total / item.quantite;

        await SunmiPrinter.printText("${item.produit.designation.toUpperCase()}\n");
        await SunmiPrinter.printText("${item.quantite.toInt()} x ${item.typeVente} @ ${unitPrice.toStringAsFixed(0)} FG\n");
        await SunmiPrinter.setAlignment(SunmiPrintAlign.RIGHT);
        await SunmiPrinter.printText("S.Total: ${item.total.toStringAsFixed(0)} FG\n");
        await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT);
      }

      await SunmiPrinter.printText("--------------------------------\n");
      await SunmiPrinter.setAlignment(SunmiPrintAlign.RIGHT);

      double prixSaisi = double.tryParse(_prixVenteController.text) ?? totalTicket;
      String formatPrix = _deviseSelectionnee == "USD" ? prixSaisi.toStringAsFixed(2) : prixSaisi.toStringAsFixed(0);

      await SunmiPrinter.printText("TOTAL PAYE: $formatPrix $_deviseSelectionnee\n");

      await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
      await SunmiPrinter.printText("\nMerci de votre confiance !\n");
      await SunmiPrinter.lineWrap(3);
    } catch (e) {
      debugPrint("Erreur impression: $e");
    }
  }
}