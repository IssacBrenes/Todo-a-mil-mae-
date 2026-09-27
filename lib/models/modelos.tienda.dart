// lib/models/modelos_tienda.dart

class Producto {
  String id;
  String nombre;
  double precioVenta;
  bool descuentaPanYCarne; 
  bool descuentaTacos; // Para descontar las 2 unidades por orden
  bool llevaGuarnicionPapas; 
  String tipoGuarnicion; // 'hamburguesa' (~7 papas) o 'taco' (2-3 puñitos)

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
  Producto producto;
  int cantidad;
  bool llevaExtraPapas; // Añade el valor del extra (₡500)

  ArticuloPedido({
    required this.producto,
    required this.cantidad,
    this.llevaExtraPapas = false,
  });
}

class MotorInventario {
  // Constantes de consumo de papas (en gramos)
  static const double gramosBolsa = 2500.0;
  static const double gramosGuarnicionHamburguesa = 40.0; // ~7 papas
  static const double gramosGuarnicionTaco = 80.0; // 2 a 3 puñitos
  static const double gramosExtraPapas = 240.0; // ~3 puñitos (extra de ₡500)
  static const double gramosOrdenCompleta = 480.0; // Doble del extra (platillo ₡1000)

  // Método que procesa un ticket finalizado
  static Map<String, double> calcularDescuento(List<ArticuloPedido> carrito) {
    double descuentoHamburguesas = 0;
    double descuentoTaquitos = 0; // Se restan por unidades individuales
    double descuentoPapasGramos = 0;
    
    for (var articulo in carrito) {
      // 1. Descuento de productos principales
      if (articulo.producto.descuentaPanYCarne) {
        descuentoHamburguesas += articulo.cantidad;
      }
      if (articulo.producto.descuentaTacos) {
        descuentoTaquitos += (2 * articulo.cantidad); // 2 taquitos por orden
      }

      // 2. Descuento Pasivo de Papas (Guarniciones incluidas)
      if (articulo.producto.llevaGuarnicionPapas) {
        if (articulo.producto.tipoGuarnicion == 'hamburguesa') {
          descuentoPapasGramos += (gramosGuarnicionHamburguesa * articulo.cantidad);
        } else if (articulo.producto.tipoGuarnicion == 'taco') {
          descuentoPapasGramos += (gramosGuarnicionTaco * articulo.cantidad);
        }
      }

      // 3. Descuento Activo de Papas (El cliente pagó por papas)
      if (articulo.llevaExtraPapas) {
        descuentoPapasGramos += (gramosExtraPapas * articulo.cantidad);
      }
      if (articulo.producto.nombre == 'Orden de Papas') {
        descuentoPapasGramos += (gramosOrdenCompleta * articulo.cantidad);
      }
    }

    // Retorna el total a restar en Firebase
    return {
      'hamburguesas_a_restar': descuentoHamburguesas,
      'taquitos_a_restar': descuentoTaquitos,
      'gramos_papas_a_restar': descuentoPapasGramos,
    };
  }
}