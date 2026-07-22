// screens/detalles_producto.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucky/providers/auth_provider.dart';
import 'package:lucky/providers/favoritos_provider.dart';
import 'package:lucky/utils/api_config.dart';
import 'package:provider/provider.dart';
import 'package:lucky/providers/carrito_provider.dart';
import 'package:lucky/models/producto_model.dart';
import 'package:lucky/models/variante_model.dart';
import 'package:material_symbols_icons/symbols.dart';

class DetallesProducto extends StatefulWidget {
  final Map<String, dynamic> producto;

  const DetallesProducto({super.key, required this.producto});

  @override
  State<DetallesProducto> createState() => _DetallesProductoState();
}

class _DetallesProductoState extends State<DetallesProducto> {
  String? _tallaSeleccionada;
  String? _colorSeleccionado;
  int _paginaActual = 0;
  final PageController _pageController = PageController();

  // Convertir el Map a ProductoModel para facilitar el acceso
  late ProductoModel _producto;
  VarianteModel? _varianteSeleccionada;

  // Listas dinámicas basadas en las variantes del producto
  List<String> get _tallasDisponibles {
    return _producto.tallas;
  }

  List<String> get _coloresDisponibles {
    return _producto.colores;
  }

  // Obtener colores disponibles para la talla seleccionada
  List<String> get _coloresPorTalla {
    if (_tallaSeleccionada == null) return _coloresDisponibles;
    return _producto.getColoresPorTalla(_tallaSeleccionada!);
  }

  // 🟢 NUEVO: obtener tallas disponibles para el color seleccionado.
  // El flujo ahora es: primero se elige color, luego se habilitan las tallas
  // que sí tienen stock para ese color específico.
  List<String> _tallasPorColor(String color) {
    return _producto.variantes
        .where((v) => v.color == color && v.stock > 0)
        .map((v) => v.talla)
        .toSet()
        .toList();
  }

  // Verificar si la combinación talla/color tiene stock
  bool get _combinacionDisponible {
    if (_tallaSeleccionada == null) return false;

    _varianteSeleccionada = _producto.getVariante(
      talla: _tallaSeleccionada!,
      color: _colorSeleccionado,
    );

    return _varianteSeleccionada != null && _varianteSeleccionada!.disponible;
  }

  @override
  void initState() {
    super.initState();
    // Inicializar el modelo
    _producto = ProductoModel.fromJson(widget.producto);

    // 🟢 FIX: ya no se preselecciona talla/color automáticamente.
    // El usuario debe elegir explícitamente ambos antes de poder
    // agregar al carrito (el botón se mantiene deshabilitado hasta
    // que _combinacionDisponible sea true).
  }

  // GETTER - Incluye imagen principal y galería
  List<String> get imagenesProducto {
    List<String> todasLasImagenes = [];

    // 1. Agregar imagen principal (si existe)
    // 🟢 FIX: imagenPrincipal llega como solo el nombre del archivo
    // (ej: "6a0e637701fea.jpg"), no como URL completa. Usamos el helper
    // ApiConfig.imagenProducto() que arma correctamente la URL pública.
    if (_producto.imagenPrincipal.isNotEmpty) {
      String imgPrincipal = ApiConfig.imagenProducto(_producto.imagenPrincipal);
      if (imgPrincipal.isNotEmpty) {
        todasLasImagenes.add(imgPrincipal);
      }
    }

    // 2. Agregar imágenes de galería (sin duplicar la principal)
    for (var filename in _producto.imagenes) {
      String urlTransformada = ApiConfig.imagenProducto(filename);
      if (urlTransformada.isNotEmpty &&
          !todasLasImagenes.contains(urlTransformada)) {
        todasLasImagenes.add(urlTransformada);
      }
    }

    return todasLasImagenes;
  }

  // TRANSFORMAR IMAGEN PRINCIPAL (por si se usa)
  String get imagenPrincipalTransformada {
    return ApiConfig.imagenProducto(_producto.imagenPrincipal);
  }

