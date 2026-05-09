import 'package:flutter/material.dart';
import 'package:lucky/models/carrito_model.dart';
import 'package:lucky/services/carrito_service.dart';
import 'package:lucky/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class CarritoProvider with ChangeNotifier {
  final CarritoService _service = CarritoService();

  CarritoModel? _carrito;
  bool _isLoading = false;
  String? _error;

  CarritoModel? get carrito => _carrito;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Map<String, dynamic>> get productos {
    if (_carrito == null) return [];
    return _carrito!.items.map((item) => item.toMap()).toList();
  }

  double get total => _carrito?.total ?? 0;

  int get cantidadTotal => _carrito?.cantidadTotal ?? 0;

  Future<void> cargarCarrito(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!authProvider.isLoggedIn) {
      _carrito = null;
      notifyListeners();
      return;
    }

    final idUsuario = authProvider.usuario!.id;
    if (idUsuario <= 0) {
      _error = 'Usuario inválido';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _carrito = await _service.obtenerCarrito(idUsuario);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> agregarProducto(
    BuildContext context,
    Map<String, dynamic> productoMap,
  ) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!authProvider.isLoggedIn) {
      _error = 'Debes iniciar sesión para agregar al carrito';
      notifyListeners();
      return;
    }

    final idUsuario = authProvider.usuario!.id;
    if (idUsuario <= 0) {
      _error = 'Usuario inválido';
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final idVariante = productoMap['id_variante'];

      if (idVariante == null) {
        throw Exception('Error: El producto no tiene ID de variante');
      }

      _carrito = await _service.agregarProducto(
        idUsuario: idUsuario,
        idVariante: idVariante,
        cantidad: productoMap['cantidad'] ?? 1,
      );

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> incrementarCantidad(BuildContext context, int index) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!authProvider.isLoggedIn || _carrito == null) return;

    final idUsuario = authProvider.usuario!.id;
    if (idUsuario <= 0) return;

    final item = _carrito!.items[index];

    try {
      _carrito = await _service.actualizarCantidad(
        idUsuario: idUsuario,
        idDetalleCarrito: item.idDetalle,
        cantidad: item.cantidad + 1,
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> decrementarCantidad(BuildContext context, int index) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!authProvider.isLoggedIn || _carrito == null) return;

    final idUsuario = authProvider.usuario!.id;
    if (idUsuario <= 0) return;

    final item = _carrito!.items[index];
    if (item.cantidad <= 1) return;

    try {
      _carrito = await _service.actualizarCantidad(
        idUsuario: idUsuario,
        idDetalleCarrito: item.idDetalle,
        cantidad: item.cantidad - 1,
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> eliminarProducto(BuildContext context, int index) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!authProvider.isLoggedIn || _carrito == null) return;

    final idUsuario = authProvider.usuario!.id;
    if (idUsuario <= 0) return;

    final item = _carrito!.items[index];

    try {
      _carrito = await _service.eliminarProducto(
        idUsuario: idUsuario,
        idDetalleCarrito: item.idDetalle,
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> limpiarCarrito(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!authProvider.isLoggedIn || _carrito == null) return;

    final idUsuario = authProvider.usuario!.id;
    if (idUsuario <= 0) return;

    try {
      await _service.limpiarCarrito(idUsuario);
      _carrito = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void cerrarSesion() {
    _carrito = null;
    _error = null;
    notifyListeners();
  }
}
