import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucky/screens/producto_card.dart';
import 'package:lucky/services/producto_service.dart';
import 'package:lucky/models/producto_model.dart';

class CatalogoParte3 extends StatefulWidget {
  final String categoria;
  final int? categoriaId;
  final String genero;
  final int? generoId;

  const CatalogoParte3({
    super.key,
    required this.categoria,
    required this.categoriaId,
    required this.genero,
    this.generoId,
  });

  @override
  State<CatalogoParte3> createState() => _CatalogoParte3State();
}

class _CatalogoParte3State extends State<CatalogoParte3> {
  final ProductoService _productoService = ProductoService();
  List<ProductoModel> _productos = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final productos = await _productoService.getProductos(
        page: 0,
        limit: 50,
        categoriaId: widget.categoriaId,
        generoId: widget.generoId,
      );

      setState(() {
        _productos = productos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _refrescar() async {
    await _cargarProductos();
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.categoria,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                widget.genero,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
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
              child: RefreshIndicator(
                onRefresh: _refrescar,
                color: const Color(0xFFED1C24),
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFED1C24),
                        ),
                      )
                    : _error != null
                    ? _errorState()
                    : _productos.isEmpty
                    ? _emptyState()
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 170 / 320,
                            ),
                        itemCount: _productos.length,
                        itemBuilder: (context, index) {
                          final producto = _productos[index];
                          return ProductoCard(
                            producto: producto.toMap(),
                            onTap: () {
                              context.push(
                                '/detallesProducto',
                                extra: producto.toMap(),
                              );
                            },
                            mostrarCorazon: true,
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

  Widget _errorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            'Error al cargar productos',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Intenta de nuevo más tarde',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _cargarProductos,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFED1C24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Reintentar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay productos en esta categoría',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Pronto tendremos más productos para ti',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
