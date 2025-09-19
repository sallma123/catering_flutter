import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/LoginRequest.dart';
import '../models/LoginResponse.dart';
import '../models/RegisterRequest.dart';


class ApiService {
  static const String baseUrl = "http://192.168.1.6:8080/"; // comme ton Retrofit

  Future<LoginResponse?> loginUser(LoginRequest request) async {
    final response = await http.post(
      Uri.parse("${baseUrl}api/auth/login"),
      headers: {"Content-Type": "application/json"},
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
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

}
