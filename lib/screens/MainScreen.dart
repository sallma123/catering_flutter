import 'package:app_catering/screens/paiements/PaiementsScreen.dart';
import 'package:app_catering/screens/profil/ProfilScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'calendrier/CalendrierScreen.dart';
import 'commandes/CommandesScreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    CommandesScreen(),
    PaiementsScreen(),
    CalendrierScreen(),
    ProfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: const Color(0xFFFFC107),
        unselectedItemColor: Colors.white,
        backgroundColor: Colors.black,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Commandes"),
          BottomNavigationBarItem(icon: Icon(Icons.credit_card), label: "Paiement"),
          BottomNavigationBarItem(icon: Icon(Icons.date_range), label: "Calendrier"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }
}
