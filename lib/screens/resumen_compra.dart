import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lucky/providers/carrito_provider.dart';
import 'package:lucky/services/checkout_service.dart';

class ResumenCompra extends StatefulWidget {
  final Map<String, dynamic> data;

  const ResumenCompra({super.key, required this.data});

  @override
  State<ResumenCompra> createState() => _ResumenCompraState();
}

class _ResumenCompraState extends State<ResumenCompra> {
  final CheckoutService _checkoutService = CheckoutService();
  bool _procesando = false;

  double _obtenerCostoEnvio() {
    return widget.data['costoEnvio'] as double? ?? 0.0;
  }

  String? _obtenerNombreAgencia() {
    return widget.data['nombreAgencia'] as String?;
  }

  String? _obtenerDireccionAgencia() {
    return widget.data['direccionAgencia'] as String?;
  }

  String? _obtenerTiempoEstimado() {
    return widget.data['tiempoEstimadoEnvio'] as String?;
  }

  // 🟢 NUEVO: código y descuento del cupón (llegan de informacion_compra)
  String? _obtenerCodigoCupon() {
    return widget.data['codigoCupon'] as String?;
  }

  double _obtenerDescuentoCupon() {
    return widget.data['montoDescuentoCupon'] as double? ?? 0.0;
  }

