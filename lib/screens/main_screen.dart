// lib/screens/main_screen.dart
import 'package:flutter/material.dart';
import 'menu_principal.dart'; // Tu menú de siempre
import 'order_tracking_screen.dart'; // El rastreador
import 'rewards_screen.dart'; // El sistema de puntos

class MainScreen extends StatefulWidget {
  final int indiceInicial;
  
  const MainScreen({super.key, this.indiceInicial = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _indiceActual;

  @override
  void initState() {
    super.initState();
    // Permite que la app arranque en la pestaña que le digamos (Ej: Menú = 0, Pedidos = 1)
    _indiceActual = widget.indiceInicial;
  }

  // Lista de las 3 pantallas que rotarán en el centro
  final List<Widget> _pantallas = [
    const MenuPrincipal(), 
    const OrderTrackingScreen(),
    const RewardsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack mantiene vivas las pantallas en memoria para que no recarguen al cambiar de pestaña
      body: IndexedStack(
        index: _indiceActual,
        children: _pantallas,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _indiceActual,
          onTap: (index) {
            setState(() {
              _indiceActual = index;
            });
          },
          backgroundColor: Colors.white,
          selectedItemColor: Colors.orange[800],
          unselectedItemColor: Colors.grey[500],
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
          type: BottomNavigationBarType.fixed, // Evita que los íconos salten al presionarlos
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.fastfood),
              activeIcon: Icon(Icons.fastfood, size: 28),
              label: 'Menú',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long),
              activeIcon: Icon(Icons.receipt_long, size: 28),
              label: 'Pedidos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.stars),
              activeIcon: Icon(Icons.stars, size: 28),
              label: 'Recompensas',
            ),
          ],
        ),
      ),
    );
  }
}