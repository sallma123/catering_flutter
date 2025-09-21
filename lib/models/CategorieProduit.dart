import 'ProduitDefini.dart';

class CategorieProduit {
  final int? id;
  final String nom;
  final int ordreAffichage;
  final String typeCommande;
  final List<ProduitDefini> produits;

  CategorieProduit({
    this.id,
    required this.nom,
    required this.ordreAffichage,
    required this.typeCommande,
    this.produits = const [],
  });

  factory CategorieProduit.fromJson(Map<String, dynamic> json) {
    return CategorieProduit(
      id: json['id'],
      nom: json['nom'],
      ordreAffichage: json['ordreAffichage'],
      typeCommande: json['typeCommande'],
      produits: (json['produits'] as List<dynamic>?)
          ?.map((e) => ProduitDefini.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'ordreAffichage': ordreAffichage,
      'typeCommande': typeCommande,
      'produits': produits.map((e) => e.toJson()).toList(),
    };
  }

  // 🔹 Ajout du copyWith
  CategorieProduit copyWith({
    int? id,
    String? nom,
    int? ordreAffichage,
    String? typeCommande,
    List<ProduitDefini>? produits,
  }) {
    return CategorieProduit(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      ordreAffichage: ordreAffichage ?? this.ordreAffichage,
      typeCommande: typeCommande ?? this.typeCommande,
      produits: produits ?? this.produits,
    );
  }
}
