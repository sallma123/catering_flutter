import 'package:flutter/foundation.dart';
import '../models/CategorieProduit.dart';
import '../models/ProduitDefini.dart';
import '../services/ApiService.dart';

class CatalogueProvider extends ChangeNotifier {
  final ApiService api;

  CatalogueProvider({required this.api});

  List<CategorieProduit> _categories = [];
  List<CategorieProduit> get categories => _categories;

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  // 🔹 Types de commande (statiques pour l’instant)
  final List<String> typesCommandeLabels = [
    "Mariage",
    "Anniversaire",
    "Baptême",
    "Buffet de soutenance",
    "Repas coffret",
    "Séminaire",
    "Ftour Ramadan",
    "Fiançailles",
    "Henna"
  ];

  String toEnum(String value) {
    switch (value.trim().toLowerCase()) {
      case "mariage":
        return "MARIAGE";
      case "anniversaire":
        return "ANNIVERSAIRE";
      case "baptême":
      case "bapteme":
        return "BAPTEME";
      case "buffet de soutenance":
        return "BUFFET_DE_SOUTENANCE";
      case "repas coffret":
        return "REPAS_COFFRET";
      case "séminaire":
      case "seminaire":
        return "SEMINAIRE";
      case "ftour ramadan":
        return "FTOUR_RAMADAN";
      case "fiançailles":
      case "fiancailles":
        return "FIANCAILLES";
      case "henna":
        return "HENNA";
      default:
        return value.toUpperCase().replaceAll(" ", "_");
    }
  }

  // -----------------------------
  // 🔹 Charger le catalogue
  // -----------------------------
  Future<void> fetchCatalogue(String typeCommande) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final enumValue = typeCommande.contains("_") ? typeCommande : toEnum(typeCommande);
      final result = await api.getCatalogue(enumValue);
      _categories = result..sort((a, b) => a.ordreAffichage.compareTo(b.ordreAffichage));
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // -----------------------------
  // 🔹 Ajouter Catégorie
  // -----------------------------
  Future<bool> ajouterCategorie(String typeCommande, String nom, int ordre) async {
    try {
      final enumValue = toEnum(typeCommande);
      final nouvelleCategorie = CategorieProduit(
        id: null,
        nom: nom,
        ordreAffichage: ordre,
        typeCommande: enumValue,
        produits: [],
      );
      final saved = await api.creerCategorie(nouvelleCategorie);
      if (saved != null) {
        _categories.add(saved);
        _categories.sort((a, b) => a.ordreAffichage.compareTo(b.ordreAffichage));
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // -----------------------------
  // 🔹 Modifier Catégorie
  // -----------------------------
  Future<void> modifierCategorie(CategorieProduit categorie) async {
    if (categorie.id == null) return;
    try {
      final updated = await api.modifierCategorie(categorie.id!, categorie);
      if (updated != null) {
        _categories = _categories.map((c) => c.id == updated.id ? updated : c).toList();
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // -----------------------------
  // 🔹 Supprimer Catégorie
  // -----------------------------
  Future<void> supprimerCategorie(int id) async {
    try {
      await api.supprimerCategorie(id);
      _categories.removeWhere((c) => c.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // -----------------------------
  // 🔹 Ajouter Produit
  // -----------------------------
  Future<void> ajouterProduit(int categorieId, {String nom = "Nouveau produit", int? ordre}) async {
    final categorie = _categories.firstWhere(
          (c) => c.id == categorieId,
      orElse: () => CategorieProduit(id: null, nom: "", ordreAffichage: 0, typeCommande: "", produits: []),
    );
    try {
      final nextOrder = ordre ??
          (categorie.produits.isNotEmpty
              ? categorie.produits.map((p) => p.ordreAffichage).reduce((a, b) => a > b ? a : b) + 1
              : 1);

      final nouveauProduit = ProduitDefini(
        id: null,
        nom: nom,
        ordreAffichage: nextOrder,
        categorieId: categorieId,
      );

      final saved = await api.creerProduit(categorieId, nouveauProduit);
      if (saved != null) {
        _categories = _categories.map((c) {
          if (c.id == categorieId) {
            return c.copyWith(
              produits: [...c.produits, saved]..sort((a, b) => a.ordreAffichage.compareTo(b.ordreAffichage)),
            );
          }
          return c;
        }).toList();
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // -----------------------------
  // 🔹 Modifier Produit
  // -----------------------------
  Future<void> modifierProduit(ProduitDefini produit) async {
    if (produit.id == null) return;
    try {
      final updated = await api.modifierProduit(produit.id!, produit);
      if (updated != null) {
        _categories = _categories.map((c) {
          if (c.id == updated.categorieId) {
            return c.copyWith(
              produits: c.produits.map((p) => p.id == updated.id ? updated : p).toList(),
            );
          }
          return c;
        }).toList();
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // -----------------------------
  // 🔹 Supprimer Produit
  // -----------------------------
  Future<void> supprimerProduit(int id) async {
    try {
      await api.supprimerProduit(id);
      _categories = _categories.map((c) {
        return c.copyWith(produits: c.produits.where((p) => p.id != id).toList());
      }).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // -----------------------------
  // 🔹 Copier tout le catalogue (sourceType -> cibleType)
  // -----------------------------
  Future<bool> copierCatalogue(String sourceType, String cibleType) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final sourceEnum = toEnum(sourceType);
      final cibleEnum = toEnum(cibleType);

      final categoriesSource = await api.getCatalogue(sourceEnum);

      for (final cat in categoriesSource) {
        final nouvelleCat = CategorieProduit(
          id: null,
          nom: cat.nom,
          ordreAffichage: cat.ordreAffichage,
          typeCommande: cibleEnum,
          produits: [],
        );

        final catCree = await api.creerCategorie(nouvelleCat);
        if (catCree != null && cat.produits.isNotEmpty) {
          for (final prod in cat.produits) {
            final nouveauProd = ProduitDefini(
              id: null,
              nom: prod.nom,
              ordreAffichage: prod.ordreAffichage,
              categorieId: catCree.id!,
            );
            await api.creerProduit(catCree.id!, nouveauProd);
          }
        }
      }

      // Rafraîchir l'affichage pour le type cible
      await fetchCatalogue(cibleType);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // -----------------------------
  // 🔹 Copier une catégorie (avec ses produits) vers un autre type
  // -----------------------------
  Future<bool> copierCategorie(CategorieProduit categorie, String cibleType) async {
    _error = null;
    notifyListeners();

    try {
      final cibleEnum = toEnum(cibleType);

      final nouvelleCat = CategorieProduit(
        id: null,
        nom: categorie.nom,
        ordreAffichage: categorie.ordreAffichage,
        typeCommande: cibleEnum,
        produits: [],
      );

      final catCree = await api.creerCategorie(nouvelleCat);

      if (catCree != null && categorie.produits.isNotEmpty) {
        for (final prod in categorie.produits) {
          final nouveauProd = ProduitDefini(
            id: null,
            nom: prod.nom,
            ordreAffichage: prod.ordreAffichage,
            categorieId: catCree.id!,
          );
          await api.creerProduit(catCree.id!, nouveauProd);
        }
      }

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      notifyListeners();
    }
  }
}
