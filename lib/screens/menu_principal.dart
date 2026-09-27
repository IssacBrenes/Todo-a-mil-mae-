// lib/screens/menu_principal.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/carrito_provider.dart';
import '../models/inventario_motor.dart';
import 'checkout_screen.dart';
import '../models/configuracion_local.dart';

class MenuPrincipal extends StatelessWidget {
  const MenuPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    final carrito = Provider.of<CarritoProvider>(context);

    // Definición de colores basados en tonos amarillos pastel y cálidos
    final Color amarilloFondo = const Color(
      0xFFFFF9E6,
    ); // Amarillo pastel muy suave
    final Color amarilloCard = const Color(
      0xFFFFF2CC,
    ); // Amarillo pastel claro para tarjetas
    final Color amarilloPrincipal = const Color(
      0xFFE6B800,
    ); // Tono acentuado para títulos y botones

    return Scaffold(
      backgroundColor: amarilloFondo,
      appBar: AppBar(
        title: const Text(
          'Todo a mil mae!',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: amarilloCard,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: const Row(
              children: [
                Icon(Icons.circle, color: Colors.green, size: 12),
                SizedBox(width: 8),
                Text(
                  'Abierto',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 1. PRIMERO LOS PLATILLOS PRINCIPALES
          const Text(
            'Platos Principales 🍔',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          TarjetaProducto(
            nombre: 'Hamburguesa Sencilla',
            precio: '₡1000',
            descripcion: 'Incluye guarnición de papas (pasiva)',
            colorFondo: amarilloCard,
            colorBorde: amarilloPrincipal,
            onTap: () => _mostrarPersonalizacion(
              context,
              Producto(
                id: 'hamburguesa',
                nombre: 'Hamburguesa Sencilla',
                precioVenta: 1000,
                descuentaPanYCarne: true,
                llevaGuarnicionPapas: true,
                tipoGuarnicion: 'hamburguesa',
              ),
            ),
          ),
          TarjetaProducto(
            nombre: 'Orden de Tacos',
            precio: '₡1000',
            descripcion: '2 taquitos con guarnición de papas',
            colorFondo: amarilloCard,
            colorBorde: amarilloPrincipal,
            onTap: () => _mostrarPersonalizacion(
              context,
              Producto(
                id: 'tacos',
                nombre: 'Orden de Tacos',
                precioVenta: 1000,
                descuentaTacos: true,
                llevaGuarnicionPapas: true,
                tipoGuarnicion: 'taco',
              ),
            ),
          ),
          TarjetaProducto(
            nombre: 'Orden de Papas',
            precio: '₡1000',
            descripcion: 'Porción completa de papas fritas',
            colorFondo: amarilloCard,
            colorBorde: amarilloPrincipal,
            onTap: () => _mostrarPersonalizacion(
              context,
              Producto(
                id: 'papas',
                nombre: 'Orden de Papas',
                precioVenta: 1000,
                tipoGuarnicion: 'papas',
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 2. SEGUNDO LAS BEBIDAS Y FRESCOS
          const Text(
            'Para acompañar 🍻',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                TarjetaRecomendado(
                  nombre: 'Cerveza Fria',
                  precio: '₡1200',
                  icono: Icons.sports_bar,
                  colorTarjeta: amarilloCard,
                  onTap: () {
                    carrito.agregarArticuloPersonalizado(
                      ArticuloPedido(
                        producto: Producto(
                          id: 'cerveza',
                          nombre: 'Cerveza Fria',
                          precioVenta: 1200,
                        ),
                        cantidad: 1,
                      ),
                    );
                    _mostrarMensaje(context, '¡Cerveza agregada!');
                  },
                ),
                TarjetaRecomendado(
                  nombre: 'Coca Cola 600ml',
                  precio: '₡1000',
                  icono: Icons.local_drink,
                  colorTarjeta: amarilloCard,
                  onTap: () {
                    carrito.agregarArticuloPersonalizado(
                      ArticuloPedido(
                        producto: Producto(
                          id: 'coca',
                          nombre: 'Coca Cola 600ml',
                          precioVenta: 1000,
                        ),
                        cantidad: 1,
                      ),
                    );
                    _mostrarMensaje(context, '¡Coca Cola agregada!');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: amarilloPrincipal,
        onPressed: () => _mostrarResumenCarrito(context),
        icon: const Icon(Icons.shopping_cart, color: Colors.black87),
        label: Text(
          'Ver Carrito (₡${carrito.calcularTotal().toStringAsFixed(0)})',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _mostrarMensaje(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), duration: const Duration(seconds: 1)),
    );
  }

  void _mostrarPersonalizacion(
    BuildContext context,
    Producto producto, {
    ArticuloPedido? itemAEditar,
    int? indexEdicion,
  }) {
    // 1. Inicializamos los valores basados en el artículo a editar, o en falso si es uno nuevo
    bool llevaExtraPapas = itemAEditar?.llevaExtraPapas ?? false;
    bool llevaSalsaExtra = itemAEditar?.llevaSalsaExtra ?? false;
    bool sinSalsas = itemAEditar?.sinSalsas ?? false;
    bool salsasAparte = itemAEditar?.salsasAparte ?? false;
    bool sinTomate = itemAEditar?.sinTomate ?? false;
    bool sinLechuga = itemAEditar?.sinLechuga ?? false;
    bool sinQueso = itemAEditar?.sinQuesoAmarillo ?? false;
    bool sinRepollo = itemAEditar?.sinRepollo ?? false;
    bool llevaJugo = itemAEditar?.llevaJugo ?? false;

    final carrito = Provider.of<CarritoProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            // Calculamos el precio dinámicamente según lo que se marque
            double precioActual = producto.precioVenta;
            if (llevaExtraPapas) precioActual += 500;
            if (llevaSalsaExtra) precioActual += 200;
            if (llevaJugo) precioActual += 500;

            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      indexEdicion != null
                          ? 'Editando: ${producto.nombre}'
                          : 'Personalizar: ${producto.nombre}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- OPCIONES EXCLUSIVAS PARA PAPAS ---
                    if (producto.tipoGuarnicion == 'papas' ||
                        producto.id == 'papas') ...[
                      CheckboxListTile(
                        title: const Text('Extra de Papas (+₡500)'),
                        value: llevaExtraPapas,
                        activeColor: Colors.orange[800],
                        onChanged: (val) =>
                            setState(() => llevaExtraPapas = val ?? false),
                      ),
                      CheckboxListTile(
                        title: const Text('Salsa Extra (+₡200)'),
                        value: llevaSalsaExtra,
                        activeColor: Colors.orange[800],
                        onChanged: (val) =>
                            setState(() => llevaSalsaExtra = val ?? false),
                      ),
                      const Divider(),
                      CheckboxListTile(
                        title: const Text('Sin Salsas'),
                        value: sinSalsas,
                        activeColor: Colors.orange[800],
                        onChanged: (val) =>
                            setState(() => sinSalsas = val ?? false),
                      ),
                      CheckboxListTile(
                        title: const Text('Salsas Aparte'),
                        value: salsasAparte,
                        activeColor: Colors.orange[800],
                        onChanged: (val) =>
                            setState(() => salsasAparte = val ?? false),
                      ),
                    ],

                    // --- OPCIONES EXCLUSIVAS PARA HAMBURGUESA ---
                    if (producto.id == 'hamburguesa') ...[
                      CheckboxListTile(
                        title: const Text('Extra de Papas (+₡500)'),
                        value: llevaExtraPapas,
                        activeColor: Colors.orange[800],
                        onChanged: (val) =>
                            setState(() => llevaExtraPapas = val ?? false),
                      ),
                      const Divider(),
                      const Text(
                        'Retirar ingredientes:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      CheckboxListTile(
                        title: const Text('Sin Tomate'),
                        value: sinTomate,
                        activeColor: Colors.orange[800],
                        onChanged: (val) =>
                            setState(() => sinTomate = val ?? false),
                      ),
                      CheckboxListTile(
                        title: const Text('Sin Lechuga'),
                        value: sinLechuga,
                        activeColor: Colors.orange[800],
                        onChanged: (val) =>
                            setState(() => sinLechuga = val ?? false),
                      ),
                      CheckboxListTile(
                        title: const Text('Sin Queso Amarillo'),
                        value: sinQueso,
                        activeColor: Colors.orange[800],
                        onChanged: (val) =>
                            setState(() => sinQueso = val ?? false),
                      ),
                    ],

                    // --- OPCIONES EXCLUSIVAS PARA TACOS ---
                    if (producto.id == 'tacos') ...[
                      CheckboxListTile(
                        title: const Text('Extra de Papas (+₡500)'),
                        value: llevaExtraPapas,
                        activeColor: Colors.orange[800],
                        onChanged: (val) =>
                            setState(() => llevaExtraPapas = val ?? false),
                      ),
                      const Divider(),
                      CheckboxListTile(
                        title: const Text('Sin Repollo'),
                        value: sinRepollo,
                        activeColor: Colors.orange[800],
                        onChanged: (val) =>
                            setState(() => sinRepollo = val ?? false),
                      ),
                      CheckboxListTile(
                        title: const Text('Sin Salsas'),
                        value: sinSalsas,
                        activeColor: Colors.orange[800],
                        onChanged: (val) =>
                            setState(() => sinSalsas = val ?? false),
                      ),
                      CheckboxListTile(
                        title: const Text('Salsas Aparte'),
                        value: salsasAparte,
                        activeColor: Colors.orange[800],
                        onChanged: (val) =>
                            setState(() => salsasAparte = val ?? false),
                      ),
                    ],
                    const Divider(),
                    const Text(
                      'Bebida',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    CheckboxListTile(
                      title: const Text('Añadir Jugo (+₡500)'),
                      value: llevaJugo,
                      activeColor: Colors.orange[800],
                      onChanged: (val) =>
                          setState(() => llevaJugo = val ?? false),
                    ),

                    const SizedBox(height: 20),
                    // BOTÓN DE CONFIRMACIÓN / ACTUALIZACIÓN
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE6B800),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        // Dentro de _mostrarPersonalizacion, en el onPressed del ElevatedButton de confirmar:

                        onPressed: () {
                          // 1. Armamos el artículo
                          final articuloModificado = ArticuloPedido(
                            producto: producto,
                            cantidad: itemAEditar?.cantidad ?? 1,
                            llevaExtraPapas: llevaExtraPapas,
                            llevaSalsaExtra: llevaSalsaExtra,
                            sinSalsas: sinSalsas,
                            salsasAparte: salsasAparte,
                            sinTomate: sinTomate,
                            sinLechuga: sinLechuga,
                            sinQuesoAmarillo: sinQueso,
                            sinRepollo: sinRepollo,
                            llevaJugo: llevaJugo,
                          );

                          // 2. Lo agregamos o actualizamos en el carrito
                          if (indexEdicion != null) {
                            carrito.actualizarItem(
                              indexEdicion,
                              articuloModificado,
                            );
                          } else {
                            carrito.agregarArticuloPersonalizado(
                              articuloModificado,
                            );
                          }

                          // 3. Cerramos el Bottom Sheet
                          Navigator.pop(context);

                          // 4. LECTURA DE CONFIGURACIÓN Y ANUNCIO FLOTANTE (NUEVO)
                          // Simulamos la lectura de la base de datos
                          // LECTURA DE CONFIGURACIÓN Y ANUNCIO FLOTANTE CENTRAL
                          // 4. LECTURA DE CONFIGURACIÓN Y ANUNCIO FLOTANTE CENTRAL
                          final config = ConfiguracionLocal();

                          if (config.estadoExpress == 'Condicionado' &&
                              carrito.calcularTotal() <
                                  config.compraMinimaExpress) {
                            showDialog(
                              context: context,
                              barrierDismissible: false, // Evita que se cierre si tocan fuera del recuadro por error
                              builder: (context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.info_outline,
                                        color: Colors.orange,
                                        size: 50,
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Aviso Express',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        config.mensajeCondicionado,
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(); // Cierra el mensaje solo cuando el usuario lo decide
                                      },
                                      child: const Text(
                                        'Entendido',
                                        style: TextStyle(
                                          color: Colors.orange,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            // Mensaje normal de éxito
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '¡${producto.nombre} agregado al pedido!',
                                ),
                                backgroundColor: Colors.green,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        child: Text(
                          indexEdicion != null
                              ? 'Guardar Cambios (₡${precioActual.toStringAsFixed(0)})'
                              : 'Añadir al Pedido (₡${precioActual.toStringAsFixed(0)})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _mostrarResumenCarrito(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Consumer<CarritoProvider>(
          builder: (context, carrito, child) {
            return Container(
              padding: const EdgeInsets.all(20),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resumen del Pedido',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  Expanded(
                    child: carrito.items.isEmpty
                        ? const Center(
                            child: Text(
                              'El carrito está vacío',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: carrito.items.length,
                            itemBuilder: (context, index) {
                              final item = carrito.items[index];
                              double precioItem = item.producto.precioVenta;
                              if (item.llevaExtraPapas) precioItem += 500;
                              if (item.llevaSalsaExtra) precioItem += 200;

                              List<String> detalles = [];
                              if (item.llevaExtraPapas)
                                detalles.add('Extra Papas (+₡500)');
                              if (item.llevaSalsaExtra)
                                detalles.add('Salsa Extra (+₡200)');
                              if (item.sinSalsas) detalles.add('Sin Salsas');
                              if (item.salsasAparte)
                                detalles.add('Salsas Aparte');
                              if (item.sinTomate) detalles.add('Sin Tomate');
                              if (item.sinLechuga) detalles.add('Sin Lechuga');
                              if (item.sinQuesoAmarillo)
                                detalles.add('Sin Queso');
                              if (item.sinRepollo) detalles.add('Sin Repollo');
                              if (item.llevaJugo)
                                detalles.add('Con Jugo (+₡500)');

                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                child: ListTile(
                                  title: Text(
                                    item.producto.nombre,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (detalles.isNotEmpty)
                                        Text(
                                          detalles.join(' • '),
                                          style: const TextStyle(
                                            color: Colors.orange,
                                            fontSize: 12,
                                          ),
                                        ),
                                      Text(
                                        'Cantidad: ${item.cantidad}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '₡${(precioItem * item.cantidad).toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      // Botón para editar
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          Navigator.pop(
                                            context,
                                          ); // Cierra el carrito temporalmente
                                          _mostrarPersonalizacion(
                                            context,
                                            item.producto,
                                            itemAEditar: item,
                                            indexEdicion: index,
                                          );
                                        },
                                      ),
                                      // Botón para eliminar
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          carrito.removerItem(index);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '₡${carrito.calcularTotal().toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE6B800),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: carrito.items.isEmpty
                          ? null
                          : () {
                              Navigator.pop(
                                context,
                              ); // Cierra el bottom sheet del carrito
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CheckoutScreen(),
                                ), // Dirige al formulario de Checkout
                              );
                            },
                      child: const Text(
                        'Proceder al Checkout',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class TarjetaRecomendado extends StatelessWidget {
  final String nombre;
  final String precio;
  final IconData icono;
  final Color colorTarjeta;
  final VoidCallback onTap;

  const TarjetaRecomendado({
    super.key,
    required this.nombre,
    required this.precio,
    required this.icono,
    required this.colorTarjeta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: colorTarjeta,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, size: 48, color: Colors.orange[800]),
            const SizedBox(height: 12),
            Text(
              nombre,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              precio,
              style: TextStyle(
                color: Colors.orange[900],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TarjetaProducto extends StatelessWidget {
  final String nombre;
  final String precio;
  final String descripcion;
  final Color colorFondo;
  final Color colorBorde;
  final VoidCallback onTap;

  const TarjetaProducto({
    super.key,
    required this.nombre,
    required this.precio,
    required this.descripcion,
    required this.colorFondo,
    required this.colorBorde,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: colorFondo,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          nombre,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(descripcion),
        trailing: Text(
          precio,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
