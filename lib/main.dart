import 'package:app_catering/screens/profil/CatalogueScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:app_catering/providers/AuthProvider.dart';
import 'package:app_catering/providers/CommandeProvider.dart';
import 'package:app_catering/providers/CatalogueProvider.dart';
import 'package:app_catering/services/ApiService.dart';
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
        ChangeNotifierProvider(
          create: (_) => CatalogueProvider(api: ApiService()),
        ),
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
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFC107), // 🌟 gold comme couleur principale
          secondary: Color(0xFFFFC107),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFC107),
            foregroundColor: Colors.black,
            minimumSize: const Size.fromHeight(48),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFFFC107),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFFFC107),
          foregroundColor: Colors.black,
        ),
      ),
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
      routes: {
        "/catalogue": (_) => const CatalogueScreen(),
      },
    );
  }
}
