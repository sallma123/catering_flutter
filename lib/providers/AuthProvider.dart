import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/LoginRequest.dart';
import '../models/LoginResponse.dart';
import '../services/ApiService.dart';

enum LoginState { idle, loading, success, error }

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  LoginState _state = LoginState.idle;
  LoginState get state => _state;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  LoginResponse? _user;
  LoginResponse? get user => _user;

  AuthProvider() {
    _loadUserFromPrefs();
  }

  /// ✅ Connexion
  Future<void> login(String email, String password) async {
    _state = LoginState.loading;
    notifyListeners();

    try {
      final request = LoginRequest(email: email, password: password);
      final LoginResponse? response = await _apiService.loginUser(request);

      if (response != null) {
        _user = response;
        _state = LoginState.success;

        // Sauvegarder id et email dans SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('id', _user!.id);
        await prefs.setString('email', _user!.email);
      } else {
        _state = LoginState.error;
        _errorMessage = 'Email ou mot de passe incorrect';
      }
    } catch (e) {
      _state = LoginState.error;
      _errorMessage = 'Erreur réseau : ${e.toString()}';
    } finally {
      notifyListeners();
    }
  }

  /// ✅ Déconnexion
  Future<void> logout() async {
    _user = null;
    _state = LoginState.idle;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Supprime toutes les données sauvegardées

    notifyListeners();
  }

  /// ✅ Réinitialiser l’état
  void resetState() {
    _state = LoginState.idle;
    _errorMessage = '';
    notifyListeners();
  }

  /// ✅ Charger les infos sauvegardées au lancement de l’app
  Future<void> _loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final int? id = prefs.getInt('id');
    final String? email = prefs.getString('email');

    if (id != null && email != null) {
      _user = LoginResponse(id: id, email: email);
      _state = LoginState.success;
      notifyListeners();
    }
  }
}
