import 'package:flutter/material.dart';
import '../../models/Commande.dart';

class CommandeCard extends StatelessWidget {
  final Commande commande;
  const CommandeCard(this.commande, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF2C2C2C),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              commande.typeCommande.toUpperCase(),
              style: const TextStyle(
                  color: Color(0xFFFFC107), fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              "${commande.nomClient} | ${commande.salle} | ${commande.nombreTables} tables",
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              commande.date,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
