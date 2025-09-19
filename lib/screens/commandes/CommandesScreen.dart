import 'package:flutter/material.dart';

class CommandesScreen extends StatelessWidget {
  const CommandesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Commandes'),
        backgroundColor: Colors.black87,
      ),
      body: const Center(
        child: Text(
          'Bienvenue sur l\'écran des commandes !',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      backgroundColor: const Color(0xFF121212),
    );
  }
}
