// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart'; 
import 'providers/carrito_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/main_screen.dart';
import 'screens/registro_nombre_screen.dart';

// EL PUNTO DE ARRANQUE (Lo que Chrome no encontraba)
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CarritoProvider()),
      ],
      child: const TodoAMilMaeApp(),
    ),
  );
}

class TodoAMilMaeApp extends StatelessWidget {
  const TodoAMilMaeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo a mil mae!',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        fontFamily: 'Roboto', 
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Color(0xFFFFF9E6),
              body: Center(child: CircularProgressIndicator(color: Colors.orange)),
            );
          }
          
          if (snapshot.hasData) {
            return VerificadorPerfil(usuario: snapshot.data!); 
          }
          
          return const AuthScreen();
        },
      ),
    );
  }
}

class VerificadorPerfil extends StatelessWidget {
  final User usuario;
  const VerificadorPerfil({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('usuarios').doc(usuario.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFFFF9E6),
            body: Center(child: CircularProgressIndicator(color: Colors.orange)),
          );
        }
        
        if (snapshot.hasData && snapshot.data!.exists) {
          return const MainScreen();
        } 
        
        return const RegistroNombreScreen();
      },
    );
  }
}