class Avance {
  final int? id;
  final double montant;
  final String date;
  final String? type;

  Avance({
    this.id,
    required this.montant,
    required this.date,
    this.type,
  });

  /// Conversion JSON → Objet
  factory Avance.fromJson(Map<String, dynamic> json) {
    return Avance(
      id: json['id'] as int?,
      montant: (json['montant'] as num).toDouble(),
      date: json['date'] as String,
      type: json['type'] as String?,
    );
  }

  /// Conversion Objet → JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'montant': montant,
      'date': date,
      'type': type,
    };
  }
}
