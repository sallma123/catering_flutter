import 'package:flutter/material.dart';
import '../../models/Commande.dart';

class CommandeCard extends StatelessWidget {
  final Commande commande;
  const CommandeCard(this.commande, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          color: Colors.white, // même couleur que CommandeSwipeItem
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // infos de la commande
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      commande.typeCommande.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFFFFC107),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${commande.nomClient} | ${commande.salle} | ${commande.nombreTables} tables",
                      style: const TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
              // date
              Text(
                "${commande.date.substring(8, 10)}/${commande.date.substring(5, 7)}",
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
