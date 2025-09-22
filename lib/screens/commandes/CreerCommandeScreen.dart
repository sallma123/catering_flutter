import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/Commande.dart';
import '../../models/ProduitCommande.dart';
import '../../providers/CommandeProvider.dart';
import '../../data/dto/CommandeDTO.dart';

class CreerCommandeScreen extends StatefulWidget {
  final Commande? commandeInitiale;
  final String typeClient;

  const CreerCommandeScreen({
    super.key,
    required this.typeClient,
    this.commandeInitiale,
  });

  @override
  State<CreerCommandeScreen> createState() => _CreerCommandeScreenState();
}

class _CreerCommandeScreenState extends State<CreerCommandeScreen> {
  final _formKey = GlobalKey<FormState>();

  late String nomClient;
  late String salle;
  late String nombre;
  late String date;
  late String typeCommande;
  late String statut;
  late String objet;
  late String commentaire;
  late String telephone;
  late String heureInvitation;

  late TextEditingController dateController;
  late TextEditingController heureController;
  late TextEditingController autreSalleController;

  final List<String> sallesDisponibles = [
    "Salle des Roses",
    "Palais Royal",
    "Golden Events",
    "Almazar",
    "Autre"
  ];

  final Map<String, String> statutLabels = {
    "NOUVEAU": "Nouveau",
    "CONFIRMEE": "Confirmée",
    "ANNULEE": "Annulée",
    "PAYEE_PARTIELLEMENT": "Payée partiellement",
    "PAYEE": "Payée"
  };

  @override
  void initState() {
    super.initState();
    final cmd = widget.commandeInitiale;
    nomClient = cmd?.nomClient ?? '';
    salle = cmd != null && cmd.salle.isNotEmpty ? cmd.salle : ''; // ❌ vide si nouvelle commande
    nombre = cmd?.nombreTables.toString() ?? '';
    date = cmd?.date ?? _getToday();
    typeCommande = cmd?.typeCommande ?? '';
    statut = cmd?.statut ?? 'NOUVEAU';
    objet = cmd?.objet ?? '';
    commentaire = cmd?.commentaire ?? '';
    telephone = cmd?.telephone ?? '';
    heureInvitation = cmd?.heureInvitation ?? '';

    // Controllers
    dateController = TextEditingController(text: date);
    heureController = TextEditingController(text: heureInvitation);
    autreSalleController = TextEditingController(
        text: salle.isNotEmpty && !sallesDisponibles.contains(salle) ? salle : '');
  }

  @override
  void dispose() {
    dateController.dispose();
    heureController.dispose();
    autreSalleController.dispose();
    super.dispose();
  }

