import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    // Diagnóstico en consola de desarrollo para verificar la estructura exacta recibida
    print("--- DEBÚG DETALLES PEDIDO ---");
    print("Contenido del objeto pedido: $pedido");

    final String estadoTexto = (pedido['estado'] ?? 
                               pedido['status'] ?? 
                               pedido['estado_pedido'] ?? 'Pendiente').toString();
                               
    final int pasoActual = _obtenerPasoEstado(estadoTexto);
    
    // 🟢 CORRECCIÓN AQUÍ: Forzamos toLowerCase() para que "ENTREGADO" en mayúsculas también sea capturado
    final bool esEntregado = estadoTexto.toLowerCase().trim() == 'entregado' || 
                             estadoTexto.toLowerCase().trim() == 'completado';
                             
    // Si está entregado se vuelve verdesito (0xFF2E7D32), si no, se queda en el rojo corporativo
    final Color colorTematico = esEntregado ? const Color(0xFF2E7D32) : const Color(0xFFED1C24);
    
    final totalPedido = pedido['precio_total'] ?? pedido['total'] ?? pedido['precio'] ?? '69.90';
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
            // Tarjeta Monto Pagado
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
                    Column(
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
                    // 🟢 Ahora sí pintará de color verde dinámico la etiqueta superior
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: colorTematico.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        estadoTexto.toUpperCase(),
                        style: TextStyle(color: colorTematico, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Tarjeta Tipo Entrega
            Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tipo entrega', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(
                      tipoEntrega,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ],
                ),
              ),
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
                  
                  final productoInfo = item['producto'] ?? item;
                  
                  final String titulo = item['nombre_producto'] ?? 
                                       productoInfo['nombre'] ?? 
                                       productoInfo['titulo'] ?? 
                                       item['titulo_producto'] ?? 'Producto';
                  
                  final String? imagenRaw = item['foto_producto'] ?? 
                                           productoInfo['foto'] ?? 
                                           productoInfo['imagen'] ?? 
                                           item['foto'] ?? 
                                           productoInfo['imagen_url'];
                  
                  String? imagenUrl = imagenRaw;
                  if (imagenUrl != null && imagenUrl.isNotEmpty) {
                    if (!imagenUrl.startsWith('http')) {
                      if (imagenUrl.contains('productos/')) {
                        imagenUrl = 'https://www.bedenb.com/' + (imagenUrl.startsWith('/') ? imagenUrl.substring(1) : imagenUrl);
                      } else {
                        imagenUrl = 'https://www.bedenb.com/productos/' + (imagenUrl.startsWith('/') ? imagenUrl.substring(1) : imagenUrl);
                      }
                    }
                  }

                  final precioItem = item['precio'] ?? item['precio_unitario'] ?? productoInfo['precio'] ?? '0.00';
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
                            child: (imagenUrl != null && imagenUrl.isNotEmpty)
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

            // 🟢 El Stepper ahora sí cambiará dinámicamente sus líneas y círculos a verde al estar entregado
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
                      subtitle: const Text('El motorizado está en ruta'),
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