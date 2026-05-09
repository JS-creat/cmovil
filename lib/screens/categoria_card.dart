// widgets/categoria_card_vertical.dart
import 'package:flutter/material.dart';

class CategoriaCard extends StatelessWidget {
  final String titulo;
  final String imagenPath;
  final VoidCallback onTap;

  const CategoriaCard({
    super.key,
    required this.titulo,
    required this.imagenPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Imagen de fondo que ocupa toda la tarjeta
              Image.asset(
                imagenPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        color: Colors.grey,
                        size: 40,
                      ),
                    ),
                  );
                },
              ),

              // Franja semitransparente en la parte inferior
              Positioned(
                bottom: 12, // Separada del borde inferior
                left: 12, // Separada del borde izquierdo
                right: 12, // Separada del borde derecho
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4, // Solo un poco más que el texto
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85), // Semitransparente
                    borderRadius: BorderRadius.circular(
                      4,
                    ), // Opcional: bordes ligeramente redondeados
                  ),
                  child: Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
