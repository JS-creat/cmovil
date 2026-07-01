import 'package:flutter/material.dart';
import '../widgets/info_pedido_box.dart';
import '../utils/api_config.dart';

class DetallesPedidoScreen extends StatelessWidget {
  final dynamic pedido; 

  const DetallesPedidoScreen({Key? key, required this.pedido}) : super(key: key);

  int _obtenerPasoEstado(String? estado) {
    if (estado == null) return 0;
    final estadoLimpio = estado.toLowerCase().trim();
    switch (estadoLimpio) {
      case 'pendiente': return 0;
      case 'confirmado':
      case 'procesando':
      case 'preparando': return 1;
      case 'en camino':
      case 'en_camino':
      case 'en ruta':
      case 'en_ruta': return 2;
      case 'listo para recoger':
      case 'listo_recoger':
      case 'listo': return 3;
      case 'entregado':
      case 'completado': return 4;
      default: return 0; 
    }
  }

  String _formatearFecha(dynamic fecha) {
    if (fecha == null) return '—';
    try {
      final date = DateTime.parse(fecha.toString());
      final dia = date.day.toString().padLeft(2, '0');
      final mes = date.month.toString().padLeft(2, '0');
      final anio = date.year.toString();
      return '$dia/$mes/$anio';
    } catch (e) {
      return fecha.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    print("--- DEBÚG DETALLES PEDIDO ---");
    print("Contenido del objeto pedido: $pedido");

    final String estadoTexto = (pedido['estado'] ?? 
                               pedido['status'] ?? 
                               pedido['estado_pedido'] ?? 'Pendiente').toString();
    final String estadoLimpioParaColor = estadoTexto.toLowerCase().trim();

    // 🟢 FIX: detectamos también el estado "anulado"/"cancelado"
    final bool esEntregado = estadoLimpioParaColor == 'entregado' || 
                             estadoLimpioParaColor == 'completado';
    final bool esAnulado = estadoLimpioParaColor == 'anulado' || 
                           estadoLimpioParaColor == 'cancelado';

    // Verde si entregado, gris si anulado, rojo corporativo en cualquier otro caso
    final Color colorTematico = esEntregado 
        ? const Color(0xFF2E7D32)
        : esAnulado 
            ? Colors.grey.shade600
            : const Color(0xFFED1C24);

    // 🟢 La etiqueta "ANULADO" se muestra en rojo aunque el stepper se quede gris
    final Color colorEtiquetaEstado = esAnulado
        ? const Color(0xFFED1C24)
        : colorTematico;

    // Si está anulado, el stepper se queda clavado en "Pendiente" (no avanza)
    final int pasoActual = esAnulado ? 0 : _obtenerPasoEstado(estadoTexto);

    // 🟢 FIX: quitamos el '69.90' hardcodeado. Revisa el print de consola
    // ("Contenido del objeto pedido: $pedido") para confirmar el nombre real
    // del campo de precio en tu API y agrégalo aquí si falta.
    final totalPedido = pedido['total_pedido'] ?? pedido['precio_total'] ?? pedido['total'] ?? '0.00';
    final codigoPedido = pedido['codigo'] ?? pedido['numero_pedido'] ?? pedido['codigo_pedido'] ?? pedido['id']?.toString() ?? '';
    final tipoEntrega = pedido['tipo_entrega'] ?? 'Recojo en tienda';
    
    final List<dynamic> productos = pedido['productos'] ?? pedido['detalles'] ?? pedido['items'] ?? [];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('Pedido #$codigoPedido', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Monto Pagado', style: TextStyle(color: Colors.grey, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(
                          'S/ $totalPedido',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: colorEtiquetaEstado.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        estadoTexto.toUpperCase(),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: colorEtiquetaEstado, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 🟢 MODIFICACIÓN AQUÍ: Fila adaptada con Tipo entrega y Cajas de fechas integradas (Estilo Web)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LADO IZQUIERDO: Tarjeta Tipo Entrega
                Expanded(
                  flex: 4,
                  child: Card(
                    color: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tipo entrega', style: TextStyle(color: Colors.grey, fontSize: 13)),
                          const SizedBox(height: 6),
                          Text(
                            tipoEntrega,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                Expanded(
                  flex: 6,
                  child: Column(
                    children: [
                      InfoPedidoBox(
                        titulo: 'Fecha envío',
                        fecha: _formatearFecha(pedido['fecha_envio']),
                        colorFondo: const Color(0xFFE3F2FD),
                        colorTexto: const Color(0xFF0D47A1),
                        icono: Icons.local_shipping_outlined,
                      ),
                      InfoPedidoBox(
                        titulo: 'Entrega estimada',
                        fecha: _formatearFecha(pedido['fecha_entrega_estimada']),
                        colorFondo: const Color(0xFFFFFDE7),
                        colorTexto: const Color(0xFFF57F17),
                        icono: Icons.calendar_today_outlined,
                      ),
                      InfoPedidoBox(
                        titulo: 'Entregado el',
                        fecha: _formatearFecha(pedido['fecha_entrega_real']),
                        colorFondo: const Color(0xFFE8F5E9),
                        colorTexto: const Color(0xFF1B5E20),
                        icono: Icons.check_circle_outline,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Productos en este pedido
            if (productos.isNotEmpty) ...[
              const Text(
                'Productos en este pedido',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: productos.length,
                itemBuilder: (context, index) {
                  final item = productos[index];

                  // 🟢 FIX: el producto real está anidado en item['variante']['producto'],
                  // no directo en item ni en item['producto']
                  final variante = item['variante'] ?? {};
                  final productoInfo = variante['producto'] ?? item['producto'] ?? item;

                  final String titulo = productoInfo['nombre_producto'] ??
                                       item['nombre_producto'] ??
                                       productoInfo['nombre'] ??
                                       productoInfo['titulo'] ??
                                       item['titulo_producto'] ?? 'Producto';

                  final String? imagenRaw = productoInfo['imagen'] ??
                                       item['foto_producto'] ??
                                       productoInfo['foto'] ??
                                       item['foto'] ??
                                       productoInfo['imagen_url'];

                  final String imagenUrl = ApiConfig.imagenProducto(imagenRaw);

                  // Usamos precio_unitario del detalle (ya viene correcto por línea de pedido)
                  final precioItem = item['precio_unitario'] ??
                                    item['precio'] ??
                                    productoInfo['precio_oferta'] ??
                                    productoInfo['precio'] ?? '0.00';
                  final cantidad = item['cantidad'] ?? 1;

                  return Card(
                    color: Colors.white,
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: (imagenUrl.isNotEmpty)
                                ? Image.network(
                                    imagenUrl,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      width: 50,
                                      height: 50,
                                      color: Colors.grey.shade100,
                                      child: const Icon(Icons.shopping_bag_outlined, color: Colors.grey, size: 20),
                                    ),
                                  )
                                : Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.grey.shade100,
                                    child: const Icon(Icons.shopping_bag_outlined, color: Colors.grey, size: 20),
                                  ),
                          ),
                          const SizedBox(width: 12),
                          
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  titulo,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Cantidad: $cantidad',
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'S/ $precioItem',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],

            // Seguimiento del pedido
            const Text(
              'Seguimiento del pedido',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(primary: colorTematico),
              ),
              child: SizedBox(
                width: double.infinity,
                child: Stepper(
                  physics: const NeverScrollableScrollPhysics(),
                  currentStep: pasoActual,
                  controlsBuilder: (context, details) => const SizedBox.shrink(),
                  steps: [
                    Step(
                      title: const Text('Pendiente', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Recibimos tu orden con éxito'),
                      content: const SizedBox.shrink(),
                      isActive: pasoActual >= 0,
                      state: pasoActual > 0 ? StepState.complete : StepState.editing,
                    ),
                    Step(
                      title: const Text('Confirmado', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Tu orden ha sido aprobada'),
                      content: const SizedBox.shrink(),
                      isActive: pasoActual >= 1,
                      state: pasoActual > 1 ? StepState.complete : (pasoActual == 1 ? StepState.editing : StepState.indexed),
                    ),
                    Step(
                      title: const Text('En Camino', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(tipoEntrega == 'Recojo en tienda' 
                        ? 'El pedido está siendo preparado para la tienda' 
                        : 'El motorizado está en ruta'),
                      content: const SizedBox.shrink(),
                      isActive: pasoActual >= 2,
                      state: pasoActual > 2 ? StepState.complete : (pasoActual == 2 ? StepState.editing : StepState.indexed),
                    ),
                    Step(
                      title: const Text('Listo para Recoger', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Ya puedes retirar tu compra'),
                      content: const SizedBox.shrink(),
                      isActive: pasoActual >= 3,
                      state: pasoActual > 3 ? StepState.complete : (pasoActual == 3 ? StepState.editing : StepState.indexed),
                    ),
                    Step(
                      title: const Text('Entregado', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('¡Compra completada con éxito!'),
                      content: const SizedBox.shrink(),
                      isActive: pasoActual == 4,
                      state: pasoActual == 4 ? StepState.complete : StepState.indexed,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}