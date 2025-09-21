class ProduitDefini {
  final int? id;
  final String nom;
  final int ordreAffichage;
  final int categorieId;

  ProduitDefini({
    this.id,
    required this.nom,
    required this.ordreAffichage,
    required this.categorieId,
  });

  factory ProduitDefini.fromJson(Map<String, dynamic> json) {
    return ProduitDefini(
      id: json['id'],
      nom: json['nom'],
      ordreAffichage: json['ordreAffichage'],
      categorieId: json['categorieId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'ordreAffichage': ordreAffichage,
      'categorieId': categorieId,
    };
  }

  // 🔹 Ajout du copyWith
  ProduitDefini copyWith({
    int? id,
    String? nom,
    int? ordreAffichage,
    int? categorieId,
  }) {
    return ProduitDefini(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      ordreAffichage: ordreAffichage ?? this.ordreAffichage,
      categorieId: categorieId ?? this.categorieId,
    );
  }
}
