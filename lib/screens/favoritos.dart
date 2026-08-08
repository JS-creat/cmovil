import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucky/screens/producto_card.dart';
import 'package:provider/provider.dart';
import 'package:lucky/providers/favoritos_provider.dart';
import 'package:lucky/providers/auth_provider.dart';
import 'package:lucky/providers/carrito_provider.dart';
import 'package:material_symbols_icons/symbols.dart';

class Favoritos extends StatefulWidget {
  const Favoritos({super.key});

  @override
  State<Favoritos> createState() => _FavoritosState();
}

class _FavoritosState extends State<Favoritos> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final favoritosProvider = Provider.of<FavoritosProvider>(
        context,
        listen: false,
      );
      favoritosProvider.cargarFavoritos(authProvider);
    });
  }

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
                      vertical: 7,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 40),
                        const Text(
                          'Mis Favoritos',
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
                                  onPressed: () {
                                    context.go('/carrito');
                                  },
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

            // ================= CONTENIDO =================
            Expanded(
              child: Consumer2<FavoritosProvider, AuthProvider>(
                builder: (context, favoritosProvider, authProvider, child) {
                  final productosFavoritos =
                      favoritosProvider.productosFavoritos;

                  if (productosFavoritos.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Symbols.favorite, // 👈 CAMBIADO A Symbols
                            size: 80,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No tienes favoritos',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Agrega productos a tus favoritos',
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
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 170 / 320,
                          ),
                      itemCount: productosFavoritos.length,
                      itemBuilder: (context, index) {
                        final producto = productosFavoritos[index];
                        return ProductoCard(
                          producto: producto,
                          onTap: () {
                            context.push('/detallesProducto', extra: producto);
                          },
                          mostrarCorazon: true,
                          esFavorito: true,
                          onCorazonTap: () async {
                            await favoritosProvider.eliminarFavorito(
                              producto,
                              authProvider,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Eliminado de favoritos'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        );
                      },
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
