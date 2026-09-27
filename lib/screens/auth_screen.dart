// lib/screens/auth_screen.dart
import 'package:flutter/material.dart';
import 'main_screen.dart';

// ignore: unused_import
import 'menu_principal.dart'; // Asegúrate de que la ruta sea correcta

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // Estados: 0 = Teléfono, 1 = Código SMS, 2 = Nombre (Usuario Nuevo)
  int _pasoActual = 0;

  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();

  bool _cargando = false;

  // 1. Simulación de envío de SMS (Firebase Auth)
  void _enviarSMS() {
    if (_telefonoController.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un número de 8 dígitos válido')),
      );
      return;
    }
    setState(() => _cargando = true);

    // Simula el tiempo de red de Firebase
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _cargando = false;
        _pasoActual = 1; // Avanza a pedir el código
      });
    });
  }

  // 2. Simulación de verificación de código SMS
  void _verificarCodigo() {
    if (_codigoController.text.length < 6) return;
    setState(() => _cargando = true);

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _cargando = false;
        // Lógica futura: Si Firebase dice que es usuario nuevo, pasamos al paso 2.
        // Si ya existe, lo mandamos directo al menú. Aquí simularemos que es nuevo.
        _pasoActual = 2;
      });
    });
  }

  // 3. Simulación de guardado de perfil (Firestore)
  void _guardarPerfil() {
    if (_nombreController.text.trim().isEmpty) return;
    setState(() => _cargando = true);

    Future.delayed(const Duration(seconds: 1), () {
      setState(() => _cargando = false);
      // Redirige al menú principal y elimina la pantalla de login del historial
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const MainScreen()));
    });
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
                // Logo o Título
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: amarilloPrincipal,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.fastfood,
                    size: 60,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Todo a mil mae!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _pasoActual == 0
                      ? 'Ingresa para pedir sin complicaciones'
                      : _pasoActual == 1
                      ? 'Ingresa el código que te enviamos'
                      : '¡Casi listos! ¿Cómo te llamamos?',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // PASO 0: INGRESAR TELÉFONO
                if (_pasoActual == 0) ...[
                  TextField(
                    controller: _telefonoController,
                    keyboardType: TextInputType.phone,
                    maxLength: 8,
                    decoration: InputDecoration(
                      prefixText: '+506 ',
                      prefixStyle: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      labelText: 'Número de Teléfono',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _cargando ? null : _enviarSMS,
                      child: _cargando
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.black87,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Enviar código por SMS',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                    ),
                  ),
                ],

                // PASO 1: INGRESAR CÓDIGO SMS
                if (_pasoActual == 1) ...[
                  TextField(
                    controller: _codigoController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      letterSpacing: 8,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      hintText: '000000',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _cargando ? null : _verificarCodigo,
                      child: _cargando
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.black87,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Verificar Código',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _pasoActual = 0),
                    child: const Text(
                      'Cambiar número de teléfono',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                ],

                // PASO 2: INGRESAR NOMBRE (Usuario Nuevo)
                if (_pasoActual == 2) ...[
                  TextField(
                    controller: _nombreController,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: 'Tu Nombre (Ej. Isaac)',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: amarilloPrincipal,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _cargando ? null : _guardarPerfil,
                      child: _cargando
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.black87,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Comenzar a pedir',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
