// lib/models/configuracion_local.dart

class ZonaExpress {
  final String nombre;
  final double tarifa;

  const ZonaExpress({required this.nombre, required this.tarifa});
}

class ConfiguracionLocal {
  final String estadoCocina; 
  final String estadoExpress; 
  final String mensajeCondicionado; 
  final double compraMinimaExpress;
  final List<ZonaExpress> zonas;

  ConfiguracionLocal({
    this.estadoCocina = 'Abierto',
    this.estadoExpress = 'Condicionado', 
    this.mensajeCondicionado = 'Para que el express sea GRATIS, tu pedido debe ser de al menos ₡2000. De lo contrario, se cobrará la tarifa regular según tu zona.',
    this.compraMinimaExpress = 2000.0,
    this.zonas = const [
      ZonaExpress(nombre: 'Centro', tarifa: 1000.0),
      ZonaExpress(nombre: 'Norte', tarifa: 1500.0),
      ZonaExpress(nombre: 'Sur', tarifa: 1500.0),
    ],
  });
}