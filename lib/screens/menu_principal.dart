// lib/screens/menu_principal.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 

import '../providers/carrito_provider.dart';
import '../models/inventario_motor.dart';
import 'checkout_screen.dart';
import '../models/configuracion_local.dart';

class MenuPrincipal extends StatelessWidget {
  const MenuPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    final carrito = Provider.of<CarritoProvider>(context);

    final Color amarilloFondo = const Color(0xFFFFF9E6);
    final Color amarilloCard = const Color(0xFFFFF2CC);
    final Color amarilloPrincipal = const Color(0xFFE6B800);

    return Scaffold(
      backgroundColor: amarilloFondo,
      appBar: AppBar(
        title: const Text('Todo a mil mae!', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: amarilloCard,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: const Row(
              children: [
                Icon(Icons.circle, color: Colors.green, size: 12),
                SizedBox(width: 8),
                Text('Abierto', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('productos').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.orange));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('El menú está vacío', style: TextStyle(fontSize: 18)));
          }

          final docs = snapshot.data!.docs;
          
          final principales = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final categoria = data['categoria']?.toString().toLowerCase().trim() ?? '';
            return categoria == 'comida';
          }).toList();

          // NUEVO: Ordenamiento estricto (1. Hamburguesa, 2. Taco, 3. Papas)
          principales.sort((a, b) {
            final idA = a.id.toLowerCase();
            final idB = b.id.toLowerCase();
            
            int pesoA = idA.contains('hamburguesa') ? 1 : idA.contains('taco') ? 2 : 3;
            int pesoB = idB.contains('hamburguesa') ? 1 : idB.contains('taco') ? 2 : 3;
            
            return pesoA.compareTo(pesoB);
          });

