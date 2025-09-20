import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart'; // ⬅️ important
import 'package:app_catering/providers/AuthProvider.dart';
import 'package:app_catering/providers/CommandeProvider.dart';
import 'package:app_catering/screens/auth/LoginScreen.dart';
import 'package:app_catering/screens/auth/RegisterScreen.dart';
import 'package:app_catering/screens/commandes/CommandesScreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise les données locales (fr, en, etc.)
  await initializeDateFormatting('fr', null);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CommandeProvider()),
      ],
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
            // écran de mot de passe oublié
          },
        ),
      ),
    );
  }
}
