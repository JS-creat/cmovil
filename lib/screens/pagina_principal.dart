import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucky/models/banner_model.dart';
import 'package:lucky/models/genero_model.dart';
import 'package:lucky/models/producto_model.dart';
import 'package:lucky/providers/banner_provider.dart';
import 'package:lucky/screens/producto_card.dart';
import 'package:lucky/services/genero_service.dart';
import 'package:lucky/services/producto_service.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:lucky/providers/carrito_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PaginaPrincipal extends StatefulWidget {
  const PaginaPrincipal({super.key});

  @override
  State<PaginaPrincipal> createState() => _PaginaPrincipalState();
}

class _PaginaPrincipalState extends State<PaginaPrincipal> {
  final PageController _pageController = PageController();
  int _paginaActual = 0;

  List<BannerModel> banners = [];

  final ProductoService _productoService = ProductoService();
  final GeneroService _generoService = GeneroService();

  // Inicializar los Futures con valores vacíos
  late Future<List<ProductoModel>> _recomendadosFuture = Future.value([]);
  late Future<List<ProductoModel>> _popularesFuture = Future.value([]);
  late Future<List<GeneroModel>> _generosFuture = Future.value([]);

  List<ProductoModel> _recomendados = [];
  List<ProductoModel> _populares = [];
  List<GeneroModel> _generos = [];

  int? _generoSeleccionado;

  bool _modoPromociones = false;

