

import '../../models/ProduitCommande.dart';

class CommandeDTO {
  final int? id;
  final String nomClient;
  final String salle;
  final int nombreTables;
  final double prixParTable;
  final String typeClient;
  final String typeCommande;
  final bool signatureCachet;
  final String statut;
  final String date;
  final List<ProduitCommande> produits;
  final String? objet;
  final String? commentaire;
  final String? telephone;
  final String? heureInvitation;

  CommandeDTO({
    this.id,
    required this.nomClient,
    required this.salle,
    required this.nombreTables,
    required this.prixParTable,
    required this.typeClient,
    required this.typeCommande,
    this.signatureCachet = false,
    required this.statut,
    required this.date,
    this.produits = const [],
    this.objet,
    this.commentaire,
    this.telephone,
    this.heureInvitation,
  });

  factory CommandeDTO.fromJson(Map<String, dynamic> json) {
    return CommandeDTO(
      id: json['id'],
      nomClient: json['nomClient'],
      salle: json['salle'],
      nombreTables: json['nombreTables'],
      prixParTable: (json['prixParTable'] as num).toDouble(),
      typeClient: json['typeClient'],
      typeCommande: json['typeCommande'],
      signatureCachet: json['signatureCachet'] ?? false,
      statut: json['statut'],
      date: json['date'],
      produits: (json['produits'] as List<dynamic>)
          .map((e) => ProduitCommande.fromJson(e))
          .toList(),
      objet: json['objet'],
      commentaire: json['commentaire'],
      telephone: json['telephone'],
      heureInvitation: json['heureInvitation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nomClient': nomClient,
      'salle': salle,
      'nombreTables': nombreTables,
      'prixParTable': prixParTable,
      'typeClient': typeClient,
      'typeCommande': typeCommande,
      'signatureCachet': signatureCachet,
      'statut': statut,
      'date': date,
      'produits': produits.map((e) => e.toJson()).toList(),
      'objet': objet,
      'commentaire': commentaire,
      'telephone': telephone,
      'heureInvitation': heureInvitation,
    };
  }
}
