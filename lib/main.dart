// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
// ignore: unused_import
import 'package:todo_a_mil_mae/screens/auth_screen.dart';
import 'package:todo_a_mil_mae/screens/main_screen.dart';
import 'firebase_options.dart';
import 'providers/carrito_provider.dart';
// ignore: unused_import
import 'screens/menu_principal.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => CarritoProvider(),
      child: const TodoAMilApp(),
    ),
  );
}

class TodoAMilApp extends StatelessWidget {
  const TodoAMilApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo a mil mae!',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MainScreen(),
    );
  }
}