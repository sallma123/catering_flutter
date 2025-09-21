import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/CatalogueProvider.dart';
import '../../models/CategorieProduit.dart';
import '../../models/ProduitDefini.dart';

class CatalogueScreen extends StatefulWidget {
  const CatalogueScreen({super.key});

  @override
  State<CatalogueScreen> createState() => _CatalogueScreenState();
}

class _CatalogueScreenState extends State<CatalogueScreen> {
  String selectedTypeCommande = ""; // vide par défaut
  final TextEditingController nomCategorieCtrl = TextEditingController();
  final TextEditingController ordreCategorieCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final catalogue = context.watch<CatalogueProvider>();

    // Afficher les erreurs du provider comme SnackBar (une seule fois)
    if (catalogue.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (catalogue.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(catalogue.error!)),
          );
          catalogue.clearError();
        }
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Catalogue"),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Dropdown type commande (utilise labels depuis le provider)
            DropdownButtonFormField<String>(
              value: selectedTypeCommande.isNotEmpty ? selectedTypeCommande : null,
              decoration: const InputDecoration(
                labelText: "Type de commande",
                border: OutlineInputBorder(),
              ),
              items: catalogue.typesCommandeLabels
                  .map((label) => DropdownMenuItem(
                value: label,
                child: Text(label),
              ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedTypeCommande = value);
                  // fetch avec la valeur (provider convertira en enum si besoin)
                  catalogue.fetchCatalogue(value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Nom catégorie (Outlined)
            TextField(
              controller: nomCategorieCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Nom de la catégorie",
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),

            // Ordre catégorie
            TextField(
              controller: ordreCategorieCtrl,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Ordre",
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),

            // Bouton ajouter catégorie
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
                onPressed: () async {
                  if (nomCategorieCtrl.text.isEmpty || selectedTypeCommande.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Remplissez le nom et le type")));
                    return;
                  }
                  final ordre = int.tryParse(ordreCategorieCtrl.text) ?? ((catalogue.categories.isNotEmpty) ? catalogue.categories.map((c) => c.ordreAffichage).reduce((a, b) => a > b ? a : b) + 1 : 1);

                  final success = await catalogue.ajouterCategorie(selectedTypeCommande, nomCategorieCtrl.text, ordre);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Catégorie ajoutée")));
                    nomCategorieCtrl.clear();
                    ordreCategorieCtrl.clear();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erreur lors de l'ajout")));
                  }
                },
                child: const Text("Ajouter catégorie"),
              ),
            ),

            const SizedBox(height: 16),

            // Liste des catégories (cards blanches, texte noir comme en Compose)
            Expanded(
              child: ListView.builder(
                itemCount: catalogue.categories.length,
                itemBuilder: (context, idx) {
                  final cat = catalogue.categories[idx];
                  // Trie local des produits par ordre
                  final produitsTries = List<ProduitDefini>.from(cat.produits)..sort((a, b) => a.ordreAffichage.compareTo(b.ordreAffichage));

                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          // Header catégorie : ordre - nom + actions
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _showModifierCategorieDialog(cat),
                                  child: Text(
                                    "${cat.ordreAffichage} - ${cat.nom}",
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () => _showCopierCategorieDialog(cat),
                                    icon: const Icon(Icons.copy),
                                    color: Colors.black,
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      if (cat.id != null) {
                                        await catalogue.supprimerCategorie(cat.id!);
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Catégorie supprimée")));
                                      }
                                    },
                                    icon: const Icon(Icons.delete),
                                    color: Colors.red,
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          // Produits
                          Column(
                            children: produitsTries.map((p) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => _showModifierProduitDialog(p),
                                        child: Text("${p.ordreAffichage}\u00A0-\u00A0${p.nom}", style: const TextStyle(color: Colors.black)),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        if (p.id != null) {
                                          await catalogue.supprimerProduit(p.id!); // <-- **ICI**: on passe UNIQUEMENT l'id du produit
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Produit supprimé")));
                                        }
                                      },
                                      icon: const Icon(Icons.delete),
                                      color: Colors.red,
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 6),

                          // Bouton ajouter produit
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
                              onPressed: () => _showAjouterProduitDialog(cat),
                              child: const Text("Ajouter produit"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // Copier tout le catalogue
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFC107), foregroundColor: Colors.black),
                onPressed: () => _showCopierToutDialog(),
                child: const Text("Copier toutes les catégories"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----- DIALOGS -----

  void _showAjouterProduitDialog(CategorieProduit cat) {
    final nomCtrl = TextEditingController();
    final ordreCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Ajouter produit"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nomCtrl, decoration: const InputDecoration(labelText: "Nom")),
              const SizedBox(height: 8),
              TextField(controller: ordreCtrl, decoration: const InputDecoration(labelText: "Ordre"), keyboardType: TextInputType.number),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annuler")),
            ElevatedButton(
              onPressed: () async {
                final ordreParsed = int.tryParse(ordreCtrl.text);
                // appel avec arguments nommés (conforme à la signature du provider)
                await context.read<CatalogueProvider>().ajouterProduit(
                  cat.id!,
                  nom: nomCtrl.text.isEmpty ? "Nouveau produit" : nomCtrl.text,
                  ordre: (ordreParsed != null && ordreParsed > 0) ? ordreParsed : null,
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Produit ajouté")));
              },
              child: const Text("Ajouter"),
            ),
          ],
        );
      },
    );
  }

  void _showModifierProduitDialog(ProduitDefini produit) {
    final nomCtrl = TextEditingController(text: produit.nom);
    final ordreCtrl = TextEditingController(text: produit.ordreAffichage.toString());

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Modifier produit"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nomCtrl, decoration: const InputDecoration(labelText: "Nom")),
              const SizedBox(height: 8),
              TextField(controller: ordreCtrl, decoration: const InputDecoration(labelText: "Ordre"), keyboardType: TextInputType.number),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annuler")),
            ElevatedButton(
              onPressed: () async {
                final newOrder = int.tryParse(ordreCtrl.text) ?? produit.ordreAffichage;
                // Construit un nouvel objet ProduitDefini (provider attend un ProduitDefini)
                final updated = produit.copyWith(
                  nom: nomCtrl.text,
                  ordreAffichage: newOrder,
                );
                await context.read<CatalogueProvider>().modifierProduit(updated);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Produit modifié")));
              },
              child: const Text("Valider"),
            ),
          ],
        );
      },
    );
  }

  void _showModifierCategorieDialog(CategorieProduit cat) {
    final nomCtrl = TextEditingController(text: cat.nom);
    final ordreCtrl = TextEditingController(text: cat.ordreAffichage.toString());

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Modifier catégorie"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nomCtrl, decoration: const InputDecoration(labelText: "Nom")),
              const SizedBox(height: 8),
              TextField(controller: ordreCtrl, decoration: const InputDecoration(labelText: "Ordre"), keyboardType: TextInputType.number),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annuler")),
            ElevatedButton(
              onPressed: () async {
                final newOrder = int.tryParse(ordreCtrl.text) ?? cat.ordreAffichage;
                final updated = cat.copyWith(nom: nomCtrl.text, ordreAffichage: newOrder);
                await context.read<CatalogueProvider>().modifierCategorie(updated);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Catégorie modifiée")));
              },
              child: const Text("Valider"),
            ),
          ],
        );
      },
    );
  }

  void _showCopierCategorieDialog(CategorieProduit categorie) {
    String? cibleType;
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx2, setStateSB) {
          final labels = context.read<CatalogueProvider>().typesCommandeLabels;
          return AlertDialog(
            title: const Text("Copier catégorie"),
            content: DropdownButtonFormField<String>(
              value: cibleType,
              decoration: const InputDecoration(labelText: "Type cible"),
              items: labels.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
              onChanged: (v) => setStateSB(() => cibleType = v),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annuler")),
              ElevatedButton(
                onPressed: () async {
                  if (cibleType == null || cibleType!.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Choisissez un type cible")));
                    return;
                  }
                  final success = await context.read<CatalogueProvider>().copierCategorie(categorie, cibleType!);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? "Catégorie copiée" : "Erreur lors de la copie")));
                },
                child: const Text("Copier"),
              ),
            ],
          );
        });
      },
    );
  }

  void _showCopierToutDialog() {
    String? cibleType;
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx2, setStateSB) {
          final labels = context.read<CatalogueProvider>().typesCommandeLabels;
          return AlertDialog(
            title: const Text("Copier tout le catalogue"),
            content: DropdownButtonFormField<String>(
              value: cibleType,
              decoration: const InputDecoration(labelText: "Type cible"),
              items: labels.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
              onChanged: (v) => setStateSB(() => cibleType = v),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annuler")),
              ElevatedButton(
                onPressed: () async {
                  if (selectedTypeCommande.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Choisissez un type source dans le menu déroulant")));
                    return;
                  }
                  if (cibleType == null || cibleType!.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Choisissez un type cible")));
                    return;
                  }
                  final success = await context.read<CatalogueProvider>().copierCatalogue(selectedTypeCommande, cibleType!);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? "Catalogue copié" : "Erreur lors de la copie")));
                },
                child: const Text("Copier tout"),
              ),
            ],
          );
        });
      },
    );
  }
}