  @override
  void initState() {
    super.initState();

    // Cargar géneros primero
    _cargarGeneros();

    // Esperar al build para cargar banners y productos
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarBanners();
      _cargarProductos();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _autoScroll();
      }
    });
  }

  Future<void> _cargarBanners() async {
    final bannerProvider = Provider.of<BannerProvider>(context, listen: false);
    await bannerProvider.cargarBanners();
    if (mounted) {
      setState(() {
        banners = bannerProvider.banners;
      });
    }
  }

  void _cargarProductos() {
    final Map<String, dynamic> filtros = {};

    if (_generoSeleccionado != null && !_modoPromociones) {
      filtros['genero_id'] = _generoSeleccionado;
    }

    if (_modoPromociones) {
      filtros['en_oferta'] = true;
    }

    _recomendadosFuture = _productoService
        .getProductosRecomendados(limit: 10, filtros: filtros)
        .then((productos) {
          if (mounted) {
            setState(() {
              _recomendados = productos;
            });
          }
          return productos;
        });

    _popularesFuture = _productoService
        .getProductosPopulares(limit: 10, filtros: filtros)
        .then((productos) {
          if (mounted) {
            setState(() {
              _populares = productos;
            });
          }
          return productos;
        });
  }

  void _cargarGeneros() {
    _generosFuture = _generoService
        .getGeneros()
        .then((generos) {
          if (mounted) {
            setState(() {
              _generos = generos;
            });
          }
          return generos;
        })
        .catchError((error) {
          return <GeneroModel>[];
        });
  }

  Future<void> _refrescarProductos() async {
    ProductoService.resetPaginacion();

    final Map<String, dynamic> filtros = {};

    if (_generoSeleccionado != null && !_modoPromociones) {
      filtros['genero_id'] = _generoSeleccionado;
    }

    if (_modoPromociones) {
      filtros['en_oferta'] = true;
    }

    await Future.wait([
      _productoService
          .getProductosRecomendados(limit: 10, filtros: filtros)
          .then((productos) {
            if (mounted) {
              setState(() {
                _recomendados = productos;
              });
            }
          }),
      _productoService.getProductosPopulares(limit: 10, filtros: filtros).then((
        productos,
      ) {
        if (mounted) {
          setState(() {
            _populares = productos;
          });
        }
      }),
      _generoService.getGeneros().then((generos) {
        if (mounted) {
          setState(() {
            _generos = generos;
          });
        }
      }),
    ]);
  }

  void _cambiarFiltro({int? generoId, bool promociones = false}) {
    setState(() {
      _generoSeleccionado = generoId;
      _modoPromociones = promociones;
    });
    _cargarProductos();
  }

  void _autoScroll() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 5));
      if (!mounted) return;

      if (_pageController.hasClients && banners.isNotEmpty) {
        _paginaActual = (_paginaActual + 1) % banners.length;
        _pageController.animateToPage(
          _paginaActual,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    }
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
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(height: 16),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _barraSuperior(),
                  ),
                  const SizedBox(height: 12),
                  Container(height: 1, color: Colors.black12),
                ],
              ),
            ),

            Expanded(
              child: Container(
                color: const Color(0xFFF7F7F7),
                child: RefreshIndicator(
                  onRefresh: _refrescarProductos,
                  color: const Color(0xFFED1C24),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            const SizedBox(height: 4),
                            _generosList(),
                            const SizedBox(height: 6),
                          ],
                        ),
                      ),

                      _bannerCarrusel(),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            _buildSeccionProductos(
                              titulo: 'Recomendado',
                              future: _recomendadosFuture,
                              productos: _recomendados,
                            ),
                            _buildSeccionProductos(
                              titulo: 'Más populares',
                              future: _popularesFuture,
                              productos: _populares,
                            ),

                            const SizedBox(height: 24),
                          ],
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

  Widget _barraSuperior() {
    return Consumer<CarritoProvider>(
      builder: (context, carritoProvider, child) {
        final cantidadTotal = carritoProvider.cantidadTotal;

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset('assets/logo.png', height: 34),
                Transform.translate(
                  offset: const Offset(0, -9.5),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        onPressed: () {
                          context.push('/carrito');
                        },
                        icon: const Icon(
                          Symbols.shopping_bag,
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
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            GestureDetector(
              onTap: () {
                context.go('/busqueda');
              },
              child: Container(
                width: double.infinity,
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey),
                    SizedBox(width: 8),
                    Text(
                      'Buscar productos...',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _generosList() {
    return FutureBuilder<List<GeneroModel>>(
      future: _generosFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            _generos.isEmpty) {
          return _generosSkeleton();
        }
        return _generosChips();
      },
    );
  }

  Widget _generosSkeleton() {
    return Center(
      child: Wrap(
        spacing: 8,
        children: List.generate(5, (index) {
          return Container(
            width: 50,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(20),
            ),
          );
        }),
      ),
    );
  }

  Widget _generosChips() {
    final List<dynamic> items = [
      {'id': null, 'nombre': 'Todo'},
      ..._generos,
      {'id': null, 'nombre': 'Promociones'},
    ];

    return Center(
      child: Wrap(
        spacing: 8,
        runSpacing: 0,
        alignment: WrapAlignment.center,
        children: items.map((item) {
          final int? id = item is GeneroModel ? item.idGenero : item['id'];
          final String nombre = item is GeneroModel
              ? item.nombreGenero
              : item['nombre'];

          bool seleccionado;
          if (nombre == 'Promociones') {
            seleccionado = _modoPromociones;
          } else if (id == null) {
            seleccionado = !_modoPromociones && _generoSeleccionado == null;
          } else {
            seleccionado = !_modoPromociones && _generoSeleccionado == id;
          }

          return GestureDetector(
            onTap: () {
              if (nombre == 'Promociones') {
                _cambiarFiltro(promociones: true);
              } else if (id == null) {
                _cambiarFiltro(generoId: null);
              } else {
                _cambiarFiltro(generoId: id);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Text(
                nombre,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: seleccionado
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: Colors.black,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _bannerCarrusel() {
    if (banners.isEmpty) {
      return _bannerSkeleton();
    }

    return SizedBox(
      height: 170,
      width: double.infinity,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: banners.length,
            onPageChanged: (i) => setState(() => _paginaActual = i),
            itemBuilder: (_, i) {
              return CachedNetworkImage(
                imageUrl: banners[i].imagen,
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (context, url) =>
                    Container(color: Colors.grey.shade300),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(banners.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _paginaActual == index ? 10 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _paginaActual == index
                        ? Colors.white
                        : Colors.white.withAlpha(120),
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bannerSkeleton() {
    return SizedBox(
      height: 170,
      width: double.infinity,
      child: Container(color: Colors.grey.shade300),
    );
  }

  Widget _buildSeccionProductos({
    required String titulo,
    required Future<List<ProductoModel>> future,
    required List<ProductoModel> productos,
  }) {
    return FutureBuilder<List<ProductoModel>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            productos.isEmpty) {
          return _buildSeccionCargando(titulo);
        }
        if (snapshot.hasError) {
          return _buildSeccionError(titulo);
        }
        if (productos.isEmpty) {
          return _buildSeccionVacia(titulo);
        }
        return _seccionProductos(
          titulo: titulo,
          productos: productos
              .map(
                (p) => {
                  ...p.toMap(),
                  'imagenes': p.imagenes,
                  'imagen_principal': p.imagenPrincipal,
                },
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildSeccionCargando(String titulo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text('Ver todo', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
        SizedBox(
          height: 330,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (context, index) {
              return _buildProductoSkeleton();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductoSkeleton() {
    return Container(
      width: 170,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  width: double.infinity,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 8),
                Container(height: 16, width: 100, color: Colors.grey.shade300),
                const SizedBox(height: 8),
                Container(height: 16, width: 80, color: Colors.grey.shade300),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeccionError(String titulo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            titulo,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Center(
            child: Text(
              'Error al cargar productos',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSeccionVacia(String titulo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            titulo,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Center(
            child: Text(
              'No hay productos disponibles',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  Widget _seccionProductos({
    required String titulo,
    required List<Map<String, dynamic>> productos,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () {
                  final Map<String, dynamic> extra = {};
                  if (_modoPromociones) {
                    extra['en_oferta'] = true;
                  } else if (_generoSeleccionado != null) {
                    extra['genero_id'] = _generoSeleccionado;
                  }
                  context.go('/catalogo', extra: extra);
                },
                child: const Text(
                  'Ver todo',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
        _listaProductos(productos),
      ],
    );
  }

  Widget _listaProductos(List<Map<String, dynamic>> lista) {
    return SizedBox(
      height: 330,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: lista.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (_, i) => _productoCard(lista[i]),
      ),
    );
  }

  Widget _productoCard(Map<String, dynamic> p) {
    return ProductoCard(
      producto: p,
      onTap: () {
        context.push('/detallesProducto', extra: p);
      },
      mostrarCorazon: true,
    );
  }
}
