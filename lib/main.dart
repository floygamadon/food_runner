import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const FoodRunnerApp());
}

class FoodRunnerApp extends StatelessWidget {
  const FoodRunnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Food Runner',
      home: const Scaffold(
        body: Center(
          child: Text('Food Runner is connected to Firebase'),
        ),
      ),
    );
  }
}