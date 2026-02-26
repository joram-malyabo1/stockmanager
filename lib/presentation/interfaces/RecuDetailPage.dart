import 'package:flutter/material.dart';
import '../../core/delayed_animation.dart';
import '../../models/RecuModel.dart';

class RecuDetailPage extends StatelessWidget {
  final Recu recu;

  RecuDetailPage({required this.recu});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text("#${recu.id}"),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: "print",
                child: Row(
                  children: [
                    Icon(Icons.print),
                    SizedBox(width: 10),
                    Text("Imprimer le reçu"),
                  ],
                ),
              ),
              PopupMenuItem(
                value: "email",
                child: Row(
                  children: [
                    Icon(Icons.email),
                    SizedBox(width: 10),
                    Text("Reçu de l’e-mail"),
                  ],
                ),
              ),
            ],
          )
        ],
      ),

      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          DelayedAnimation(
            delay: 300,
            child: Text(
              "FC${recu.total.toStringAsFixed(0)}",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 5),

          Center(child: Text("Total", style: TextStyle(color: Colors.grey))),

          SizedBox(height: 20),

          Text("Employé(e): ${recu.employe}"),
          Text("PDV: ${recu.pdv}"),

          Divider(height: 30),

          Text("Sur Place", style: TextStyle(fontSize: 20)),

          SizedBox(height: 10),

          ...recu.items.map((e) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${e.produit}\n${e.qty} x FC${e.prix}"),
                Text("FC${(e.qty * e.prix).toStringAsFixed(0)}"),
              ],
            );
          }).toList(),

          Divider(height: 30),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total", style: TextStyle(fontSize: 22)),
              Text(
                "FC${recu.total.toStringAsFixed(0)}",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          SizedBox(height: 20),

          Text("Espèces  FC${recu.total.toStringAsFixed(0)}"),

          SizedBox(height: 20),

          Text(recu.date.toString(), style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