  String _getToday() {
    final now = DateTime.now();
    return "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        date =
        "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
        dateController.text = date;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        heureInvitation =
        "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
        heureController.text = heureInvitation;
      });
    }
  }

  void _continuerCreationCommande() {
    final isoDate = _convertToIso(date);
    final salleFinal =
    salle == "Autre" ? autreSalleController.text : salle;

    final dto = CommandeDTO(
      id: widget.commandeInitiale?.id,
      nomClient: nomClient,
      salle: salleFinal,
      nombreTables: int.tryParse(nombre) ?? 0,
      prixParTable: 0,
      typeClient: widget.typeClient,
      typeCommande: typeCommande,
      statut: statut,
      date: isoDate,
      produits: widget.commandeInitiale?.produits ?? [],
      objet: objet,
      commentaire: commentaire,
      telephone: telephone,
      heureInvitation: heureInvitation,
    );

    Navigator.of(context).pop(dto);
  }

  String _convertToIso(String dateFr) {
    try {
      final parts = dateFr.split('/');
      return "${parts[2]}-${parts[1]}-${parts[0]}";
    } catch (_) {
      return "2025-01-01";
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CommandeProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title: Text(
          widget.commandeInitiale != null
              ? "Modification commande"
              : "Création commande : ${widget.typeClient.toUpperCase()}",
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Type commande
              DropdownButtonFormField<String>(
                value: typeCommande.isEmpty ? null : typeCommande,
                items: (widget.typeClient.toLowerCase() == "entreprise"
                    ? [
                  "Buffet de soutenance",
                  "Repas coffret",
                  "Séminaire",
                  "Ftour Ramadan"
                ]
                    : [
                  "Mariage",
                  "Anniversaire",
                  "Baptême",
                  "Fiançailles",
                  "Henna",
                  "Ftour Ramadan"
                ])
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => typeCommande = val ?? ''),
                decoration: _fieldDecoration("Type de commande"),
              ),

              const SizedBox(height: 12),
              _buildTextField("Nom du client", nomClient, (val) => nomClient = val),
              const SizedBox(height: 12),

              // Salle
              DropdownButtonFormField<String>(
                value: salle.isEmpty ? null : sallesDisponibles.contains(salle) ? salle : "Autre",
                items: sallesDisponibles
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    salle = val ?? '';
                    if (salle != "Autre" && sallesDisponibles.contains(salle)) {
                      autreSalleController.text = salle;
                    } else if (salle == "Autre") {
                      autreSalleController.text = '';
                    }
                  });
                },
                decoration: _fieldDecoration("Salle"),
              ),

              const SizedBox(height: 12),

              // Champ pour "Autre salle"
              if (salle == "Autre")
                _buildTextField(
                    "Nom de la salle",
                    autreSalleController.text,
                        (val) => autreSalleController.text = val),

              const SizedBox(height: 12),
              // Nombre de tables / personnes
              _buildTextField(
                  widget.typeClient.toLowerCase() == "entreprise"
                      ? "Nombre de personnes"
                      : "Nombre de tables",
                  nombre,
                      (val) => nombre = val,
                  keyboardType: TextInputType.number),

              const SizedBox(height: 12),
              // Date
              InkWell(
                onTap: _pickDate,
                child: TextFormField(
                  controller: dateController,
                  enabled: false,
                  style: const TextStyle(color: Colors.white),
                  decoration: _fieldDecoration("Date"),
                ),
              ),

              const SizedBox(height: 12),
              // Téléphone
              _buildTextField(
                  "Téléphone", telephone, (val) => telephone = val,
                  keyboardType: TextInputType.phone),

              const SizedBox(height: 12),
              // Heure invitation
              InkWell(
                onTap: _pickTime,
                child: TextFormField(
                  controller: heureController,
                  enabled: false,
                  style: const TextStyle(color: Colors.white),
                  decoration: _fieldDecoration("Heure d'invitation"),
                ),
              ),

              const SizedBox(height: 12),
              // Statut
              DropdownButtonFormField<String>(
                value: statutLabels[statut],
                items: statutLabels.values
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) {
                  final selected = statutLabels.entries
                      .firstWhere((entry) => entry.value == val)
                      .key;
                  setState(() => statut = selected);
                },
                decoration: _fieldDecoration("Statut"),
              ),

              const SizedBox(height: 12),
              // Objet (facultatif)
              if (widget.typeClient.toLowerCase() == "entreprise")
                _buildTextField("Objet (facultatif)", objet, (val) => objet = val),

              if (widget.typeClient.toLowerCase() == "entreprise")
                const SizedBox(height: 12),

              // Commentaire
              _buildTextField("Commentaire", commentaire, (val) => commentaire = val),

              const SizedBox(height: 24),
              Row(
                children: [
                  if (widget.commandeInitiale != null)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          provider.modifierCommande(
                              widget.commandeInitiale!.id!, _toDto(),
                              onSuccess: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Commande modifiée")));
                              });
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            minimumSize: const Size.fromHeight(50)),
                        child: const Text("Modifier"),
                      ),
                    ),
                  if (widget.commandeInitiale != null) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _continuerCreationCommande,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFC107),
                          minimumSize: const Size.fromHeight(50)),
                      child: const Text("Suivant",
                          style: TextStyle(color: Colors.black)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  CommandeDTO _toDto() {
    final salleFinal = salle == "Autre" ? autreSalleController.text : salle;
    return CommandeDTO(
      id: widget.commandeInitiale?.id,
      nomClient: nomClient,
      salle: salleFinal,
      nombreTables: int.tryParse(nombre) ?? 0,
      prixParTable: widget.commandeInitiale?.prixParTable ?? 0,
      typeClient: widget.typeClient,
      typeCommande: typeCommande,
      statut: statut,
      date: _convertToIso(date),
      produits: widget.commandeInitiale?.produits ?? [],
      objet: objet,
      commentaire: commentaire,
      telephone: telephone,
      heureInvitation: heureInvitation,
    );
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white),
      enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFFFC107)),
          borderRadius: BorderRadius.circular(8)),
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
    );
  }

  Widget _buildTextField(String label, String value, Function(String) onChanged,
      {TextInputType keyboardType = TextInputType.text, bool enabled = true}) {
    return TextFormField(
      initialValue: value,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      enabled: enabled,
      decoration: _fieldDecoration(label),
    );
  }
}
