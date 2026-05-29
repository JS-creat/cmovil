import 'dart:async';
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
import 'package:lucky/utils/api_config.dart';

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

  late Future<List<ProductoModel>> _recomendadosFuture = Future.value([]);
  late Future<List<ProductoModel>> _popularesFuture = Future.value([]);
  late Future<List<GeneroModel>> _generosFuture = Future.value([]);

  List<ProductoModel> _recomendados = [];
  List<ProductoModel> _populares = [];
  List<GeneroModel> _generos = [];

  int? _generoSeleccionado;
  bool _modoPromociones = false;

  Timer? _scrollTimer;

  static const double _alturaCard = 340;

  @override
  void initState() {
    super.initState();
    _cargarGeneros();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarBanners();
      _cargarProductos();
    });
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _cargarBanners() async {
    final bannerProvider = Provider.of<BannerProvider>(context, listen: false);
    await bannerProvider.cargarBanners();
    if (mounted) {
      setState(() {
        banners = bannerProvider.banners;
      });
      _iniciarAutoScroll();
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
          if (mounted) setState(() => _recomendados = productos);
          return productos;
        });

    _popularesFuture = _productoService
        .getProductosPopulares(limit: 10, filtros: filtros)
        .then((productos) {
          if (mounted) setState(() => _populares = productos);
          return productos;
        });
  }

  void _cargarGeneros() {
    _generosFuture = _generoService
        .getGeneros()
        .then((generos) {
          if (mounted) setState(() => _generos = generos);
          return generos;
        })
        .catchError((_) => <GeneroModel>[]);
  }

  Future<void> _refrescarProductos() async {
    ProductoService.resetPaginacion();
    final Map<String, dynamic> filtros = {};
    if (_generoSeleccionado != null && !_modoPromociones) {
      filtros['genero_id'] = _generoSeleccionado;
    }
    if (_modoPromociones) filtros['en_oferta'] = true;

    await Future.wait([
      _productoService
          .getProductosRecomendados(limit: 10, filtros: filtros)
          .then((p) {
            if (mounted) setState(() => _recomendados = p);
          }),
      _productoService.getProductosPopulares(limit: 10, filtros: filtros).then((
        p,
      ) {
        if (mounted) setState(() => _populares = p);
      }),
      _generoService.getGeneros().then((g) {
        if (mounted) setState(() => _generos = g);
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

  void _iniciarAutoScroll() {
    _scrollTimer?.cancel();
    _scrollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || banners.isEmpty || !_pageController.hasClients) return;
      _paginaActual = (_paginaActual + 1) % banners.length;
      _pageController.animateToPage(
        _paginaActual,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ─── MEJORA: fondo ligeramente más cálido para el body ───
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header ───
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(children: [_barraSuperior()]),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refrescarProductos,
                color: const Color(0xFFED1C24),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 12),
                    _generosList(),
                    const SizedBox(height: 16),
                    _bannerCarrusel(),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          // ─── Sección Recomendados ───
                          // Trae productos ordenados por score de recomendación
                          // (más recientes / mejor valorados para el usuario)
                          _buildSeccionProductos(
                            titulo: 'Recomendado para ti',
                            future: _recomendadosFuture,
                            productos: _recomendados,
                          ),
                          // ─── Sección Populares ───
                          // Trae productos ordenados por ventas o visitas
                          _buildSeccionProductos(
                            titulo: 'Los más populares',
                            future: _popularesFuture,
                            productos: _populares,
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
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
                Image.asset('assets/logo.png', height: 32),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      onPressed: () => context.push('/carrito'),
                      icon: const Icon(
                        Symbols.shopping_bag,
                        size: 26,
                        color: Colors.black,
                      ),
                    ),
                    if (cantidadTotal > 0)
                      Positioned(
                        right: 4,
                        top: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFFED1C24),
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            cantidadTotal > 9 ? '9+' : cantidadTotal.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // ─── Barra de búsqueda ───
            GestureDetector(
              onTap: () => context.go('/busqueda'),
              child: Container(
                width: double.infinity,
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.black.withOpacity(0.06)),
                ),
                child: const Row(
                  children: [
                    Icon(Symbols.search, color: Colors.black45, size: 20),
                    SizedBox(width: 10),
                    Text(
                      '¿Qué estás buscando hoy?',
                      style: TextStyle(
                        color: Colors.black38,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
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

  // ─── Géneros / Filtros ───
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
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 5,
        itemBuilder: (context, index) => Container(
          width: 72,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _generosChips() {
    final List<dynamic> items = [
      {'id': null, 'nombre': 'Todo'},
      ..._generos,
      {'id': null, 'nombre': 'Promociones'},
    ];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
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

          // ─── MEJORA: chip con ícono de fuego para Promociones ───
          final bool esPromocion = nombre == 'Promociones';

          return GestureDetector(
            onTap: () {
              if (esPromocion) {
                _cambiarFiltro(promociones: true);
              } else if (id == null) {
                _cambiarFiltro(generoId: null);
              } else {
                _cambiarFiltro(generoId: id);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: EdgeInsets.symmetric(horizontal: esPromocion ? 14 : 18),
              decoration: BoxDecoration(
                color: seleccionado
                    ? (esPromocion ? const Color(0xFFED1C24) : Colors.black)
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: seleccionado
                      ? Colors.transparent
                      : Colors.black.withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: seleccionado
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (esPromocion) ...[
                      Icon(
                        Symbols.local_fire_department,
                        size: 14,
                        color: seleccionado
                            ? Colors.white
                            : const Color(0xFFED1C24),
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      nombre,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: seleccionado
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: seleccionado
                            ? Colors.white
                            : (esPromocion
                                  ? const Color(0xFFED1C24)
                                  : Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Banner Carrusel ───
  Widget _bannerCarrusel() {
    if (banners.isEmpty) return _bannerSkeleton();

    return Container(
      height: 170,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: banners.length,
              onPageChanged: (i) => setState(() => _paginaActual = i),
              itemBuilder: (_, i) {
                final String urlImagen = ApiConfig.imagenBanner(
                  banners[i].imagen,
                );

                return CachedNetworkImage(
                  imageUrl: urlImagen,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) =>
                      Container(color: Colors.grey.shade200),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey.shade100,
                    child: const Center(
                      child: Icon(Symbols.broken_image, color: Colors.grey),
                    ),
                  ),
                );
              },
            ),
            // ─── Indicadores de página ───
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(banners.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _paginaActual == index ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _paginaActual == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.45),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bannerSkeleton() {
    return Container(
      height: 170,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(18),
      ),
    );
  }

  // ─── Sección de productos (Recomendados / Populares) ───
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
        if (snapshot.hasError) return const SizedBox.shrink();
        if (productos.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Encabezado de sección ───
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      titulo,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
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
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFED1C24).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Ver todo',
                        style: TextStyle(
                          color: Color(0xFFED1C24),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ─── CORRECCIÓN: SizedBox con altura suficiente para ProductoCard ───
            // Si ProductoCard sigue desbordando, aumenta _alturaCard
            SizedBox(
              height: _alturaCard,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: productos.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final p = productos[i];
                  final datosProducto = {
                    ...p.toMap(),
                    'estado': p.toMap()['estado_producto'] ?? 1,
                    'estado_producto': p.toMap()['estado_producto'] ?? 1,
                    'imagenes': p.imagenes,
                    'imagen_principal': p.imagenPrincipal,
                  };

                  return ProductoCard(
                    producto: datosProducto,
                    onTap: () =>
                        context.push('/detallesProducto', extra: datosProducto),
                    mostrarCorazon: true,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // ─── Estado de carga (skeleton) ───
  Widget _buildSeccionCargando(String titulo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  titulo,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Ver todo',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: _alturaCard,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (context, index) => _skeletonCard(),
          ),
        ),
      ],
    );
  }

  // ─── MEJORA: Skeleton animado para las cards ───
  Widget _skeletonCard() {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen placeholder
          Container(
            height: 190,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 12, width: 110, color: Colors.grey.shade300),
                const SizedBox(height: 6),
                Container(height: 12, width: 80, color: Colors.grey.shade300),
                const SizedBox(height: 10),
                Container(height: 16, width: 60, color: Colors.grey.shade300),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
