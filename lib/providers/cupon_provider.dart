import 'package:flutter/material.dart';
import 'package:lucky/models/Cupon_model.dart';
import 'package:lucky/services/cupon_service.dart';

class CuponProvider with ChangeNotifier {
  final CuponService _service = CuponService();

  List<CuponModel> _cupones = [];
  CuponModel? _cuponSeleccionado;
  bool _isLoading = false;
  bool _isValidando = false;
  String? _error;

  List<CuponModel> get cupones => _cupones;
  CuponModel? get cuponSeleccionado => _cuponSeleccionado;
  bool get isLoading => _isLoading;
  bool get isValidando => _isValidando;
  String? get error => _error;
  bool get tieneCupon => _cuponSeleccionado != null;

  Future<void> cargarCupones() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cupones = await _service.obtenerDisponibles();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Valida el cupón contra el backend antes de seleccionarlo
  Future<bool> validarYSeleccionar({
    required CuponModel cupon,
    required double subtotal,
  }) async {
    _isValidando = true;
    _error = null;
    notifyListeners();

    try {
      final resultado = await _service.validarCupon(
        codigo: cupon.codigo,
        montoCarrito: subtotal,
      );

      // Si el backend responde éxito, el cupón es válido
      _cuponSeleccionado = cupon;
      _isValidando = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isValidando = false;
      notifyListeners();
      return false;
    }
  }

  void seleccionarCuponDirecto(CuponModel cupon) {
    _cuponSeleccionado = cupon;
    _error = null;
    notifyListeners();
  }

  void quitarCupon() {
    _cuponSeleccionado = null;
    _error = null;
    notifyListeners();
  }

  /// Cálculo local del descuento (fallback si el backend ya lo validó)
  double calcularDescuento(double subtotal) {
    if (_cuponSeleccionado == null) return 0.0;
    if (subtotal < _cuponSeleccionado!.montoCompraMinima) return 0.0;

    if (_cuponSeleccionado!.tipoDescuento == 'porcentaje') {
      final desc = subtotal * (_cuponSeleccionado!.valorDescuento / 100);
      return double.parse(desc.toStringAsFixed(2));
    } else {
      return _cuponSeleccionado!.valorDescuento;
    }
  }

  double calcularTotal(double subtotal, double costoEnvio) {
    final descuento = calcularDescuento(subtotal);
    final total = subtotal + costoEnvio - descuento;
    return total < 0 ? 0.0 : total;
  }
}