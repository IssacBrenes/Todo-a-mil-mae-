// lib/providers/carrito_provider.dart
import 'package:flutter/foundation.dart';

import '../models/inventario_motor.dart';

class CarritoProvider with ChangeNotifier {
  final List<ArticuloPedido> _items = [];

  List<ArticuloPedido> get items => _items;

  // Añade un artículo personalizado al carrito
  void agregarArticuloPersonalizado(ArticuloPedido articulo) {
    _items.add(articulo);
    notifyListeners();
  }

  // Actualizar un artículo existente en el carrito por su índice (¡Este faltaba!)
  void actualizarItem(int index, ArticuloPedido articulo) {
    if (index >= 0 && index < _items.length) {
      _items[index] = articulo;
      notifyListeners();
    }
  }

  // Eliminar un artículo específico del carrito por su índice
  void removerItem(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  // Limpia el carrito al finalizar o cancelar la orden
  void limpiarCarrito() {
    _items.clear();
    notifyListeners();
  }

  // Calcula el total en colones sumando extras y salsas extra
  double calcularTotal() {
    double total = 0;
    for (var item in _items) {
      double precioBase = item.producto.precioVenta;
      if (item.llevaExtraPapas) {
        precioBase += 500.0; // Extra de papas
      }
      if (item.llevaSalsaExtra) {
        precioBase += 200.0; // Salsa extra para papas
      }

      if (item.llevaJugo) precioBase += 500.0;

      total += precioBase * item.cantidad;
    }
    return total;
  }
}
