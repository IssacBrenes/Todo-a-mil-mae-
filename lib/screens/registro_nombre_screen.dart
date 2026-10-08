// lib/screens/registro_nombre_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main_screen.dart';

class RegistroNombreScreen extends StatefulWidget {
  const RegistroNombreScreen({super.key});

  @override
  State<RegistroNombreScreen> createState() => _RegistroNombreScreenState();
}

class _RegistroNombreScreenState extends State<RegistroNombreScreen> {
  final TextEditingController _nombreController = TextEditingController();
  bool _cargando = false;

  void _guardarPerfil() async {
    if (_nombreController.text.trim().isEmpty) return;
    
    setState(() => _cargando = true);
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // Crea el perfil oficial en la base de datos de Todo a mil mae!
        await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).set({
          'nombre': _nombreController.text.trim(),
          'telefono': user.phoneNumber,
          'puntos': 0, // Todos inician con 0 estrellas
          'fechaRegistro': FieldValue.serverTimestamp(),
        });

        // Lo enviamos a la pantalla maestra para que empiece a comprar
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
        }
      } catch (e) {
        setState(() => _cargando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color amarilloFondo = const Color(0xFFFFF9E6);
    final Color amarilloPrincipal = const Color(0xFFE6B800);

    return Scaffold(
      backgroundColor: amarilloFondo,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: amarilloPrincipal, shape: BoxShape.circle),
                  child: const Icon(Icons.person_add, size: 60, color: Colors.black87),
                ),
                const SizedBox(height: 24),
                const Text('¡Bienvenido!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 8),
                const Text(
                  '¿Cómo te llamás? Queremos saber quién nos visita.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _nombreController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Tu Nombre',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: amarilloPrincipal,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _cargando ? null : _guardarPerfil,
                    child: _cargando 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black87, strokeWidth: 2))
                        : const Text('Comenzar a pedir', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}