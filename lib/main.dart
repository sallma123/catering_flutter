import 'package:app_catering/providers/AuthProvider.dart';
import 'package:app_catering/screens/auth/RegisterScreen.dart';
import 'package:app_catering/screens/commandes/CommandesScreen.dart';
import 'package:app_catering/screens/auth/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const CateringApp(),
    ),
  );
}

class CateringApp extends StatelessWidget {
  const CateringApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catering App',
      theme: ThemeData.dark(),
      home: Builder(
        builder: (context) => LoginScreen(
          onLoginSuccess: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const CommandesScreen()),
            );
          },
          onNavigateToRegister: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => RegisterScreen()),
            );
          },
          onNavigateToForgotPassword: () {
            // Ici tu peux naviguer vers ton écran de mot de passe oublié
          },
        ),
      ),
    );
  }
}
