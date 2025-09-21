import 'dart:convert';
import 'package:http/http.dart' as http;

import '../data/dto/CommandeDTO.dart';
import '../models/Avance.dart';
import '../models/CategorieProduit.dart';
import '../models/Commande.dart';
import '../models/LoginRequest.dart';
import '../models/LoginResponse.dart';
import '../models/ProduitDefini.dart';
import '../models/RegisterRequest.dart';

class ApiService {
  static const String baseUrl = "http://192.168.1.5:8080/"; // comme ton Retrofit

  // ✅ Centralisation des headers
  final Map<String, String> headers = {
    "Content-Type": "application/json",
    "Accept": "application/json",
  };

  Future<LoginResponse?> loginUser(LoginRequest request) async {
    final response = await http.post(
      Uri.parse("${baseUrl}api/auth/login"),
      headers: headers,
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return LoginResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Échec de connexion : ${response.statusCode}");
    }
  }

  Future<bool> registerUser(RegisterRequest request) async {
    final response = await http.post(
      Uri.parse("${baseUrl}api/auth/register"),
      headers: headers,
      body: jsonEncode(request.toJson()),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  /// 🔹 GET commandes
  Future<List<Commande>> getCommandes() async {
    final response = await http.get(
      Uri.parse("${baseUrl}api/commandes"),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((json) => Commande.fromJson(json)).toList();
    } else {
      throw Exception("Erreur chargement commandes: ${response.statusCode}");
    }
  }

  /// 🔹 POST créer commande
  Future<Commande?> creerCommande(CommandeDTO dto) async {
    final response = await http.post(
      Uri.parse("${baseUrl}api/commandes"),
      headers: headers,
      body: jsonEncode(dto.toJson()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Commande.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  /// 🔹 PUT modifier commande
  Future<Commande?> modifierCommande(int id, CommandeDTO dto) async {
    final response = await http.put(
      Uri.parse("${baseUrl}api/commandes/$id"),
      headers: headers,
      body: jsonEncode(dto.toJson()),
    );
    if (response.statusCode == 200) {
      return Commande.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  /// 🔹 POST ajouter avance
  Future<void> ajouterAvance(int idCommande, Avance avance) async {
    final response = await http.post(
      Uri.parse("${baseUrl}api/commandes/$idCommande/avances"),
      headers: headers,
      body: jsonEncode(avance.toJson()),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Erreur ajout avance: ${response.statusCode}");
    }
  }

  /// 🔹 GET avances par commande
  Future<List<Avance>> getAvancesByCommande(int idCommande) async {
    final response = await http.get(
      Uri.parse("${baseUrl}api/commandes/$idCommande/avances"),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((json) => Avance.fromJson(json)).toList();
    } else {
      throw Exception("Erreur chargement avances: ${response.statusCode}");
    }
  }

  /// 🔹 Vérifier date
  Future<bool> verifierDate(String date) async {
    final response = await http.get(
      Uri.parse("${baseUrl}api/commandes/verifier-date?date=$date"),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as bool;
    }
    return false;
  }

  /// 🔹 Déplacer vers corbeille
  Future<void> deplacerVersCorbeille(int id) async {
    final response = await http.put(
      Uri.parse("${baseUrl}api/commandes/$id/corbeille"),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception("Erreur suppression soft: ${response.statusCode}");
    }
  }

  /// 🔹 GET commandes dans corbeille
  Future<List<Commande>> getCommandesDansCorbeille() async {
    final response = await http.get(
      Uri.parse("${baseUrl}api/commandes/corbeille"),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((json) => Commande.fromJson(json)).toList();
    } else {
      throw Exception("Erreur corbeille: ${response.statusCode}");
    }
  }

  /// 🔹 Restaurer commande
  Future<void> restaurerCommande(int id) async {
    final response = await http.put(
      Uri.parse("${baseUrl}api/commandes/$id/restaurer"),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception("Erreur restauration commande: ${response.statusCode}");
    }
  }

  /// 🔹 Supprimer définitivement commande
  Future<void> supprimerCommandeDefinitivement(int id) async {
    final response = await http.delete(
      Uri.parse("${baseUrl}api/commandes/$id"),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception("Erreur suppression définitive: ${response.statusCode}");
    }
  }

  /// 🔹 Supprimer une avance
  Future<void> supprimerAvance(int idCommande, int idAvance) async {
    final response = await http.delete(
      Uri.parse("${baseUrl}api/commandes/$idCommande/avances/$idAvance"),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception("Erreur suppression avance: ${response.statusCode}");
    }
  }
  // 🔹 CATALOGUE
  // -----------------------------

  /// Charger le catalogue par type de commande (ex: "MARIAGE")
  Future<List<CategorieProduit>> getCatalogue(String typeCommande) async {
    final response = await http.get(
      Uri.parse("${baseUrl}api/catalogue/$typeCommande"),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((json) => CategorieProduit.fromJson(json)).toList();
    } else {
      throw Exception("Erreur chargement catalogue: ${response.statusCode}");
    }
  }

  /// Créer une catégorie
  Future<CategorieProduit?> creerCategorie(CategorieProduit categorie) async {
    final response = await http.post(
      Uri.parse("${baseUrl}api/catalogue"),
      headers: headers,
      body: jsonEncode(categorie.toJson()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return CategorieProduit.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  /// Modifier une catégorie
  Future<CategorieProduit?> modifierCategorie(int id, CategorieProduit categorie) async {
    final response = await http.put(
      Uri.parse("${baseUrl}api/catalogue/$id"),
      headers: headers,
      body: jsonEncode(categorie.toJson()),
    );
    if (response.statusCode == 200) {
      return CategorieProduit.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  /// Supprimer une catégorie
  Future<void> supprimerCategorie(int id) async {
    final response = await http.delete(
      Uri.parse("${baseUrl}api/catalogue/$id"),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception("Erreur suppression catégorie: ${response.statusCode}");
    }
  }

  // -----------------------------
  // 🔹 PRODUITS DÉFINIS
  // -----------------------------

  /// Créer un produit dans une catégorie
  Future<ProduitDefini?> creerProduit(int categorieId, ProduitDefini produit) async {
    final response = await http.post(
      Uri.parse("${baseUrl}api/catalogue/$categorieId/produits"),
      headers: headers,
      body: jsonEncode(produit.toJson()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return ProduitDefini.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  /// Modifier un produit
  Future<ProduitDefini?> modifierProduit(int id, ProduitDefini produit) async {
    final response = await http.put(
      Uri.parse("${baseUrl}api/catalogue/produits/$id"),
      headers: headers,
      body: jsonEncode(produit.toJson()),
    );
    if (response.statusCode == 200) {
      return ProduitDefini.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  /// Supprimer un produit
  Future<void> supprimerProduit(int id) async {
    final response = await http.delete(
      Uri.parse("${baseUrl}api/catalogue/produits/$id"),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception("Erreur suppression produit: ${response.statusCode}");
    }
  }

  // -----------------------------
  // 🔹 REFERENCE VALUES
  /*

  Future<List<ReferenceValue>> getReferenceValuesByCategory(String category) async {
    final response = await http.get(
      Uri.parse("${baseUrl}api/references/$category"),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((json) => ReferenceValue.fromJson(json)).toList();
    } else {
      throw Exception("Erreur chargement références: ${response.statusCode}");
    }
  }

  Future<List<ReferenceValue>> getAllReferenceValues() async {
    final response = await http.get(
      Uri.parse("${baseUrl}api/references"),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((json) => ReferenceValue.fromJson(json)).toList();
    } else {
      throw Exception("Erreur chargement références globales: ${response.statusCode}");
    }
  }

  Future<ReferenceValue?> addReferenceValue(ReferenceValue value) async {
    final response = await http.post(
      Uri.parse("${baseUrl}api/references"),
      headers: headers,
      body: jsonEncode(value.toJson()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return ReferenceValue.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<ReferenceValue?> updateReferenceValue(int id, ReferenceValue value) async {
    final response = await http.put(
      Uri.parse("${baseUrl}api/references/$id"),
      headers: headers,
      body: jsonEncode(value.toJson()),
    );
    if (response.statusCode == 200) {
      return ReferenceValue.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<void> deleteReferenceValue(int id) async {
    final response = await http.delete(
      Uri.parse("${baseUrl}api/references/$id"),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception("Erreur suppression référence: ${response.statusCode}");
    }
  }*/
}