          final bebidas = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final categoria = data['categoria']?.toString().toLowerCase().trim() ?? '';
            return categoria == 'bebida';
          }).toList();

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const Text('Platos Principales 🍔', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 12),
              
              ...principales.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                // Convertimos el ID a minúsculas para atrapar singular o plural
                final id = doc.id.toLowerCase(); 
                
                // Lector de nombres blindado con valores por defecto inteligentes
                String nombre = data['nombre'] ?? data['Nombre'] ?? '';
                if (nombre.isEmpty) {
                  if (id.contains('papa')) nombre = 'Orden de Papas';
                  else if (id.contains('taco')) nombre = 'Orden de Tacos';
                  else if (id.contains('hamburguesa')) nombre = 'Hamburguesa Sencilla';
                  else nombre = 'Producto';
                }
                
                // Lector de precio ultra-robusto (convierte TODO a texto primero y luego a número)
                double precio = 0;
                final rawPrecio = data['precio'] ?? data['Precio'];
                if (rawPrecio != null) {
                  precio = double.tryParse(rawPrecio.toString()) ?? 0.0;
                }

                // Lector de descripción blindado
                String descripcion = data['descripcion'] ?? data['Descripcion'] ?? '';
                if (descripcion.isEmpty) {
                  if (id.contains('hamburguesa')) descripcion = 'Incluye guarnición de papas';
                  else if (id.contains('taco')) descripcion = '2 taquitos con repollo y papas';
                  else if (id.contains('papa')) descripcion = 'Porción completa de papas fritas';
                  else descripcion = '¡Delicioso!';
                }

                final stock = (data['stock'] ?? 0).toInt();
                final bool agotado = stock <= 0;

                bool descuentaPanYCarne = false;
                bool descuentaTacos = false;
                bool llevaGuarnicionPapas = false;
                String tipoGuarnicion = 'ninguna';

                // Asignación de reglas de negocio usando .contains() para ignorar si es plural o singular
                if (id.contains('hamburguesa')) {
                  descuentaPanYCarne = true;
                  llevaGuarnicionPapas = true;
                  tipoGuarnicion = 'hamburguesa';
                } else if (id.contains('taco')) {
                  descuentaTacos = true;
                  llevaGuarnicionPapas = true;
                  tipoGuarnicion = 'taco';
                } else if (id.contains('papa')) {
                  tipoGuarnicion = 'papas';
                }

                return TarjetaProducto(
                  nombre: nombre,
                  precio: '₡${precio.toInt()}',
                  descripcion: descripcion,
                  colorFondo: agotado ? Colors.grey[300]! : amarilloCard,
                  colorBorde: agotado ? Colors.grey : amarilloPrincipal,
                  agotado: agotado,
                  onTap: agotado ? () {} : () => _mostrarPersonalizacion(
                    context,
                    Producto(
                      id: id,
                      nombre: nombre,
                      precioVenta: precio,
                      descuentaPanYCarne: descuentaPanYCarne,
                      descuentaTacos: descuentaTacos,
                      llevaGuarnicionPapas: llevaGuarnicionPapas,
                      tipoGuarnicion: tipoGuarnicion,
                    ),
                  ),
                );
              }),

              const SizedBox(height: 24),

              const Text('Para acompañar 🍻', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 12),
              SizedBox(
                height: 170, 
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: bebidas.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final id = doc.id.toLowerCase();
                    
                    String nombre = data['nombre'] ?? data['Nombre'] ?? '';
                    if (nombre.isEmpty) {
                      if (id.contains('fresco') || id.contains('jugo')) nombre = 'Fresco Natural';
                      else nombre = 'Bebida';
                    }
                    
                    double precio = 0;
                    final rawPrecio = data['precio'] ?? data['Precio'];
                    if (rawPrecio != null) {
                      precio = double.tryParse(rawPrecio.toString()) ?? 0.0;
                    }

                    final stock = (data['stock'] ?? 0).toInt();
                    final bool agotado = stock <= 0;

                    IconData icono = Icons.local_drink;
                    if (id.contains('cerveza')) icono = Icons.sports_bar;

                    return TarjetaRecomendado(
                      nombre: nombre,
                      precio: '₡${precio.toInt()}',
                      icono: icono,
                      colorTarjeta: agotado ? Colors.grey[300]! : amarilloCard,
                      agotado: agotado,
                      onTap: agotado ? () {} : () {
                        carrito.agregarArticuloPersonalizado(
                          ArticuloPedido(
                            producto: Producto(id: id, nombre: nombre, precioVenta: precio),
                            cantidad: 1,
                          ),
                        );
                        _mostrarMensaje(context, '¡$nombre agregada!');
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: amarilloPrincipal,
        onPressed: () => _mostrarResumenCarrito(context),
        icon: const Icon(Icons.shopping_cart, color: Colors.black87),
        label: Text(
          'Ver Carrito (₡${carrito.calcularTotal().toStringAsFixed(0)})',
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _mostrarMensaje(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), duration: const Duration(seconds: 1)),
    );
  }

  void _mostrarPersonalizacion(BuildContext context, Producto producto, {ArticuloPedido? itemAEditar, int? indexEdicion}) {
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
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
                      indexEdicion != null ? 'Editando: ${producto.nombre}' : 'Personalizar: ${producto.nombre}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    // Opciones restauradas con .contains() para ignorar singular/plural
                    if (producto.tipoGuarnicion == 'papas' || producto.id.contains('papa')) ...[
                      CheckboxListTile(title: const Text('Extra de Papas (+₡500)'), value: llevaExtraPapas, activeColor: Colors.orange[800], onChanged: (val) => setState(() => llevaExtraPapas = val ?? false)),
                      CheckboxListTile(title: const Text('Salsa Extra (+₡200)'), value: llevaSalsaExtra, activeColor: Colors.orange[800], onChanged: (val) => setState(() => llevaSalsaExtra = val ?? false)),
                      const Divider(),
                      CheckboxListTile(title: const Text('Sin Salsas'), value: sinSalsas, activeColor: Colors.orange[800], onChanged: (val) => setState(() => sinSalsas = val ?? false)),
                      CheckboxListTile(title: const Text('Salsas Aparte'), value: salsasAparte, activeColor: Colors.orange[800], onChanged: (val) => setState(() => salsasAparte = val ?? false)),
                    ],

                    if (producto.id.contains('hamburguesa')) ...[
                      CheckboxListTile(title: const Text('Extra de Papas (+₡500)'), value: llevaExtraPapas, activeColor: Colors.orange[800], onChanged: (val) => setState(() => llevaExtraPapas = val ?? false)),
                      const Divider(),
                      const Text('Retirar ingredientes:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      CheckboxListTile(title: const Text('Sin Tomate'), value: sinTomate, activeColor: Colors.orange[800], onChanged: (val) => setState(() => sinTomate = val ?? false)),
                      CheckboxListTile(title: const Text('Sin Lechuga'), value: sinLechuga, activeColor: Colors.orange[800], onChanged: (val) => setState(() => sinLechuga = val ?? false)),
                      CheckboxListTile(title: const Text('Sin Queso Amarillo'), value: sinQueso, activeColor: Colors.orange[800], onChanged: (val) => setState(() => sinQueso = val ?? false)),
                    ],

                    if (producto.id.contains('taco')) ...[
                      CheckboxListTile(title: const Text('Extra de Papas (+₡500)'), value: llevaExtraPapas, activeColor: Colors.orange[800], onChanged: (val) => setState(() => llevaExtraPapas = val ?? false)),
                      const Divider(),
                      CheckboxListTile(title: const Text('Sin Repollo'), value: sinRepollo, activeColor: Colors.orange[800], onChanged: (val) => setState(() => sinRepollo = val ?? false)),
                      CheckboxListTile(title: const Text('Sin Salsas'), value: sinSalsas, activeColor: Colors.orange[800], onChanged: (val) => setState(() => sinSalsas = val ?? false)),
                      CheckboxListTile(title: const Text('Salsas Aparte'), value: salsasAparte, activeColor: Colors.orange[800], onChanged: (val) => setState(() => salsasAparte = val ?? false)),
                    ],
                    
                    const Divider(),
                    const Text('Bebida', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                    CheckboxListTile(title: const Text('Añadir Jugo (+₡500)'), value: llevaJugo, activeColor: Colors.orange[800], onChanged: (val) => setState(() => llevaJugo = val ?? false)),

                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE6B800),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          // 1. Armamos el artículo modificado
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

                          if (indexEdicion != null) {
                            // FLUJO DE EDICIÓN
                            carrito.actualizarItem(indexEdicion, articuloModificado);
                            Navigator.pop(context); // Cierra la pestaña de personalización
                            _mostrarResumenCarrito(context); // Vuelve a abrir el carrito de compras
                          } else {
                            // FLUJO DE PRODUCTO NUEVO
                            carrito.agregarArticuloPersonalizado(articuloModificado);
                            Navigator.pop(context); // Cierra la pestaña de personalización

                            // Verifica alertas Express o muestra el Snackbar de éxito
                            final config = ConfiguracionLocal();
                            if (config.estadoExpress == 'Condicionado' && carrito.calcularTotal() < config.compraMinimaExpress) {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.info_outline, color: Colors.orange, size: 50),
                                        const SizedBox(height: 16),
                                        const Text('Aviso Express', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                        const SizedBox(height: 8),
                                        Text(config.mensajeCondicionado, textAlign: TextAlign.center),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: const Text('Entendido', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 16)),
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('¡${producto.nombre} agregado al pedido!'), 
                                  backgroundColor: Colors.green, 
                                  duration: const Duration(seconds: 2)
                                )
                              );
                            }
                          }
                        },
                        child: Text(
                          indexEdicion != null ? 'Guardar Cambios (₡${precioActual.toStringAsFixed(0)})' : 'Añadir al Pedido (₡${precioActual.toStringAsFixed(0)})',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        return Consumer<CarritoProvider>(
          builder: (context, carrito, child) {
            return Container(
              padding: const EdgeInsets.all(20),
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Resumen del Pedido', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const Divider(),
                  Expanded(
                    child: carrito.items.isEmpty
                        ? const Center(child: Text('El carrito está vacío', style: TextStyle(color: Colors.grey, fontSize: 16)))
                        : ListView.builder(
                            itemCount: carrito.items.length,
                            itemBuilder: (context, index) {
                              final item = carrito.items[index];
                              double precioItem = item.producto.precioVenta;
                              if (item.llevaExtraPapas) precioItem += 500;
                              if (item.llevaSalsaExtra) precioItem += 200;
                              if (item.llevaJugo) precioItem += 500; // ¡Esta era la línea que faltaba!

                              List<String> detalles = [];
                              if (item.llevaExtraPapas) detalles.add('Extra Papas (+₡500)');
                              if (item.llevaSalsaExtra) detalles.add('Salsa Extra (+₡200)');
                              if (item.sinSalsas) detalles.add('Sin Salsas');
                              if (item.salsasAparte) detalles.add('Salsas Aparte');
                              if (item.sinTomate) detalles.add('Sin Tomate');
                              if (item.sinLechuga) detalles.add('Sin Lechuga');
                              if (item.sinQuesoAmarillo) detalles.add('Sin Queso');
                              if (item.sinRepollo) detalles.add('Sin Repollo');
                              if (item.llevaJugo) detalles.add('Con Jugo (+₡500)');

                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                child: ListTile(
                                  title: Text(item.producto.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (detalles.isNotEmpty) Text(detalles.join(' • '), style: const TextStyle(color: Colors.orange, fontSize: 12)),
                                      Text('Cantidad: ${item.cantidad}', style: const TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('₡${(precioItem * item.cantidad).toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                      const SizedBox(width: 4),
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _mostrarPersonalizacion(context, item.producto, itemAEditar: item, indexEdicion: index);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                        onPressed: () => carrito.removerItem(index),
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
                      const Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('₡${carrito.calcularTotal().toStringAsFixed(0)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE6B800),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: carrito.items.isEmpty ? null : () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const CheckoutScreen()));
                      },
                      child: const Text('Proceder al Checkout', style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.bold)),
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
  final bool agotado; 
  final VoidCallback onTap;

  const TarjetaRecomendado({
    super.key,
    required this.nombre,
    required this.precio,
    required this.icono,
    required this.colorTarjeta,
    this.agotado = false,
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
          boxShadow: agotado ? [] : [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, size: 48, color: agotado ? Colors.grey : Colors.orange[800]),
            const SizedBox(height: 12),
            Text(
              nombre,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                decoration: agotado ? TextDecoration.lineThrough : TextDecoration.none,
                color: agotado ? Colors.grey : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            agotado
                ? const Text('Agotado', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
                : Text(precio, style: TextStyle(color: Colors.orange[900], fontWeight: FontWeight.bold)),
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
  final bool agotado; 
  final VoidCallback onTap;

  const TarjetaProducto({
    super.key,
    required this.nombre,
    required this.precio,
    required this.descripcion,
    required this.colorFondo,
    required this.colorBorde,
    this.agotado = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: colorFondo,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: agotado ? 0 : 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          nombre,
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 18,
            decoration: agotado ? TextDecoration.lineThrough : TextDecoration.none,
            color: agotado ? Colors.grey : Colors.black87,
          ),
        ),
        subtitle: Text(descripcion, style: TextStyle(color: agotado ? Colors.grey : Colors.black54)),
        trailing: agotado
            ? const Text('Agotado', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16))
            : Text(precio, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
        onTap: onTap,
      ),
    );
  }
}