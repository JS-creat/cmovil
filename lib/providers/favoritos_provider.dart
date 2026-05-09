import 'package:flutter/material.dart';
import 'package:lucky/services/favorito_service.dart';
import 'package:lucky/providers/auth_provider.dart';

class FavoritosProvider with ChangeNotifier {
  final FavoritoService _service = FavoritoService();

  List<Map<String, dynamic>> _productosFavoritos = [];
  int? _idUsuarioActual;

  List<Map<String, dynamic>> get productosFavoritos => _productosFavoritos;
  bool get tieneFavoritos => _productosFavoritos.isNotEmpty;

  // Cargar favoritos del usuario actual
  Future<void> cargarFavoritos(AuthProvider authProvider) async {
    if (!authProvider.isLoggedIn) {
      _productosFavoritos = [];
      _idUsuarioActual = null;
      notifyListeners();
      return;
    }

    final idUsuario = authProvider.usuario!.id;
    if (idUsuario <= 0) return;

    // Si es el mismo usuario, no recargar
    if (_idUsuarioActual == idUsuario && _productosFavoritos.isNotEmpty) {
      return;
    }

    final favoritos = await _service.obtenerFavoritos(idUsuario);
    _productosFavoritos = favoritos;
    _idUsuarioActual = idUsuario;
    notifyListeners();
  }

  bool esFavorito(Map<String, dynamic> producto) {
    final idProducto = producto['id'];
    if (idProducto == null) return false;
    return _productosFavoritos.any((p) => p['id'] == idProducto);
  }

  Future<void> agregarFavorito(
    Map<String, dynamic> producto,
    AuthProvider authProvider,
  ) async {
    if (!authProvider.isLoggedIn) return;

    final idUsuario = authProvider.usuario!.id;
    final idProducto = producto['id'];

    if (idProducto == null) {
      print('Error: Producto sin ID');
      return;
    }

    final success = await _service.agregarFavorito(idUsuario, idProducto);
    if (success) {
      _productosFavoritos.add({...producto, 'esFavorito': true});
      notifyListeners();
    }
  }

  Future<void> eliminarFavorito(
    Map<String, dynamic> producto,
    AuthProvider authProvider,
  ) async {
    if (!authProvider.isLoggedIn) return;

    final idUsuario = authProvider.usuario!.id;
    final idProducto = producto['id'];

    if (idProducto == null) {
      print('Error: Producto sin ID');
      return;
    }

    final success = await _service.eliminarFavorito(idUsuario, idProducto);
    if (success) {
      _productosFavoritos.removeWhere((p) => p['id'] == idProducto);
      notifyListeners();
    }
  }

  // 👇 MODIFICADO: Ahora devuelve true si se agregó, false si se eliminó
  Future<bool> toggleFavorito(
    Map<String, dynamic> producto,
    AuthProvider authProvider,
  ) async {
    final eraFavorito = esFavorito(producto);

    if (eraFavorito) {
      await eliminarFavorito(producto, authProvider);
      return false; // Se eliminó
    } else {
      await agregarFavorito(producto, authProvider);
      return true; // Se agregó
    }
  }

  void limpiarFavoritos() {
    _productosFavoritos.clear();
    _idUsuarioActual = null;
    notifyListeners();
  }

  // Llamar cuando el usuario cierra sesión
  void cerrarSesion() {
    _productosFavoritos = [];
    _idUsuarioActual = null;
    notifyListeners();
  }
}
