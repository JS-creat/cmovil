import 'package:flutter/material.dart';
import 'package:lucky/utils/api_config.dart';
import 'package:material_symbols_icons/symbols.dart';

class ProductoCard extends StatelessWidget {
  final Map<String, dynamic> producto;
  final VoidCallback? onTap;
  final bool mostrarCorazon;
  final bool esFavorito;
  final VoidCallback? onCorazonTap;

  const ProductoCard({
    super.key,
    required this.producto,
    this.onTap,
    this.mostrarCorazon = false,
    this.esFavorito = false,
    this.onCorazonTap,
  });

  // Función para formatear precio de manera segura
  String _formatearPrecio(dynamic precio) {
    if (precio == null) return '0.00';

    if (precio is int) return precio.toStringAsFixed(2);
    if (precio is double) return precio.toStringAsFixed(2);

    if (precio is String) {
      final numero = double.tryParse(precio);
      return numero?.toStringAsFixed(2) ?? '0.00';
    }

    return '0.00';
  }

  @override
  Widget build(BuildContext context) {
    String imagenOriginal =
        producto['imagen_principal']?.toString().trim() ?? '';

    final String imagenPrincipal = imagenOriginal.replaceFirst(
      '${ApiConfig.baseUrl}/productos/',
      '${ApiConfig.apiUrl}/imagen/',
    );

    int descuentoPorcentaje = producto['descuento'] ?? 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 170,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del producto
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: imagenPrincipal.isNotEmpty
                  ? Image.network(
                      imagenPrincipal,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 220,
                          color: Colors.grey.shade100,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                              color: const Color(0xFFED1C24),
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 220,
                          color: Colors.grey.shade100,
                          child: Center(
                            child: Icon(
                              Symbols.image,
                              size: 40,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      height: 220,
                      color: Colors.grey.shade100,
                      child: Center(
                        child: Icon(
                          Symbols.image_not_supported,
                          size: 40,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          producto['titulo'] ?? 'Producto sin título',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (mostrarCorazon)
                        GestureDetector(
                          onTap: onCorazonTap,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 4, top: 2),
                            child: Icon(
                              Symbols.favorite,
                              fill: esFavorito ? 1 : 0,
                              size: 20,
                              color: esFavorito
                                  ? Colors.black
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Row(
                    children: [
Text(
            'S/ ${_formatearPrecio(producto['precio'])}',
            style: TextStyle(
              color: (producto['precioAntes'] != null && 
                      producto['precioAntes'] > 0 && 
                      producto['precioAntes'] != producto['precio'])
                  ? const Color(0xFFED1C24)
                  : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
                      if (descuentoPorcentaje > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFED1C24),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '-$descuentoPorcentaje%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (producto['precioAntes'] != null &&
                      producto['precioAntes'] > 0 &&
                      producto['precioAntes'] != producto['precio']) ...[
                    const SizedBox(height: 2),
                    Stack(
                      children: [
                        Text(
                          'S/ ${_formatearPrecio(producto['precioAntes'])}',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 12,
                          ),
                        ),
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              height: 1,
                              width: 60,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}