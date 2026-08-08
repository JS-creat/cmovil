import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:lucky/models/producto_model.dart';
import 'package:lucky/models/genero_model.dart';
import 'package:lucky/services/producto_service.dart';
import 'package:lucky/services/genero_service.dart';
import 'package:lucky/screens/producto_card.dart';
import 'package:lucky/providers/favoritos_provider.dart';
import 'package:lucky/providers/auth_provider.dart';

class Busqueda extends StatefulWidget {
  const Busqueda({super.key});

  @override
  State<Busqueda> createState() => _BusquedaState();
}

class _BusquedaState extends State<Busqueda> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ProductoService _productoService = ProductoService();
  final GeneroService _generoService = GeneroService();

  List<ProductoModel> _resultados = [];
  List<GeneroModel> _generos = [];

  bool _buscando = false;
  bool _yaBusco = false;
  String? _error;

  int? _generoSeleccionado;
  bool _modoPromociones = false;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _cargarGeneros();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _cargarGeneros() async {
    try {
      final generos = await _generoService.getGeneros();
      if (mounted) setState(() => _generos = generos);
    } catch (_) {
      // Si fallan los géneros, igual se puede buscar sin ese filtro
    }
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      _buscar();
    });
  }

  Future<void> _buscar() async {
    final query = _controller.text.trim();

    if (query.isEmpty) {
      setState(() {
        _resultados = [];
        _yaBusco = false;
        _error = null;
      });
      return;
    }

    setState(() {
      _buscando = true;
      _yaBusco = true;
      _error = null;
    });

    try {
      final Map<String, dynamic> filtros = {};
      if (_modoPromociones) {
        filtros['en_oferta'] = true;
      } else if (_generoSeleccionado != null) {
        filtros['genero_id'] = _generoSeleccionado;
      }

      final resultados = await _productoService.buscarProductos(
        query,
        limit: 30,
        filtros: filtros,
      );

      if (mounted) {
        setState(() {
          _resultados = resultados;
          _buscando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _buscando = false;
        });
      }
    }
  }

  void _cambiarFiltro({int? generoId, bool promociones = false}) {
    setState(() {
      _generoSeleccionado = generoId;
      _modoPromociones = promociones;
    });
    if (_controller.text.trim().isNotEmpty) {
      _buscar();
    }
  }

  void _limpiarBusqueda() {
    _controller.clear();
    setState(() {
      _resultados = [];
      _yaBusco = false;
      _error = null;
    });
    _focusNode.requestFocus();
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
              padding: const EdgeInsets.fromLTRB(12, 10, 16, 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/');
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.arrow_back,
                        size: 24,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Container(
                      height: 46,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.black.withOpacity(0.06)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              focusNode: _focusNode,
                              textInputAction: TextInputAction.search,
                              onChanged: _onQueryChanged,
                              onSubmitted: (_) {
                                _debounce?.cancel();
                                _buscar();
                              },
                              decoration: const InputDecoration(
                                hintText: '¿Qué estás buscando hoy?',
                                hintStyle: TextStyle(
                                  color: Colors.black38,
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          if (_controller.text.isNotEmpty)
                            GestureDetector(
                              onTap: _limpiarBusqueda,
                              child: const Icon(
                                Icons.close,
                                size: 18,
                                color: Colors.black45,
                              ),
                            ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              _debounce?.cancel();
                              _buscar();
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.search,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 1, color: Colors.black12),

            // ================= FILTROS =================
            if (_yaBusco) ...[
              const SizedBox(height: 12),
              _buildFiltros(),
            ],

            // ================= CONTENIDO =================
            Expanded(
              child: Container(
                color: const Color(0xFFF7F7F7),
                child: _buildContenido(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltros() {
    final List<dynamic> items = [
      {'id': null, 'nombre': 'Todo'},
      ..._generos,
      {'id': null, 'nombre': 'Promociones'},
    ];

    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final int? id = item is GeneroModel ? item.idGenero : item['id'];
          final String nombre =
              item is GeneroModel ? item.nombreGenero : item['nombre'];
          final bool esPromocion = nombre == 'Promociones';

          bool seleccionado;
          if (esPromocion) {
            seleccionado = _modoPromociones;
          } else if (id == null) {
            seleccionado = !_modoPromociones && _generoSeleccionado == null;
          } else {
            seleccionado = !_modoPromociones && _generoSeleccionado == id;
          }

          return GestureDetector(
            onTap: () {
              if (esPromocion) {
                _cambiarFiltro(promociones: true);
              } else {
                _cambiarFiltro(generoId: id);
              }
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: seleccionado
                    ? (esPromocion ? const Color(0xFFED1C24) : Colors.black)
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: seleccionado
                      ? Colors.transparent
                      : Colors.black.withOpacity(0.1),
                ),
              ),
              child: Text(
                nombre,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: seleccionado ? FontWeight.w600 : FontWeight.w500,
                  color: seleccionado
                      ? Colors.white
                      : (esPromocion ? const Color(0xFFED1C24) : Colors.black87),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContenido() {
    if (!_yaBusco) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Symbols.search, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                'Busca entre todos nuestros productos',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (_buscando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Symbols.error, size: 56, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'Ocurrió un error al buscar',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _buscar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_resultados.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Symbols.search_off,
                size: 64,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                'No se encontraron productos',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Intenta con otra palabra clave',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      );
    }

    // 🟢 Igual que en la página principal: se consulta a FavoritosProvider
    // para que el corazón refleje el estado real y pueda tocarse.
    return Consumer<FavoritosProvider>(
      builder: (context, favoritosProvider, _) {
        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              sliver: SliverToBoxAdapter(
                child: Text(
                  '${_resultados.length} artículo${_resultados.length == 1 ? '' : 's'}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 170 / 320,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final p = _resultados[index];
                  final datosProducto = {
                    ...p.toMap(),
                    'estado': p.toMap()['estado_producto'] ?? 1,
                    'estado_producto': p.toMap()['estado_producto'] ?? 1,
                    'imagenes': p.imagenes,
                    'imagen_principal': p.imagenPrincipal,
                  };

                  final esFav = favoritosProvider.esFavorito(datosProducto);

                  return ProductoCard(
                    producto: datosProducto,
                    onTap: () => context.push(
                      '/detallesProducto',
                      extra: datosProducto,
                    ),
                    mostrarCorazon: true,
                    esFavorito: esFav,
                    onCorazonTap: () async {
                      final authProvider = Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      );

                      if (!authProvider.isLoggedIn) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Debes iniciar sesión para agregar a favoritos',
                            ),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        context.go('/cuenta/iniciarSesion');
                        return;
                      }

                      final seAgrego = await favoritosProvider.toggleFavorito(
                        datosProducto,
                        authProvider,
                      );

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              seAgrego
                                  ? 'Agregado a favoritos'
                                  : 'Eliminado de favoritos',
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  );
                }, childCount: _resultados.length),
              ),
            ),
          ],
        );
      },
    );
  }
}