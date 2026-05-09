// lib/providers/categoria_provider.dart
import 'package:flutter/material.dart';
import 'package:lucky/services/categoria_service.dart';

class CategoriaProvider extends ChangeNotifier {
  final CategoriaService _categoriaService = CategoriaService();

  List<Map<String, dynamic>> _categorias = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get categorias => _categorias;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> cargarCategorias({int? generoId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categorias = await _categoriaService.getCategoriasPorGenero(generoId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void limpiar() {
    _categorias = [];
    notifyListeners();
  }
}
