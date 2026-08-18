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
                            Symbols.shopping_cart,
                            size: 80,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tu carrito está vacío',
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

// Widget separado para manejar cada ítem del carrito
class _ItemCarritoConCupones extends StatefulWidget {
  final Map<String, dynamic> producto;
  final int index;

  const _ItemCarritoConCupones({required this.producto, required this.index});

  @override
  State<_ItemCarritoConCupones> createState() => _ItemCarritoConCuponesState();
}

class _ItemCarritoConCuponesState extends State<_ItemCarritoConCupones> {
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
    // Solo se pinta rojo/tachado si realmente hay una oferta
    final bool tieneOferta =
        precioAntes != null && precioAntes > 0 && precioAntes != precio;
    // Stock disponible para esta variante específica
    final int stockDisponible = producto['stock'] is int
        ? producto['stock'] as int
        : (producto['stock'] as num?)?.toInt() ?? 0;

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
      child: Row(
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
                // Título y botón eliminar
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
                      style: TextStyle(
                        color: tieneOferta
                            ? const Color(0xFFFF0000)
                            : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (tieneOferta && descuento != null && descuento > 0)
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
                if (tieneOferta)
                  Text(
                    'S/ ${precioAntes.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                const SizedBox(height: 8),

                // Selector de cantidad (sin botón de cupones)
                Row(
                  children: [
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
                            onPressed: cantidad < stockDisponible
                                ? () => carritoProvider.incrementarCantidad(
                                      context,
                                      index,
                                    )
                                : () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'No hay más stock disponible',
                                        ),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  },
                            icon: Icon(
                              Symbols.add,
                              size: 16,
                              color: cantidad < stockDisponible
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}