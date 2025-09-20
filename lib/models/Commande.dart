import 'package:app_catering/models/Avance.dart';
import 'package:app_catering/models/ProduitCommande.dart';

class Commande {
  final int? id;
  final String numeroCommande;
  final String typeClient;
  final String typeCommande;
  final String statut;
  final String nomClient;
  final String salle;
  final int nombreTables;
  final double prixParTable;
  final double total;
  final bool corbeille;
  final String? dateSuppression;
  final String date;
  String? objet;
  final String? commentaire;
  final List<ProduitCommande> produits;
  List<Avance> avances;
  bool signatureCachet;
  final String? telephone;
  final String? heureInvitation;

  Commande({
    this.id,
    required this.numeroCommande,
    required this.typeClient,
    required this.typeCommande,
    required this.statut,
    required this.nomClient,
    required this.salle,
    required this.nombreTables,
    required this.prixParTable,
    required this.total,
    this.corbeille = false,
    this.dateSuppression,
    required this.date,
    this.objet,
    this.commentaire,
    this.produits = const [],
    this.avances = const [],
    this.signatureCachet = false,
    this.telephone,
    this.heureInvitation,
  });

  /// Calcul dynamique du reste à payer
  double get resteAPayer =>
      total - avances.fold(0.0, (sum, a) => sum + a.montant);

  /// Conversion JSON → Objet
  factory Commande.fromJson(Map<String, dynamic> json) {
    return Commande(
      id: json['id'] as int?,
      numeroCommande: json['numeroCommande'] as String,
      typeClient: json['typeClient'] as String,
      typeCommande: json['typeCommande'] as String,
      statut: json['statut'] as String,
      nomClient: json['nomClient'] as String,
      salle: json['salle'] as String,
      nombreTables: json['nombreTables'] as int,
      prixParTable: (json['prixParTable'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      corbeille: json['corbeille'] ?? false,
      dateSuppression: json['dateSuppression'] as String?,
      date: json['date'] as String,
      objet: json['objet'] as String?,
      commentaire: json['commentaire'] as String?,
      produits: (json['produits'] as List<dynamic>?)
          ?.map((e) => ProduitCommande.fromJson(e))
          .toList() ??
          [],
      avances: (json['avances'] as List<dynamic>?)
          ?.map((e) => Avance.fromJson(e))
          .toList() ??
          [],
      signatureCachet: json['signatureCachet'] ?? false,
      telephone: json['telephone'] as String?,
      heureInvitation: json['heureInvitation'] as String?,
    );
  }

  /// Conversion Objet → JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'numeroCommande': numeroCommande,
      'typeClient': typeClient,
      'typeCommande': typeCommande,
      'statut': statut,
      'nomClient': nomClient,
      'salle': salle,
      'nombreTables': nombreTables,
      'prixParTable': prixParTable,
      'total': total,
      'corbeille': corbeille,
      'dateSuppression': dateSuppression,
      'date': date,
      'objet': objet,
      'commentaire': commentaire,
      'produits': produits.map((e) => e.toJson()).toList(),
      'avances': avances.map((e) => e.toJson()).toList(),
      'signatureCachet': signatureCachet,
      'telephone': telephone,
      'heureInvitation': heureInvitation,
    };
  }
}
