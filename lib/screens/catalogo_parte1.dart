// screens/catalogo_parte1.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lucky/providers/generos_provider.dart';
import 'package:lucky/screens/categoria_card.dart';

class CatalogoParte1 extends StatefulWidget {
  const CatalogoParte1({super.key});

  @override
  State<CatalogoParte1> createState() => _CatalogoParte1State();
}

class _CatalogoParte1State extends State<CatalogoParte1> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final generosProvider = Provider.of<GenerosProvider>(
        context,
        listen: false,
      );
      if (!generosProvider.cargados) {
        generosProvider.cargarGeneros();
      }
    });
  }

  // Mapa de imágenes locales para cada género (usando el nombre como key)
  final Map<String, String> _imagenesGeneros = {
    'hombre': 'assets/catalogo_hombre.jpg',
    'mujer': 'assets/catalogo_mujer.jpg',
    // Puedes agregar más según los géneros que tengas
    'default': 'assets/catalogo_default.jpg',
  };

  String _getImagenParaGenero(String nombreGenero) {
    final nombreLower = nombreGenero.toLowerCase();
    return _imagenesGeneros[nombreLower] ?? _imagenesGeneros['default']!;
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
                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 16.0),
                      child: Text(
                        'Catálogo',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(height: 1, color: Colors.black12),
                ],
              ),
            ),

            // ================= CONTENIDO PRINCIPAL =================
            Expanded(
              child: Container(
                color: const Color(0xFFF7F7F7),
                child: Consumer<GenerosProvider>(
                  builder: (context, generosProvider, child) {
                    // Mostrar loading mientras carga
                    if (generosProvider.cargando && !generosProvider.cargados) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFED1C24),
                        ),
                      );
                    }

                    // Mostrar error si hay
                    if (generosProvider.error != null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error al cargar categorías',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                generosProvider.cargarGeneros(
                                  forzarRecarga: true,
                                );
                              },
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      );
                    }

                    // ✅ AHORA USA TODOS LOS GÉNEROS
                    final generos = generosProvider.generos;

                    // Si no hay géneros, mostrar mensaje
                    if (generos.isEmpty) {
                      return Center(
                        child: Text(
                          'No hay categorías disponibles',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      );
                    }

                    // Mostrar grid con TODOS los géneros de la API
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.75,
                            ),
                        itemCount: generos.length,
                        itemBuilder: (context, index) {
                          final genero = generos[index];
                          return CategoriaCard(
                            titulo: genero.nombreGenero,
                            imagenPath: _getImagenParaGenero(
                              genero.nombreGenero,
                            ),
                            onTap: () {
                              context.push(
                                '/catalogo-parte2',
                                extra: {
                                  'genero': genero.nombreGenero,
                                  'generoId': genero.idGenero,
                                },
                              );
                            },
                          );
                        },
                      ),
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