  Future<void> _confirmarPedido() async {
    if (_procesando) return;

    setState(() {
      _procesando = true;
    });

    try {
      final data = widget.data;

      final response = await _checkoutService.confirmarCheckout(
        idTipoDocumento: data['idTipoDocumento'],
        numeroDocumento: data['numeroDocumento'],
        telefono: data['telefono'],
        idTipoEntrega: data['idTipoEntrega'],
        idDistrito: data['idTipoEntrega'] == 2 ? data['idDistrito'] : null,
        codigoCupon: _obtenerCodigoCupon(),
      );

      if (!mounted) return;

      // 🟢 CAMBIADO: el pedido queda "Pendiente" en el backend — todavía
      // no hay pago real. En vez de navegar directo a "Compra exitosa"
      // (como si ya hubiera pagado), abrimos el WebView de Mercado Pago
      // con la URL que armó el backend (init_point). Recién cuando el
      // WebView detecta la URL de retorno de éxito, se navega a la
      // pantalla final.
      final initPoint = response['init_point'] as String?;

      if (initPoint == null || initPoint.isEmpty) {
        throw Exception('No se pudo iniciar el pago. Intenta nuevamente.');
      }

      if (!mounted) return;

      context.push(
        '/pagoWebview',
        extra: {
          'initPoint': initPoint,
          'idPedido': response['id_pedido'],
          'numeroPedido': response['numero_pedido'],
        },
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _procesando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final carritoProvider = Provider.of<CarritoProvider>(context);
    final productos = carritoProvider.productos;

    final nombreUsuario = widget.data['nombreUsuario'] ?? 'Usuario';
    final numeroDocumento = widget.data['numeroDocumento'] ?? '-';
    final tipoDocumentoNombre = widget.data['tipoDocumentoNombre'] ?? '';
    final idTipoEntrega = widget.data['idTipoEntrega'] as int?;
    final distritoNombre = widget.data['distritoNombre'];
    final departamentoNombre = widget.data['departamentoNombre'];
    final provinciaNombre = widget.data['provinciaNombre'];

    final costoEnvio = _obtenerCostoEnvio();
    final nombreAgencia = _obtenerNombreAgencia();
    final direccionAgencia = _obtenerDireccionAgencia();
    final tiempoEstimado = _obtenerTiempoEstimado();
    final codigoCupon = _obtenerCodigoCupon();
    final descuentoCupon = _obtenerDescuentoCupon();

    final subtotal = carritoProvider.total;
    final totalFinal =
        (subtotal - descuentoCupon).clamp(0, double.infinity) + costoEnvio;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/');
                            }
                          },
                          child: const Icon(
                            Icons.arrow_back,
                            size: 24,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Resumen de compra',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(height: 1, color: Colors.black12),
                ],
              ),
            ),

            Expanded(
              child: Container(
                color: const Color(0xFFF7F7F7),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Información de envío',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _infoCard(
                        children: [
                          _infoRow('Nombre', nombreUsuario.toString()),
                          const SizedBox(height: 14),
                          _infoRow(
                            'Documento',
                            tipoDocumentoNombre.isNotEmpty
                                ? '$tipoDocumentoNombre: $numeroDocumento'
                                : numeroDocumento.toString(),
                          ),
                          const SizedBox(height: 14),
                          _infoRow(
                            'Entrega',
                            idTipoEntrega == 1
                                ? 'Retiro en tienda'
                                : 'Envío a provincia',
                          ),
                          if (idTipoEntrega == 2) ...[
                            if (departamentoNombre != null) ...[
                              const SizedBox(height: 14),
                              _infoRow(
                                'Departamento',
                                departamentoNombre.toString(),
                              ),
                            ],
                            if (provinciaNombre != null) ...[
                              const SizedBox(height: 14),
                              _infoRow('Provincia', provinciaNombre.toString()),
                            ],
                            if (distritoNombre != null) ...[
                              const SizedBox(height: 14),
                              _infoRow('Distrito', distritoNombre.toString()),
                            ],
                            if (nombreAgencia != null) ...[
                              const SizedBox(height: 14),
                              _infoRow('Agencia', nombreAgencia),
                            ],
                            if (direccionAgencia != null) ...[
                              const SizedBox(height: 14),
                              _infoRow('Dirección', direccionAgencia),
                            ],
                            if (tiempoEstimado != null &&
                                tiempoEstimado.isNotEmpty) ...[
                              const SizedBox(height: 14),
                              _infoRow('Tiempo estimado', tiempoEstimado),
                            ],
                          ],
                        ],
                      ),

                      const SizedBox(height: 28),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Resumen del pedido',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${productos.length} producto${productos.length == 1 ? '' : 's'}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _infoCard(
                        padding: const EdgeInsets.all(16),
                        children: [
                          ...productos.map((producto) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _resumenProductoRow(producto),
                            );
                          }),

                          Divider(color: Colors.grey.shade200, height: 24),

                          _resumenRow('Subtotal', subtotal),

                          // 🟢 NUEVO: fila de descuento por cupón, solo si
                          // hay uno aplicado
                          if (codigoCupon != null && descuentoCupon > 0) ...[
                            const SizedBox(height: 10),
                            _resumenDescuentoRow(codigoCupon, descuentoCupon),
                          ],

                          const SizedBox(height: 10),
                          _resumenEnvioRow(costoEnvio),
                        ],
                      ),

                      const SizedBox(height: 24),

                      _infoCard(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'Total a pagar',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'S/ ${totalFinal.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'IGV incluido',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.black12, width: 1),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
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
                        'S/ ${totalFinal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _procesando ? null : _confirmarPedido,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _procesando
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Confirmar pedido',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard({
    required List<Widget> children,
    EdgeInsets padding = const EdgeInsets.all(18),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _resumenProductoRow(Map<String, dynamic> producto) {
    final String nombre = producto['titulo']?.toString() ?? 'Producto';
    final String imagenUrl = producto['imagen_principal']?.toString() ?? '';
    final String color = producto['color']?.toString() ?? '';
    final String talla = producto['talla']?.toString() ?? '';

    final int cantidad =
        int.tryParse((producto['cantidad'] ?? 1).toString()) ?? 1;

    final double precio =
        double.tryParse((producto['precio'] ?? 0).toString()) ?? 0.0;
    final double? precioAntes = producto['precioAntes'] != null
        ? double.tryParse(producto['precioAntes'].toString())
        : null;
    final bool tieneOferta =
        precioAntes != null && precioAntes > 0 && precioAntes != precio;

    final double subtotalProducto = precio * cantidad;

    final String subtitulo = [
      if (color.isNotEmpty) color,
      if (talla.isNotEmpty) talla,
    ].join(' · ');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imagenUrl.isNotEmpty
                  ? Image.network(
                      imagenUrl,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 56,
                        height: 56,
                        color: Colors.grey.shade100,
                        child: Icon(
                          Icons.image_outlined,
                          color: Colors.grey.shade400,
                          size: 22,
                        ),
                      ),
                    )
                  : Container(
                      width: 56,
                      height: 56,
                      color: Colors.grey.shade100,
                      child: Icon(
                        Icons.image_outlined,
                        color: Colors.grey.shade400,
                        size: 22,
                      ),
                    ),
            ),
            Positioned(
              top: -6,
              left: -6,
              child: Container(
                width: 18,
                height: 18,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  cantidad.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nombre,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitulo.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  subtitulo,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
              if (tieneOferta) ...[
                const SizedBox(height: 2),
                const Text(
                  'En oferta',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),

        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'S/ ${subtotalProducto.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'S/ ${precio.toStringAsFixed(2)} c/u',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ],
        ),
      ],
    );
  }

  Widget _resumenRow(String label, double valor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
        ),
        Text(
          'S/ ${valor.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  // 🟢 NUEVO: fila de descuento del cupón, en verde con signo negativo
  Widget _resumenDescuentoRow(String codigo, double descuento) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Descuento ($codigo)',
          style: TextStyle(fontSize: 14, color: Colors.green.shade700),
        ),
        Text(
          '- S/ ${descuento.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.green.shade700,
          ),
        ),
      ],
    );
  }

  Widget _resumenEnvioRow(double costoEnvio) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Envío',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
        ),
        Text(
          costoEnvio > 0 ? '+ S/ ${costoEnvio.toStringAsFixed(2)}' : '—',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: costoEnvio > 0
                ? const Color(0xFFED8B00)
                : Colors.grey.shade400,
          ),
        ),
      ],
    );
  }
}