import 'package:app_catering/screens/commandes/CommandeSwipeItem.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/Commande.dart';
import '../../providers/CommandeProvider.dart';
import 'CreerCommandeScreen.dart';

class CommandesScreen extends StatefulWidget {
  const CommandesScreen({super.key});

  @override
  State<CommandesScreen> createState() => _CommandesScreenState();
}

class _CommandesScreenState extends State<CommandesScreen> {
  String query = "";
  String filtre = "FUTURE";
  DateTime? dateDebut;
  DateTime? dateFin;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<CommandeProvider>(context, listen: false).fetchCommandes());
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CommandeProvider>(context);
    final commandes = provider.commandes;

    final today = DateTime.now();
    final sdfInput = DateFormat("yyyy-MM-dd");
    final sdfMois = DateFormat("MMMM yyyy", "fr");
    final sdfSort = DateFormat("yyyy-MM-dd");

    // 🔎 Filtrage
    final commandesFiltrees = commandes.where((c) {
      final nomMatch = query.isEmpty ||
          c.nomClient.toLowerCase().contains(query.toLowerCase()) ||
          c.salle.toLowerCase().contains(query.toLowerCase());

      DateTime? date;
      try {
        date = sdfInput.parse(c.date);
      } catch (_) {}

      bool dateOK = true;
      if (filtre == "PASSEE") {
        dateOK = date != null && date.isBefore(today);
      } else if (filtre == "FUTURE") {
        dateOK = date != null && !date.isBefore(today);
      } else if (filtre == "ENTRE DEUX DATES") {
        if (date != null && dateDebut != null && dateFin != null) {
          dateOK =
              !date.isBefore(dateDebut!) && !date.isAfter(dateFin!);
        } else {
          dateOK = false;
        }
      }

      return nomMatch && dateOK;
    }).toList()
      ..sort((a, b) {
        try {
          return sdfSort.parse(a.date).compareTo(sdfSort.parse(b.date));
        } catch (_) {
          return 0;
        }
      });

    // 📦 Groupement par mois
    final grouped = <String, List<Commande>>{};
    for (var c in commandesFiltrees) {
      try {
        final d = sdfInput.parse(c.date);
        final mois = sdfMois.format(d);
        grouped.putIfAbsent(mois, () => []).add(c);
      } catch (_) {
        grouped.putIfAbsent("Inconnue", () => []).add(c);
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Column(
        children: [
          // 🔎 Barre recherche + filtre
// 🔎 Barre recherche + filtre moderne
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                // Barre de recherche
                TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => query = val),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    hintText: "Rechercher...",
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF1E1E1E),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Ligne de filtres en chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      "TOUS",
                      "FUTURE",
                      "PASSEE",
                      "ENTRE DEUX DATES",
                    ].map((f) {
                      final isSelected = filtre == f;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(
                            f,
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: const Color(0xFFFFC107),
                          backgroundColor: const Color(0xFF1E1E1E),
                          onSelected: (_) {
                            setState(() => filtre = f);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Si filtre = ENTRE DEUX DATES → picker intégré
                if (filtre == "ENTRE DEUX DATES")
                  Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) setState(() => dateDebut = picked);
                          },
                          icon: const Icon(Icons.date_range, color: Colors.white70),
                          label: Text(
                            dateDebut != null
                                ? DateFormat("dd/MM").format(dateDebut!)
                                : "Début",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) setState(() => dateFin = picked);
                          },
                          icon: const Icon(Icons.date_range, color: Colors.white70),
                          label: Text(
                            dateFin != null
                                ? DateFormat("dd/MM").format(dateFin!)
                                : "Fin",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),


          Expanded(
            child: provider.isLoading
                ? const Center(
                child: CircularProgressIndicator(
                    color: Color(0xFFFFC107)))
                : ListView(
              padding: const EdgeInsets.all(6),
              children: grouped.entries.expand((entry) {
                final mois = entry.key;
                final items = entry.value;
                return [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      mois,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  ...items.map((commande) =>
                      CommandeSwipeItem(
                        commande: commande,
                        onDeleteClick: () {
                          // Supprimer la commande
                        },
                        onFicheClick: () {
                          // Ouvrir la fiche
                        },
                        onDuplicateClick: () {
                          // Dupliquer la commande
                        },
                        content: ListTile(
                          title: Text(
                            commande.typeCommande.toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFFFFC107),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            "${commande.nomClient} | ${commande.salle} | ${commande.nombreTables} tables",
                            style: const TextStyle(color: Colors.black),
                          ),
                          trailing: Text(
                            DateFormat("dd/MM").format(DateTime.parse(commande.date)),
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ))

                ];
              }).toList(),
            ),
          ),

          // ➕ Boutons ajout commande
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: ["Particulier", "Entreprise", "Partenaire"]
                  .map((label) => Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC107),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: () async {
                      // Navigation vers CreerCommandeScreen
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CreerCommandeScreen(
                            typeClient: label,
                          ),
                        ),
                      );

                      // 🔹 result est un CommandeDTO retourné après création
                      if (result != null) {
                        // Par exemple, on peut l'ajouter au provider
                        Provider.of<CommandeProvider>(context, listen: false).creerCommande(
                          result,
                          onSuccess: (id) {
                            // 🔹 Après création, tu peux récupérer l'id et éventuellement faire un setState ou notifier
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Commande créée"))
                            );
                          },
                          onError: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Erreur lors de la création"))
                            );
                          },
                        );

                      }
                    },
                    child: Text(
                      label.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 10.2,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ))
                  .toList(),
            )
            ,
          )
        ],
      ),
    );
  }
}
