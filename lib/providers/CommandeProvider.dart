import 'package:flutter/material.dart';
import '../data/dto/CommandeDTO.dart';
import '../models/Commande.dart';
import '../models/Avance.dart';
import '../services/ApiService.dart';

class CommandeProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Commande> _commandes = [];
  List<Commande> get commandes => _commandes;

  Map<String, List<Commande>> _commandesParDate = {};
  Map<String, List<Commande>> get commandesParDate => _commandesParDate;

  List<Commande> _corbeille = [];
  List<Commande> get corbeille => _corbeille;

  bool isLoading = false;

  /// Charger toutes les commandes actives
  Future<void> fetchCommandes() async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await _apiService.getCommandes();
      _commandes = response.where((c) => !c.corbeille).toList();
      _regrouperParDate(_commandes);

      // Charger les avances pour chaque commande directement
      for (var cmd in _commandes) {
        if (cmd.id != null) {
          cmd.avances = await _apiService.getAvancesByCommande(cmd.id!);
        }
      }
    } catch (e) {
      _commandes = [];
      _commandesParDate = {};
      debugPrint("Erreur fetchCommandes: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _regrouperParDate(List<Commande> commandes) {
    _commandesParDate = {};
    for (var cmd in commandes) {
      _commandesParDate.putIfAbsent(cmd.date, () => []);
      _commandesParDate[cmd.date]!.add(cmd);
    }
  }

  /// Créer une commande
  Future<void> creerCommande(
      CommandeDTO dto, {
        required Function(int id) onSuccess,
        Function()? onError,
      }) async {
    try {
      final response = await _apiService.creerCommande(dto);
      if (response != null && response.id != null) {
        await fetchCommandes();
        onSuccess(response.id!);
      } else {
        onError?.call();
      }
    } catch (e) {
      debugPrint("Erreur création commande: $e");
      onError?.call();
    }
  }

  /// Modifier une commande
  Future<void> modifierCommande(
      int id,
      CommandeDTO dto, {
        Function()? onSuccess,
        Function()? onError,
      }) async {
    try {
      final response = await _apiService.modifierCommande(id, dto);
      if (response != null) {
        await fetchCommandes();
        onSuccess?.call();
      } else {
        onError?.call();
      }
    } catch (e) {
      debugPrint("Erreur modifierCommande: $e");
      onError?.call();
    }
  }

  /// Vérifier si une date est déjà réservée
  Future<bool> verifierDate(String dateIso) async {
    try {
      return await _apiService.verifierDate(dateIso);
    } catch (e) {
      debugPrint("Erreur vérification date: $e");
      return false;
    }
  }

  /// Ajouter une avance à une commande
  Future<void> ajouterAvance(int idCommande, Avance avance) async {
    try {
      await _apiService.ajouterAvance(idCommande, avance);
      await fetchCommandes();
    } catch (e) {
      debugPrint("Erreur ajout avance: $e");
    }
  }

  /// Supprimer une avance d'une commande
  Future<void> supprimerAvance(int idCommande, int idAvance) async {
    try {
      await _apiService.supprimerAvance(idCommande, idAvance);
      await fetchCommandes();
    } catch (e) {
      debugPrint("Erreur suppression avance: $e");
    }
  }

  /// Soft delete → corbeille
  Future<void> supprimerCommandeSoft(int id, {Function()? onSuccess}) async {
    try {
      await _apiService.deplacerVersCorbeille(id);
      await fetchCommandes();
      onSuccess?.call();
    } catch (e) {
      debugPrint("Erreur suppression soft: $e");
    }
  }

  /// Charger corbeille
  Future<void> fetchCorbeille() async {
    try {
      _corbeille = await _apiService.getCommandesDansCorbeille();
      notifyListeners();
    } catch (e) {
      debugPrint("Erreur fetchCorbeille: $e");
    }
  }

  /// Restaurer commande
  Future<void> restaurerCommande(int id, {Function()? onSuccess}) async {
    try {
      await _apiService.restaurerCommande(id);
      await fetchCorbeille();
      await fetchCommandes();
      onSuccess?.call();
    } catch (e) {
      debugPrint("Erreur restauration: $e");
    }
  }

  /// Supprimer définitivement
  Future<void> supprimerDefinitivement(int id, {Function()? onSuccess}) async {
    try {
      await _apiService.supprimerCommandeDefinitivement(id);
      await fetchCorbeille();
      onSuccess?.call();
    } catch (e) {
      debugPrint("Erreur suppression définitive: $e");
    }
  }
}
