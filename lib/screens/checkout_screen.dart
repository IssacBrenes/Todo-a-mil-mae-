// lib/screens/checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 

import '../providers/carrito_provider.dart';
import '../models/inventario_motor.dart';
import '../models/configuracion_local.dart';
// ignore: unused_import
import 'order_tracking_screen.dart';
import 'main_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final ConfiguracionLocal config = ConfiguracionLocal();

  String _tipoEntrega = 'Recoger en local';
  ZonaExpress? _zonaSeleccionada;
  String _metodoPago = 'Transferencia (SINPE)';
  final TextEditingController _notasController = TextEditingController();

  final List<String> _metodosPago = [
    'Transferencia (SINPE)',
    'Efectivo exacto',
    'Efectivo con vuelto',
  ];

  @override
  Widget build(BuildContext context) {
    final carrito = Provider.of<CarritoProvider>(context);
    final Color amarilloFondo = const Color(0xFFFFF9E6);
    final Color amarilloPrincipal = const Color(0xFFE6B800);

    // 1. Cálculos Base
    double subtotalCarrito = carrito.calcularTotal();
    double costoEnvio = 0;

    // 2. Lógica Matemática
    bool esExpress = _tipoEntrega == 'Express';
    bool tieneZona = _zonaSeleccionada != null;

    if (esExpress && tieneZona) {
      if (config.estadoExpress == 'Condicionado') {
        costoEnvio = (subtotalCarrito >= config.compraMinimaExpress)
            ? 0
            : _zonaSeleccionada!.tarifa;
      } else if (config.estadoExpress == 'Activo') {
        costoEnvio = _zonaSeleccionada!.tarifa;
      }
    }

    double granTotal = subtotalCarrito + costoEnvio;

    // 3. Validación de Bloqueo del Botón
    bool botonBloqueado = false;
    String textoBoton = 'Enviar Pedido';

    if (esExpress) {
      if (!tieneZona) {
        botonBloqueado = true;
        textoBoton = 'Selecciona una zona';
      } else if (config.estadoExpress == 'Condicionado' &&
          granTotal < config.compraMinimaExpress) {
        botonBloqueado = true;
        textoBoton = 'No alcanzas el mínimo';
      }
    }

    return Scaffold(
      backgroundColor: amarilloFondo,
      appBar: AppBar(
        title: const Text(
          'Confirmar Pedido',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: amarilloPrincipal,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: amarilloPrincipal, width: 1),
              ),
              child: const Row(
                children: [
                  Icon(Icons.person, color: Colors.grey),
                  SizedBox(width: 10),
                  Text(
                    'Cliente: Isaac (8888-8888)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Método de Entrega',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (config.estadoExpress == 'Apagado')
              const Padding(
                padding: EdgeInsets.only(bottom: 12.0),
                child: Text(
                  '⚠️ Debido al clima o alta demanda, operamos solo para recoger en local.',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            // SELECTOR DE MÉTODO DE ENTREGA
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _tipoEntrega,
                  isExpanded: true,
                  items:
                      [
                        'Recoger en local',
                        if (config.estadoExpress != 'Apagado') 'Express',
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _tipoEntrega = newValue!;
                      if (_tipoEntrega == 'Recoger en local') {
                        _zonaSeleccionada = null;
                      }
                    });
                  },
                ),
              ),
            ),

            if (esExpress) ...[
              const SizedBox(height: 12),

              // PANEL DINÁMICO (Aparece inmediatamente al seleccionar "Express", sin importar la zona)
              if (config.estadoExpress == 'Condicionado')
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        (!tieneZona &&
                                subtotalCarrito >=
                                    config.compraMinimaExpress) ||
                            (tieneZona && costoEnvio == 0)
                        ? Colors.green[50]
                        : (botonBloqueado ? Colors.red[50] : Colors.orange[50]),
                    border: Border.all(
                      color:
                          (!tieneZona &&
                                  subtotalCarrito >=
                                      config.compraMinimaExpress) ||
                              (tieneZona && costoEnvio == 0)
                          ? Colors.green
                          : (botonBloqueado ? Colors.red : Colors.orange),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // CASO 1: AVISO TEMPRANO (Sin zona y sin llegar a la meta de comida)
                      if (!tieneZona &&
                          subtotalCarrito < config.compraMinimaExpress) ...[
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.orange[800]),
                            const SizedBox(width: 8),
                            Text(
                              'Condiciones del Express',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[900],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Para obtener envío GRATIS, necesitas al menos ₡${config.compraMinimaExpress.toStringAsFixed(0)} en productos. Actualmente tienes ₡${subtotalCarrito.toStringAsFixed(0)}.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.orange[900],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Añade ₡${(config.compraMinimaExpress - subtotalCarrito).toStringAsFixed(0)} en el menú para envío gratis, o selecciona tu zona abajo para ver la tarifa.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.orange[900],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ]
                      // CASO 2: ÉXITO TEMPRANO (Sin zona pero con el carrito lleno)
                      // CASO 2: ÉXITO TEMPRANO (Sin zona pero con el carrito lleno)
                      // CASO 2: ÉXITO TEMPRANO (Sin zona pero con el carrito lleno)
                      else if (!tieneZona &&
                          subtotalCarrito >= config.compraMinimaExpress) ...[
                        Row(
                          // <-- Le quitamos el const al Row general
                          children: [
                            const Icon(
                              Icons.stars,
                              color: Colors.green,
                            ), // Se lo pasamos al Icon
                            const SizedBox(
                              width: 8,
                            ), // Se lo pasamos al SizedBox
                            Text(
                              '¡Envío Gratis Desbloqueado!',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green[800],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Llenaste tu carrito de comida. Selecciona tu zona abajo y el envío te saldrá en ₡0.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.green[900],
                          ),
                        ),
                      ]
                      // CASO 3: BLOQUEADO (Con zona pero Gran Total < Mínimo)
                      else if (tieneZona && botonBloqueado) ...[
                        const Row(
                          children: [
                            Icon(Icons.block, color: Colors.red),
                            SizedBox(width: 8),
                            Text(
                              'Falta para procesar la orden',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tu total con envío es ₡${granTotal.toStringAsFixed(0)}. Faltan ₡${(config.compraMinimaExpress - granTotal).toStringAsFixed(0)} para poder enviar tu pedido.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red[900],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '¡Añade un fresco o postre al carrito para superar el mínimo en lugar de pagar solo envío!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red[900],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ]
                      // CASO 4: UPSELLING (Con zona, alcanza mínimo pagando envío)
                      else if (tieneZona && costoEnvio > 0) ...[
                        Row(
                          children: [
                            Icon(Icons.stars, color: Colors.orange[800]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'El envío está asegurado!',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey[900],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Su pedido será entregado a ${_zonaSeleccionada!.nombre} con un costo de ₡${_zonaSeleccionada!.tarifa.toStringAsFixed(0)}. ¡Aún puedes añadir más comida para obtener envío gratis!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blueGrey[900],
                          ),
                        ),
                      ]
                      // CASO 5: ÉXITO TOTAL (Con zona y comida suficiente)
                      else ...[
                        Row(
                          children: [
                            Icon(
                              Icons.local_shipping,
                              color: Colors.green[800],
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '¡Envío GRATIS aplicado a tu zona!',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'El costo hasta ${_zonaSeleccionada!.nombre} ha sido eliminado de tu total. ¡A disfrutar!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.green[900],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

              // SELECTOR DE ZONA
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<ZonaExpress>(
                    hint: const Text('Selecciona la zona de envío'),
                    value: _zonaSeleccionada,
                    isExpanded: true,
                    items: config.zonas.map((ZonaExpress zona) {
                      bool esGratis =
                          config.estadoExpress == 'Condicionado' &&
                          subtotalCarrito >= config.compraMinimaExpress;
                      return DropdownMenuItem<ZonaExpress>(
                        value: zona,
                        child: Text(
                          esGratis
                              ? '${zona.nombre} (¡Gratis!)'
                              : '${zona.nombre} (+₡${zona.tarifa.toStringAsFixed(0)})',
                          style: TextStyle(
                            color: esGratis
                                ? Colors.green[700]
                                : Colors.black87,
                            fontWeight: esGratis
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (ZonaExpress? nuevaZona) {
                      setState(() {
                        _zonaSeleccionada = nuevaZona;
                      });
                    },
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),
            const Text(
              'Método de Pago',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _metodoPago,
                  isExpanded: true,
                  items: _metodosPago.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _metodoPago = newValue!;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),
            TextField(
              controller: _notasController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Notas para la cocina (opcional)',
                hintText: 'Ej. Timbre malo, llamar al llegar...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 32),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total a Pagar:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  '₡${granTotal.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

           // --- INICIO DEL BOTÓN REEMPLAZADO ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: amarilloPrincipal,
                  disabledBackgroundColor: Colors.grey[400],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: botonBloqueado
                    ? null
                    : () async {
                        // 1. Mostrar indicador de carga para evitar doble toque
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const Center(
                            child: CircularProgressIndicator(color: Colors.orange),
                          ),
                        );

                        try {
                          final db = FirebaseFirestore.instance;
                          final batch = db.batch();

                          // --- CONTADOR EXTRA DE JUGOS ---
                          int totalJugos = 0;

                          // --- PILAR 1: EL TIMBRE DIGITAL (La Comanda) ---
                          final pedidoRef = db.collection('pedidos').doc();
                          
                          final itemsMap = carrito.items.map((item) {
                            // Sumamos los jugos: ya sea como producto individual o como extra
                            if (item.producto.id == 'jugo' || item.producto.id == 'fresco') {
                              totalJugos += item.cantidad;
                            }
                            if (item.llevaJugo) {
                              totalJugos += item.cantidad;
                            }

                            return {
                              'producto_id': item.producto.id,
                              'nombre': item.producto.nombre,
                              'cantidad': item.cantidad,
                              'precio_unitario': item.producto.precioVenta,
                              'llevaExtraPapas': item.llevaExtraPapas,
                              'llevaSalsaExtra': item.llevaSalsaExtra,
                              'llevaJugo': item.llevaJugo,
                              'sinTomate': item.sinTomate,
                              'sinLechuga': item.sinLechuga,
                            };
                          }).toList();

                          batch.set(pedidoRef, {
                            // Usamos el ID real si existe, si no, lo marcamos como invitado
                            'cliente_id': FirebaseAuth.instance.currentUser?.uid ?? 'invitado', 
                            'cliente_nombre': 'Isaac', // Podrás conectar esto al perfil luego
                            'telefono': '8888-8888',
                            'metodo_entrega': _tipoEntrega,
                            'zona_express': _zonaSeleccionada?.nombre ?? 'N/A',
                            'costo_envio': costoEnvio,
                            'metodo_pago': _metodoPago,
                            'notas_cocina': _notasController.text,
                            'subtotal': subtotalCarrito,
                            'gran_total': granTotal,
                            'estado': 'Recibido',
                            'fecha_orden': FieldValue.serverTimestamp(),
                            'items': itemsMap,
                          });

                          // --- PILAR 2: EL DESCUENTO AUTOMÁTICO ---
                          final descuento = MotorInventario.calcularDescuento(carrito.items);
                          
                          if ((descuento['hamburguesas'] ?? 0) > 0) {
                            batch.update(db.collection('productos').doc('hamburguesa'), 
                              {'stock': FieldValue.increment(-(descuento['hamburguesas'] as int))});
                          }
                          if ((descuento['tacos'] ?? 0) > 0) {
                            batch.update(db.collection('productos').doc('taco'), 
                              {'stock': FieldValue.increment(-(descuento['tacos'] as int))});
                          }
                          if ((descuento['ordenesPapas'] ?? 0) > 0) {
                            batch.update(db.collection('productos').doc('papas'), 
                              {'stock': FieldValue.increment(-(descuento['ordenesPapas'] as int))});
                          }
                          // NUEVO: Descuento de Jugos
                          if (totalJugos > 0) {
                            // Cambia 'jugo' por 'fresco' si así se llama el documento en tu Firebase
                            batch.update(db.collection('productos').doc('jugo'), 
                              {'stock': FieldValue.increment(-totalJugos)});
                          }

                          // --- PILAR 3: LAS RECOMPENSAS (CORREGIDO) ---
                          int puntosGanados = (granTotal / 1000).floor();
                          final String? uid = FirebaseAuth.instance.currentUser?.uid;
                          
                          if (uid != null && puntosGanados > 0) {
                            final userRef = db.collection('usuarios').doc(uid);
                            // Usamos update para sumar sobre el atributo "puntos" que ya existe
                            batch.update(userRef, {
                              'puntos': FieldValue.increment(puntosGanados)
                            });
                          }

                          // --- EJECUCIÓN MAESTRA ---
                          await batch.commit(); 

                          if (context.mounted) Navigator.pop(context);

                          carrito.limpiarCarrito();
                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MainScreen(indiceInicial: 1),
                              ),
                              (route) => false,
                            );
                          }

                        } catch (e) {
                          // Si falla el internet o Firebase, quitamos el loading y avisamos
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error al enviar la orden: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                child: Text(
                  textoBoton,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: botonBloqueado ? Colors.grey[700] : Colors.black87,
                  ),
                ),
              ),
            ),
            // --- FIN DEL BOTÓN REEMPLAZADO ---
          ],
        ),
      ),
    );
  }
}
