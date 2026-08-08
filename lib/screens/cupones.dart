import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:lucky/providers/carrito_provider.dart';
import 'package:lucky/providers/cupon_provider.dart';
import 'package:lucky/models/Cupon_model.dart';

class Cupones extends StatefulWidget {
  const Cupones({super.key});

  @override
  State<Cupones> createState() => _CuponesState();
}

class _CuponesState extends State<Cupones> {
  @override
  void initState() {
    super.initState();
    // Cargar cupones al entrar a la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CuponProvider>().cargarCupones();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ================= BARRA SUPERIOR =================
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 7,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        const Text(
                          'Cupones',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Consumer<CarritoProvider>(
                          builder: (context, carritoProvider, child) {
                            final cantidadTotal = carritoProvider.cantidadTotal;
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                IconButton(
                                  onPressed: () => context.go('/carrito'),
                                  icon: const Icon(
                                    Symbols.shopping_cart,
                                    size: 28,
                                    color: Colors.black,
                                  ),
                                ),
                                if (cantidadTotal > 0)
                                  Positioned(
                                    right: 2,
                                    top: 4,
                                    child: Container(
                                      width: 16,
                                      height: 16,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFED1C24),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          cantidadTotal > 9
                                              ? '9+'
                                              : cantidadTotal.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(height: 1, color: Colors.black12),
                ],
              ),
            ),

            // ================= CONTENIDO DINÁMICO =================
            Expanded(
              child: Container(
                color: const Color(0xFFF7F7F7),
                child: Consumer<CuponProvider>(
                  builder: (context, cuponProvider, _) {
                    // Loading
                    if (cuponProvider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // Error
                    if (cuponProvider.error != null) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No se pudieron cargar los cupones',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                cuponProvider.error!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => cuponProvider.cargarCupones(),
                                child: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // Lista vacía
                    if (cuponProvider.cupones.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Symbols.local_offer,
                                size: 48,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No hay cupones disponibles',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Vuelve pronto para ver nuevas promociones',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // Lista real de cupones
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: cuponProvider.cupones.length,
                      itemBuilder: (context, index) {
                        final cupon = cuponProvider.cupones[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _CuponCardReal(cupon: cupon),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= TARJETA DE CUPÓN REAL (desde API) =================
class _CuponCardReal extends StatelessWidget {
  final CuponModel cupon;

  const _CuponCardReal({required this.cupon});

  Color get _colorFondo {
    if (cupon.tipoDescuento == 'porcentaje') {
      return const Color(0xFFF0FFF0); // verde claro
    }
    return const Color(0xFFFFF0F0); // rojo claro
  }

  IconData get _icono {
    if (cupon.tipoDescuento == 'porcentaje') {
      return Symbols.percent;
    }
    return Symbols.confirmation_number;
  }

  String get _vencimientoTexto {
    if (cupon.diasRestantes <= 0) return 'Vence hoy';
    if (cupon.diasRestantes == 1) return 'Vence mañana';
    return 'Vence: ${cupon.diasRestantes} días';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: const Color(0xFFFF0000).withAlpha(51),
                width: 4,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _colorFondo,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(_icono, color: const Color(0xFFFF0000), size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Código del cupón en negrita
                      Text(
                        cupon.codigo,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Descripción
                      Text(
                        cupon.descripcion.isNotEmpty
                            ? cupon.descripcion
                            : 'Descuento ${cupon.descuentoFormateado}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Descuento formateado
                      Text(
                        cupon.descuentoFormateado,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFED8B00),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Vencimiento
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _vencimientoTexto,
                            style: TextStyle(
                              fontSize: 12,
                              color: cupon.diasRestantes <= 3
                                  ? Colors.orange
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      if (cupon.montoCompraMinima > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Compra mínima: S/ ${cupon.montoCompraMinima.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}