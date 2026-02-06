import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:vault_clothes/core/services/service_locator.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  setupLocator();

  runApp(const VaultClothesApp());
}

class VaultClothesApp extends StatelessWidget {
  const VaultClothesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vault Clothes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Vault Clothes Initialized'),
        ),
      ),
    );
  }
}
