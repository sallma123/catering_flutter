class ProduitCommande {
  int? id;
  String nom;
  String categorie;
  double prix;
  bool selectionne;
  int quantite;

  ProduitCommande({
    this.id,
    required this.nom,
    required this.categorie,
    required this.prix,
    this.selectionne = false,
    this.quantite = 1,
  });

  /// ✅ JSON → Objet
  factory ProduitCommande.fromJson(Map<String, dynamic> json) {
    return ProduitCommande(
      id: json['id'],
      nom: json['nom'],
      categorie: json['categorie'],
      prix: (json['prix'] as num).toDouble(),
      selectionne: json['selectionne'] ?? false,
      quantite: json['quantite'] ?? 1,
    );
  }

  /// ✅ Objet → JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'categorie': categorie,
      'prix': prix,
      'selectionne': selectionne,
      'quantite': quantite,
    };
  }

  @override
  String toString() {
    return prix > 0
        ? "$nom x$quantite - $prix DH"
        : "$nom x$quantite";
  }
}
