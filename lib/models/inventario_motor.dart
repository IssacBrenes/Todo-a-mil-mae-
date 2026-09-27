// lib/models/inventario_motor.dart

class Producto {
  final String id;
  final String nombre;
  final double precioVenta;
  final bool descuentaPanYCarne; 
  final bool descuentaTacos; 
  final bool llevaGuarnicionPapas; 
  final String tipoGuarnicion; // 'hamburguesa', 'taco', o 'papas'

  Producto({
    required this.id,
    required this.nombre,
    required this.precioVenta,
    this.descuentaPanYCarne = false,
    this.descuentaTacos = false,
    this.llevaGuarnicionPapas = false,
    this.tipoGuarnicion = 'ninguna',
  });
}

class ArticuloPedido {
  final Producto producto;
  final int cantidad;
  final bool llevaExtraPapas; 
  final bool llevaSalsaExtra;
  final bool sinSalsas;
  final bool salsasAparte;
  final bool sinTomate;
  final bool sinLechuga;
  final bool sinQuesoAmarillo;
  final bool sinRepollo;
  final bool llevaJugo;

  ArticuloPedido({
    required this.producto,
    required this.cantidad,
    this.llevaExtraPapas = false,
    this.llevaSalsaExtra = false,
    this.sinSalsas = false,
    this.salsasAparte = false,
    this.sinTomate = false,
    this.sinLechuga = false,
    this.sinQuesoAmarillo = false,
    this.sinRepollo = false,
    this.llevaJugo = false,
  });
}

class MotorInventario {
  // Método estático para calcular el descuento o procesar el inventario de los ítems
  static Map<String, dynamic> calcularDescuento(List<ArticuloPedido> items) {
    int totalHamburguesas = 0;
    int totalTacos = 0;
    int totalOrdenesPapas = 0;
    int totalExtrasPapas = 0;

    for (var item in items) {
      if (item.producto.id == 'hamburguesa') {
        totalHamburguesas += item.cantidad;
      } else if (item.producto.id == 'tacos') {
        totalTacos += item.cantidad;
      } else if (item.producto.id == 'papas') {
        totalOrdenesPapas += item.cantidad;
      }

      if (item.llevaExtraPapas) {
        totalExtrasPapas += item.cantidad;
      }
    }

    // Retorna un mapa resumen listo para registrar en Firestore o consola
    return {
      'hamburguesas': totalHamburguesas,
      'tacos': totalTacos,
      'ordenesPapas': totalOrdenesPapas,
      'extrasPapas': totalExtrasPapas,
    };
  }
}