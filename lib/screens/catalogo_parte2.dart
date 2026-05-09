import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucky/screens/categoria_card.dart';
import 'package:lucky/providers/categoria_provider.dart';
import 'package:provider/provider.dart';

class CatalogoParte2 extends StatefulWidget {
  final String genero;
  final int? generoId;

  const CatalogoParte2({super.key, required this.genero, this.generoId});

  @override
  State<CatalogoParte2> createState() => _CatalogoParte2State();
}

class _CatalogoParte2State extends State<CatalogoParte2> {
  final Map<String, String> _categorias = {
    'Pantalones': 'pantalones',
    'Casacas': 'casacas',
    'Camisas': 'camisas',
    'Polos': 'polos',
    'Abrigos': 'abrigos',
  };

  String _obtenerImagen(String categoria) {
    final nombreArchivo = _categorias[categoria] ?? categoria.toLowerCase();
    final generoKey = widget.genero.toLowerCase();
    return 'assets/${nombreArchivo}_$generoKey.jpg';
  }

  @override
  void initState() {
    super.initState();
    // 👇 ESPERAR A QUE EL WIDGET ESTÉ CONSTRUIDO
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarCategorias();
    });
  }

  void _cargarCategorias() {
    final categoriaProvider = Provider.of<CategoriaProvider>(
      context,
      listen: false,
    );
    categoriaProvider.cargarCategorias(generoId: widget.generoId);
  }

  @override
  Widget build(BuildContext context) {
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
                              context.go('/catalogo');
                            }
                          },
                          child: const Icon(
                            Icons.arrow_back,
                            size: 24,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.genero,
                          style: const TextStyle(
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
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Consumer<CategoriaProvider>(
                          builder: (context, categoriaProvider, child) {
                            if (categoriaProvider.isLoading) {
                              return _cargandoGrid();
                            }

                            if (categoriaProvider.categorias.isEmpty) {
                              return const Center(
                                child: Text('No hay categorías disponibles'),
                              );
                            }

                            return GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 0.75,
                                  ),
                              itemCount: categoriaProvider.categorias.length,
                              itemBuilder: (context, index) {
                                final categoria =
                                    categoriaProvider.categorias[index];
                                final nombreCategoria =
                                    categoria['nombre_categoria'];
                                final imagenPath = _obtenerImagen(
                                  nombreCategoria,
                                );

                                return CategoriaCard(
                                  titulo: nombreCategoria,
                                  imagenPath: imagenPath,
                                  onTap: () {
                                    context.push(
                                      '/catalogo-parte3',
                                      extra: {
                                        'categoria': nombreCategoria,
                                        'categoriaId':
                                            categoria['id_categoria'],
                                        'genero': widget.genero,
                                        'generoId': widget.generoId,
                                      },
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cargandoGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }
}
