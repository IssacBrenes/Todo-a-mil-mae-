// lib/screens/rewards_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/carrito_provider.dart';
import '../models/inventario_motor.dart'; // Necesario para agregar el producto

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  final int _puntosActuales = 14; 
  int? _recompensaSeleccionada; // Guarda el índice de la recompensa marcada

  final List<Map<String, dynamic>> _catalogoRecompensas = [
    {'titulo': 'Jugo Gratis', 'puntos': 5, 'icono': Icons.local_drink},
    {'titulo': 'Extra de Papas', 'puntos': 7, 'icono': Icons.add_circle_outline},
    {'titulo': 'Orden de Papas', 'puntos': 12, 'icono': Icons.takeout_dining},
    {'titulo': 'Hamburguesa o Taco', 'puntos': 16, 'icono': Icons.fastfood},
    {'titulo': 'Hamburguesa/Taco + Extra Papas', 'puntos': 20, 'icono': Icons.star},
  ];

  @override
  Widget build(BuildContext context) {
    final carrito = Provider.of<CarritoProvider>(context);
    final bool carritoVacio = carrito.items.isEmpty;

    final Color amarilloFondo = const Color(0xFFFFF9E6);
    final Color amarilloPrincipal = const Color(0xFFE6B800);

    return Scaffold(
      backgroundColor: amarilloFondo,
      appBar: AppBar(
        title: const Text('Tus Recompensas', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: amarilloPrincipal,
        elevation: 0,
        automaticallyImplyLeading: false, // Oculta el botón de retroceso para mantener la barra anclada
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange[400]!, Colors.orange[800]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
              ],
            ),
            child: Column(
              children: [
                const Text('Puntos Acumulados', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(
                  '$_puntosActuales',
                  style: const TextStyle(color: Colors.white, fontSize: 60, fontWeight: FontWeight.bold, height: 1),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                  child: const Text('1 pts (₡1k-₡3k) | 2 pts (₡3k+) | 3 pts (₡5k+)', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _catalogoRecompensas.length,
              itemBuilder: (context, index) {
                final recompensa = _catalogoRecompensas[index];
                final bool alcanza = _puntosActuales >= recompensa['puntos'];
                final bool estaSeleccionada = _recompensaSeleccionada == index;

                return GestureDetector(
                  onTap: alcanza ? () {
                    setState(() {
                      // Si ya estaba seleccionada, la desmarca. Si no, la marca.
                      _recompensaSeleccionada = estaSeleccionada ? null : index;
                    });
                  } : null,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: estaSeleccionada ? Colors.orange[50] : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: estaSeleccionada ? Colors.orange : (alcanza ? amarilloPrincipal : Colors.grey[300]!), 
                        width: estaSeleccionada ? 3 : 2
                      ),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: alcanza ? amarilloFondo : Colors.grey[200],
                        child: Icon(recompensa['icono'], color: alcanza ? Colors.orange[800] : Colors.grey),
                      ),
                      title: Text(recompensa['titulo'], style: TextStyle(fontWeight: FontWeight.bold, color: alcanza ? Colors.black87 : Colors.grey)),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: alcanza ? Colors.green[100] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${recompensa['puntos']} pts',
                          style: TextStyle(fontWeight: FontWeight.bold, color: alcanza ? Colors.green[800] : Colors.grey[600]),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: carritoVacio ? Colors.grey[300] : amarilloPrincipal,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                if (carritoVacio) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Las recompensas solo pueden ser utilizadas durante una compra. ¡Añade un platillo al carrito primero!'),
                      backgroundColor: Colors.orange,
                      duration: Duration(seconds: 3),
                    ),
                  );
                } else if (_recompensaSeleccionada == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Toca una de las recompensas desbloqueadas para seleccionarla.'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                } else {
                  // Inyecta el premio al carrito a costo 0
                  final premio = _catalogoRecompensas[_recompensaSeleccionada!];
                  carrito.agregarArticuloPersonalizado(ArticuloPedido(
                    producto: Producto(
                      id: 'recompensa_${premio['titulo']}',
                      nombre: '🎁 ${premio['titulo']} (Recompensa)',
                      precioVenta: 0.0, // Costo cero para el cliente
                    ),
                    cantidad: 1,
                  ));

                  setState(() => _recompensaSeleccionada = null); // Limpia la selección
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('¡${premio['titulo']} añadido a tu carrito gratis!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: Text(
                'Añadir al pedido',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: carritoVacio ? Colors.grey[600] : Colors.black87,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}