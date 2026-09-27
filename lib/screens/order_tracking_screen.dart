// lib/screens/order_tracking_screen.dart
import 'package:flutter/material.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String tipoEntrega; // 'Express' o 'Recoger en local'
  
  const OrderTrackingScreen({super.key, this.tipoEntrega = 'Express'});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  // Simulación de lectura de Firebase: 0 = Recibido, 1 = En la plancha, 2 = Empacado, 3 = En camino/Listo
  final int _estadoActual = 1; 

  // Datos simulados de fidelidad del cliente
  final int _comprasRealizadas = 3;
  final int _metaCompras = 5;

  Widget _construirPasoTimeline(int indice, String titulo, String subtitulo, IconData icono) {
    bool pasoCompletado = _estadoActual >= indice;
    bool pasoActual = _estadoActual == indice;
    
    final Color amarilloPrincipal = const Color(0xFFE6B800);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: pasoCompletado ? amarilloPrincipal : Colors.grey[300],
                shape: BoxShape.circle,
                border: pasoActual ? Border.all(color: Colors.orange[800]!, width: 3) : null,
              ),
              child: Icon(icono, color: pasoCompletado ? Colors.black87 : Colors.grey[600], size: 20),
            ),
            if (indice < 3) // Línea conectora
              Container(
                width: 3,
                height: 50,
                color: pasoCompletado ? amarilloPrincipal : Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: pasoActual ? FontWeight.bold : FontWeight.w600,
                    color: pasoCompletado ? Colors.black87 : Colors.grey,
                  ),
                ),
                if (pasoActual) ...[
                  const SizedBox(height: 4),
                  Text(subtitulo, style: TextStyle(color: Colors.orange[800], fontSize: 14)),
                ],
                const SizedBox(height: 24), // Espaciado entre pasos
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color amarilloFondo = const Color(0xFFFFF9E6);
    final Color amarilloPrincipal = const Color(0xFFE6B800);

    String pasoFinalTitulo = widget.tipoEntrega == 'Express' ? 'En Camino' : 'Listo para Retirar';
    String pasoFinalSubtitulo = widget.tipoEntrega == 'Express' 
        ? 'El repartidor va hacia tu ubicación.' 
        : 'Puedes pasar al local por tu pedido.';

    return Scaffold(
      backgroundColor: amarilloFondo,
      appBar: AppBar(
        title: const Text('Estado de tu Pedido', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: amarilloPrincipal,
        elevation: 0,
        automaticallyImplyLeading: false, // Quita el botón de retroceso para evitar que salgan a medio proceso
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera del pedido
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: amarilloPrincipal),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Orden #1045', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('Tiempo estimado: 25 - 35 min', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  Icon(Icons.timer, color: Colors.orange, size: 30),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Línea de tiempo
            const Text('Progreso', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            
            _construirPasoTimeline(0, 'Pedido Recibido', 'La cocina ha aceptado tu orden.', Icons.receipt_long),
            _construirPasoTimeline(1, 'En la plancha', 'Tus hamburguesas y tacos se están cocinando.', Icons.outdoor_grill),
            _construirPasoTimeline(2, 'Empacado', 'Revisando que todo vaya perfecto.', Icons.takeout_dining),
            _construirPasoTimeline(3, pasoFinalTitulo, pasoFinalSubtitulo, widget.tipoEntrega == 'Express' ? Icons.motorcycle : Icons.storefront),

            const SizedBox(height: 40),

            // Tarjeta de Fidelidad (Gamificación)
            const Text('Tus Recompensas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange[100]!, Colors.orange[50]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.orange[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.star_rounded, color: Colors.orange[800], size: 28),
                      const SizedBox(width: 8),
                      Text('¡Falta poco para tu premio!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange[900])),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Llevas $_comprasRealizadas de $_metaCompras pedidos acumulados.', style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 12),
                  // Barra de progreso de estrellas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(_metaCompras, (index) {
                      return Icon(
                        Icons.star_rounded,
                        color: index < _comprasRealizadas ? Colors.orange[800] : Colors.grey[400],
                        size: 32,
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Completa las 5 estrellas y llévate un Jugo o Extra de Papas totalmente GRATIS en tu próxima compra.',
                    style: TextStyle(color: Colors.orange[900], fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}