// screens/cupones.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:lucky/providers/carrito_provider.dart';
import 'package:material_symbols_icons/symbols.dart';

class Cupones extends StatefulWidget {
  const Cupones({super.key});

  @override
  State<Cupones> createState() => _CuponesState();
}

class _CuponesState extends State<Cupones> {
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
                        // Icono de carrito con Consumer
                        Consumer<CarritoProvider>(
                          builder: (context, carritoProvider, child) {
                            final cantidadTotal = carritoProvider.cantidadTotal;
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    context.go('/carrito');
                                  },
                                  icon: const Icon(
                                    Symbols.shopping_bag,
                                    size: 28,
                                    color: Colors.black,
                                  ),
                                ),
                                if (cantidadTotal > 0)
                                  Positioned(
                                    right: 2, // 👈 MÁS A LA IZQUIERDA (era 0)
                                    top: 4, // 👈 MÁS ABAJO (era 0)
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

            // ================= CONTENIDO PRINCIPAL =================
            Expanded(
              child: Container(
                color: const Color(0xFFF7F7F7),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 8, bottom: 12),
                      child: Text(
                        'Tus cupones disponibles',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    _CuponCard(
                      icono: Symbols.confirmation_number,
                      titulo: 'Cupón de S/ 50',
                      descripcion:
                          'Cupón con valor de S/ 50 de descuento en prendas de mujer.',
                      fechaVencimiento: 'Vence: 30 días',
                      colorFondo: const Color(0xFFFFF0F0),
                    ),

                    const SizedBox(height: 12),

                    _CuponCard(
                      icono: Symbols.confirmation_number,
                      titulo: 'Cupón de S/ 20',
                      descripcion:
                          'Cupón con valor de S/ 20 de descuento en cualquier prenda de la tienda.',
                      fechaVencimiento: 'Vence: 30 días',
                      colorFondo: const Color(0xFFF0F7FF),
                    ),

                    const SizedBox(height: 12),

                    _CuponCard(
                      icono: Symbols.percent,
                      titulo: 'Cupón 30% OFF',
                      descripcion:
                          'Cupón de 30% de descuento en cualquier polera de la tienda.',
                      fechaVencimiento: 'Vence: 7 días',
                      colorFondo: const Color(0xFFF0FFF0),
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

// Widget para cada tarjeta de cupón
class _CuponCard extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String descripcion;
  final String fechaVencimiento;
  final Color colorFondo;

  const _CuponCard({
    required this.icono,
    required this.titulo,
    required this.descripcion,
    required this.fechaVencimiento,
    required this.colorFondo,
  });

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
                    color: colorFondo,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icono, color: const Color(0xFFFF0000), size: 24),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        descripcion,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            fechaVencimiento,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
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
