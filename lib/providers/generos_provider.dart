import 'package:flutter/material.dart';
import 'package:lucky/models/genero_model.dart';
import 'package:lucky/services/genero_service.dart';

class GenerosProvider extends ChangeNotifier {
  List<GeneroModel> _generos = [];
  bool _cargando = false;
  bool _cargados = false;
  String? _error;

  List<GeneroModel> get generos => _generos;
  bool get cargando => _cargando;
  bool get cargados => _cargados;
  String? get error => _error;

  final GeneroService _generoService = GeneroService();

  Future<void> cargarGeneros({bool forzarRecarga = false}) async {
    if (_cargados && !forzarRecarga) return;

    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      _generos = await _generoService.getGeneros();
      _cargados = true;
    } catch (e) {
      _error = e.toString();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }
}