  String _formatearPrecio(dynamic precio) {
    if (precio == null) return '';

    double valor = precio is int
        ? precio.toDouble()
        : (precio is double ? precio : double.tryParse(precio.toString()) ?? 0);

    return valor.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Método para mostrar el overlay de confirmación
  void _mostrarMensajeConfirmacion(BuildContext context) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            color: Colors.green,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.green,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Agregado al carrito',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 1), () {
      overlayEntry.remove();
    });
  }

  // Método para verificar si el usuario está logueado
  void _verificarUsuarioYAgregarCarrito(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!authProvider.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesión para agregar al carrito'),
          duration: Duration(seconds: 2),
        ),
      );
      context.go('/cuenta/iniciarSesion');
      return;
    }

    _agregarAlCarrito(context);
  }

  void _agregarAlCarrito(BuildContext context) {
    final carritoProvider = Provider.of<CarritoProvider>(
      context,
      listen: false,
    );

    final productoCarrito = {
      'id': _producto.id,
      'id_variante': _varianteSeleccionada?.id,
      'titulo': _producto.titulo,
      'precio': _producto.precio,
      'precioAntes': _producto.precioAntes,
      'descuento': _producto.descuento,
      'imagenes': _producto.imagenes.map((filename) {
        return ApiConfig.imagenProducto(filename);
      }).toList(),
      'imagen_principal': ApiConfig.imagenProducto(_producto.imagenPrincipal),
      'talla': _tallaSeleccionada,
      'color': _colorSeleccionado,
      'cantidad': 1,
    };

    carritoProvider.agregarProducto(context, productoCarrito);
    _mostrarMensajeConfirmacion(context);
  }

  @override
  Widget build(BuildContext context) {
    int descuentoPorcentaje = _producto.descuento ?? 0;
    final precioAntesValor = _producto.precioAntes;
    bool tienePrecioAnterior =
        precioAntesValor != null && precioAntesValor > 0;
    // El precio principal solo va en rojo si hay descuento/precio anterior real,
    // si no, se ve negro-negrita igual que en la tarjeta del catálogo.
    final Color colorPrecioPrincipal =
        tienePrecioAnterior ? const Color(0xFFED1C24) : Colors.black;

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
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 7,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            context.pop();
                          },
                          child: const Icon(
                            Icons.arrow_back,
                            size: 24,
                            color: Colors.black,
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
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Imagen del producto
                    SizedBox(
                      height: 500,
                      width: double.infinity,
                      child: Stack(
                        children: [
                          PageView.builder(
                            controller: _pageController,
                            itemCount: imagenesProducto.length,
                            onPageChanged: (index) {
                              setState(() {
                                _paginaActual = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              return Container(
                                color: Colors.white,
                                child: Image.network(
                                  imagenesProducto[index],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value:
                                                loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                : null,
                                          ),
                                        );
                                      },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: Icon(
                                          Symbols.image,
                                          size: 50,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                          Positioned(
                            bottom: 16,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(imagenesProducto.length, (
                                index,
                              ) {
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
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
                    ),

                    // Información del producto
                    Container(
                      color: const Color(0xFFF7F7F7),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _producto.titulo,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(height: 8),

                            Row(
                              children: [
                                Text(
                                  'S/ ${_formatearPrecio(_producto.precio)}',
                                  style: TextStyle(
                                    color: colorPrecioPrincipal,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                if (tienePrecioAnterior) ...[
                                  const SizedBox(height: 4),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Stack(
                                      children: [
                                        Text(
                                          'S/ ${_formatearPrecio(_producto.precioAntes)}',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                        Positioned.fill(
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Container(
                                              height: 1,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],

                                if (descuentoPorcentaje > 0) ...[
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFED1C24),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '-$descuentoPorcentaje%',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 8),

                            if (_producto.descripcion.isNotEmpty) ...[
                              const Text(
                                'Descripción:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _producto.descripcion,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            if (_coloresDisponibles.isNotEmpty) ...[
                              const Text(
                                'Color:',
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 12),

                              Wrap(
                                spacing: 8,
                                children: _coloresDisponibles.map((colorNombre) {
                                  bool seleccionado =
                                      colorNombre == _colorSeleccionado;
                                  // 🟢 FIX: el color se elige primero, así que su
                                  // stock se verifica contra CUALQUIER talla, no
                                  // contra una talla que todavía no existe.
                                  bool tieneStock = _producto.variantes.any(
                                    (v) => v.color == colorNombre && v.stock > 0,
                                  );

                                  return GestureDetector(
                                    onTap: tieneStock
                                        ? () {
                                            setState(() {
                                              if (seleccionado) {
                                                // 🟢 Toggle: tocar de nuevo deselecciona
                                                _colorSeleccionado = null;
                                                _tallaSeleccionada = null;
                                              } else {
                                                _colorSeleccionado = colorNombre;
                                                // Al cambiar de color, se resetea la
                                                // talla porque puede no ser válida
                                                // para el nuevo color.
                                                _tallaSeleccionada = null;
                                              }
                                            });
                                          }
                                        : null,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: seleccionado
                                            ? Colors.grey.shade300
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: seleccionado
                                              ? Colors.black
                                              : (tieneStock
                                                    ? Colors.grey.shade500
                                                    : Colors.grey.shade300),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        colorNombre,
                                        style: TextStyle(
                                          color: tieneStock
                                              ? Colors.black
                                              : Colors.grey.shade400,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 16),
                            ],

                            if (_tallasDisponibles.isNotEmpty) ...[
                              const Text(
                                'Talla:',
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 12),

                              // 🟢 Aviso mientras no se eligió color todavía
                              if (_colorSeleccionado == null) ...[
                                Text(
                                  'Selecciona un color primero',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade500,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],

                              Wrap(
                                spacing: 8,
                                children: _tallasDisponibles.map((talla) {
                                  bool seleccionada =
                                      talla == _tallaSeleccionada;
                                  // 🟢 FIX: la talla solo se puede tocar si ya
                                  // hay un color elegido, y su stock se valida
                                  // específicamente contra ese color.
                                  bool habilitadaPorColor =
                                      _colorSeleccionado != null;
                                  bool tieneStock = habilitadaPorColor &&
                                      _tallasPorColor(_colorSeleccionado!)
                                          .contains(talla);

                                  return GestureDetector(
                                    onTap: tieneStock
                                        ? () {
                                            setState(() {
                                              if (seleccionada) {
                                                // 🟢 Toggle: tocar de nuevo deselecciona
                                                _tallaSeleccionada = null;
                                              } else {
                                                _tallaSeleccionada = talla;
                                              }
                                            });
                                          }
                                        : null,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: seleccionada
                                            ? Colors.grey.shade300
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: seleccionada
                                              ? Colors.black
                                              : (tieneStock
                                                    ? Colors.grey.shade500
                                                    : Colors.grey.shade300),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        talla,
                                        style: TextStyle(
                                          color: tieneStock
                                              ? Colors.black
                                              : Colors.grey.shade400,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 32),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.black12, width: 1),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Botón "A favoritos"
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final favoritosProvider =
                            Provider.of<FavoritosProvider>(
                              context,
                              listen: false,
                            );
                        final authProvider = Provider.of<AuthProvider>(
                          context,
                          listen: false,
                        );

                        final seAgrego = await favoritosProvider.toggleFavorito(
                          widget.producto,
                          authProvider,
                        );

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
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: Colors.grey.shade500,
                            width: 1,
                          ),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Consumer<FavoritosProvider>(
                        builder: (context, favoritosProvider, child) {
                          final esFavorito = favoritosProvider.esFavorito(
                            widget.producto,
                          );
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                esFavorito
                                    ? Symbols.favorite
                                    : Symbols.favorite,
                                fill: esFavorito ? 1 : 0,
                                size: 20,
                                color: esFavorito
                                    ? Colors.black
                                    : Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                esFavorito ? 'En favoritos' : 'Agregar a favoritos',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Botón "Al carrito"
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _combinacionDisponible
                          ? () => _verificarUsuarioYAgregarCarrito(context)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _combinacionDisponible
                            ? const Color(0xFFED1C24)
                            : Colors.grey.shade400,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Symbols.shopping_bag,
                            size: 20,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _combinacionDisponible ? 'Añadir al carrito' : 'Sin stock',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}