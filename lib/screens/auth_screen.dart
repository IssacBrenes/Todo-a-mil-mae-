// lib/screens/auth_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  int _pasoActual = 0; 
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _codigoController = TextEditingController();
  
  bool _cargando = false;
  String _verificationId = '';

  // 1. Conexión real con Firebase para enviar SMS
  void _enviarSMS() async {
    if (_telefonoController.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingresa un número de 8 dígitos válido')));
      return;
    }
    
    setState(() => _cargando = true);
    
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+506${_telefonoController.text.trim()}',
        // Auto-resolución para algunos dispositivos Android
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() => _cargando = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
        },
        // Cuando el SMS sale de los servidores de Google
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _cargando = false;
            _pasoActual = 1; // Transforma la pantalla para pedir el código
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      setState(() => _cargando = false);
    }
  }

  // 2. Verificación del código digitado por el cliente
  void _verificarCodigo() async {
    if (_codigoController.text.length < 6) return;
    setState(() => _cargando = true);

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _codigoController.text.trim(),
      );
      
      // Al iniciar sesión exitosamente, el StreamBuilder del main.dart nos sacará de aquí automáticamente
      await FirebaseAuth.instance.signInWithCredential(credential);
      
    } catch (e) {
      setState(() => _cargando = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Código incorrecto o expirado', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
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
                  child: const Icon(Icons.fastfood, size: 60, color: Colors.black87),
                ),
                const SizedBox(height: 24),
                const Text('Todo a mil mae!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 8),
                Text(
                  _pasoActual == 0 ? 'Ingresa para pedir sin complicaciones' : 'Ingresa el código que te enviamos',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // PASO 0: TELÉFONO
                if (_pasoActual == 0) ...[
                  TextField(
                    controller: _telefonoController,
                    keyboardType: TextInputType.phone,
                    maxLength: 8,
                    decoration: InputDecoration(
                      prefixText: '+506 ',
                      prefixStyle: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
                      labelText: 'Número de Teléfono',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      counterText: '',
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
                      onPressed: _cargando ? null : _enviarSMS,
                      child: _cargando 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black87, strokeWidth: 2))
                          : const Text('Enviar código por SMS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                    ),
                  ),
                ],

                // PASO 1: CÓDIGO SMS
                if (_pasoActual == 1) ...[
                  TextField(
                    controller: _codigoController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: '000000',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      counterText: '',
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
                      onPressed: _cargando ? null : _verificarCodigo,
                      child: _cargando 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black87, strokeWidth: 2))
                          : const Text('Verificar Código', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _pasoActual = 0),
                    child: const Text('Cambiar número de teléfono', style: TextStyle(color: Colors.orange)),
                  )
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}