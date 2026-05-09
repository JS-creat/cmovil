import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lucky/providers/carrito_provider.dart';
import 'package:material_symbols_icons/symbols.dart';

class Carrito extends StatefulWidget {
  const Carrito({super.key});

  @override
  State<Carrito> createState() => _CarritoState();
}

class _CarritoState extends State<Carrito> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // BARRA SUPERIOR
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
                      mainAxisAlignment: MainAxisAlignment.start,
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
                            Symbols.arrow_back,
                            size: 24,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Carrito',
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

            // CONTENIDO
            Expanded(
              child: Consumer<CarritoProvider>(
                builder: (context, carritoProvider, child) {
                  final productos = carritoProvider.productos;
                  final total = carritoProvider.total;

                  if (productos.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Symbols.shopping_bag,
                            size: 80,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tu bolsa está vacía',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Agrega productos para continuar',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Container(
                    color: const Color(0xFFF7F7F7),
                    child: Column(
                      children: [
                        // Lista de productos
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            itemCount: productos.length,
                            itemBuilder: (context, index) {
                              final producto = productos[index];
                              return _ItemCarritoConCupones(
                                producto: producto,
                                index: index,
                              );
                            },
                          ),
                        ),

                        // Sección de total y botón de compra
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              top: BorderSide(color: Colors.black12, width: 1),
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              // Total
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total:',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'S/ ${total.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Botón continuar compra
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    context.push('/informacionCompra');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                  ),
                                  child: const Text(
                                    'Continuar con la compra',
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget separado para manejar el estado de cupones por producto
class _ItemCarritoConCupones extends StatefulWidget {
  final Map<String, dynamic> producto;
  final int index;

  const _ItemCarritoConCupones({required this.producto, required this.index});

  @override
  State<_ItemCarritoConCupones> createState() => _ItemCarritoConCuponesState();
}

class _ItemCarritoConCuponesState extends State<_ItemCarritoConCupones> {
  bool _cuponesExpandidos = false;

  final List<Map<String, dynamic>> _cuponesDisponibles = [
    {
      'codigo': 'DESC20',
      'descuento': 20,
      'descripcion': '20% de descuento en toda la compra',
      'validoHasta': '31/12/2024',
    },
    {
      'codigo': 'ENVIOGRATIS',
      'descuento': 0,
      'descripcion': 'Envío gratis en compras mayores a S/ 100',
      'validoHasta': '15/12/2024',
    },
    {
      'codigo': 'VERANO15',
      'descuento': 15,
      'descripcion': '15% de descuento en productos de verano',
      'validoHasta': '30/11/2024',
    },
    {
      'codigo': 'BIENVENIDA10',
      'descuento': 10,
      'descripcion': '10% de descuento para nuevos usuarios',
      'validoHasta': '31/12/2024',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final carritoProvider = Provider.of<CarritoProvider>(context);
    final producto = widget.producto;
    final index = widget.index;

    final String imagenPrincipal = producto['imagen_principal'] ?? '';
    final String titulo = producto['titulo'] ?? '';
    final double precio = producto['precio'] is int
        ? (producto['precio'] as int).toDouble()
        : producto['precio'] as double;
    final int cantidad = producto['cantidad'] as int;
    final String talla = producto['talla'] ?? '';
    final String color = producto['color'] ?? '';
    final double? precioAntes = producto['precioAntes'] != null
        ? (producto['precioAntes'] as num).toDouble()
        : null;
    final int? descuento = producto['descuento'] as int?;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
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
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen del producto
              Container(
                width: 100,
                height: 130,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade100,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imagenPrincipal.isNotEmpty
                      ? Image.network(
                          imagenPrincipal,
                          fit: BoxFit.cover,
                          width: 100,
                          height: 130,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade200,
                              child: Icon(
                                Symbols.image,
                                size: 40,
                                color: Colors.grey.shade400,
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Icon(
                            Symbols.image,
                            size: 40,
                            color: Colors.grey.shade400,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),

              // Información del producto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título y botón eliminar (ahora con X)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              titulo,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            carritoProvider.eliminarProducto(context, index);
                          },
                          icon: Icon(
                            Symbols.close,
                            size: 20,
                            color: Colors.black,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Color y talla
                    Row(
                      children: [
                        Text(
                          'Color: $color',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Talla: $talla',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Precio y descuento
                    Row(
                      children: [
                        Text(
                          'S/ ${precio.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Color(0xFFFF0000),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (descuento != null && descuento > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF0000),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '-$descuento%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),

                    // Precio anterior
                    if (precioAntes != null)
                      Text(
                        'S/ ${precioAntes.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    const SizedBox(height: 8),

                    // Selector de cantidad y botón de cupones
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Selector de cantidad
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: cantidad > 1
                                    ? () => carritoProvider.decrementarCantidad(
                                        context,
                                        index,
                                      )
                                    : null,
                                icon: Icon(
                                  Symbols.remove,
                                  size: 16,
                                  color: cantidad > 1
                                      ? Colors.black
                                      : Colors.grey,
                                ),
                                padding: const EdgeInsets.all(4),
                                constraints: const BoxConstraints(),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                cantidad.toString(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                onPressed: () => carritoProvider
                                    .incrementarCantidad(context, index),
                                icon: Icon(Symbols.add, size: 16),
                                padding: const EdgeInsets.all(4),
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),

                        // Botón para mostrar cupones
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _cuponesExpandidos = !_cuponesExpandidos;
                              });
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.only(
                                left: 12,
                                right: 6,
                                top: 12,
                                bottom: 12,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Cupones',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  _cuponesExpandidos
                                      ? Symbols.keyboard_arrow_up
                                      : Symbols.keyboard_arrow_down,
                                  size: 16,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Lista desplegable de cupones
          if (_cuponesExpandidos) ...[
            const SizedBox(height: 12),
            Divider(color: Colors.grey.shade300, height: 1),
            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Symbols.local_offer, size: 16, color: Color(0xFFFF0000)),
                  const SizedBox(width: 6),
                  Text(
                    'Cupones disponibles',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ),

            Column(
              children: _cuponesDisponibles.map((cupon) {
                return _ItemCupon(
                  cupon: cupon,
                  onSeleccionar: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Cupón ${cupon['codigo']} aplicado'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    setState(() {
                      _cuponesExpandidos = false;
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

// Widget para mostrar cada cupón individual
class _ItemCupon extends StatelessWidget {
  final Map<String, dynamic> cupon;
  final VoidCallback onSeleccionar;

  const _ItemCupon({required this.cupon, required this.onSeleccionar});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: cupon['descuento'] > 0
                  ? Color(0xFFFF0000).withAlpha(25)
                  : Colors.green.withAlpha(25),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: cupon['descuento'] > 0
                    ? Color(0xFFFF0000).withAlpha(76)
                    : Colors.green.withAlpha(76),
                width: 1,
              ),
            ),
            child: Text(
              cupon['descuento'] > 0 ? '-${cupon['descuento']}%' : 'ENVÍO',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: cupon['descuento'] > 0
                    ? Color(0xFFFF0000)
                    : Colors.green,
              ),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cupon['codigo'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  cupon['descripcion'],
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Válido hasta: ${cupon['validoHasta']}',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),

          TextButton(
            onPressed: onSeleccionar,
            style: TextButton.styleFrom(
              backgroundColor: Color(0xFFFF0000),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            child: const Text(
              'Aplicar',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
