import 'package:flutter/material.dart';
import 'package:lucky/services/checkout_service.dart';

class CheckoutProvider with ChangeNotifier {
  final CheckoutService _service = CheckoutService();

  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _pedido;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get pedido => _pedido;

  Future<bool> confirmarCheckout({
    required int idTipoDocumento,
    required String numeroDocumento,
    required String telefono,
    required int idTipoEntrega,
    int? idDistrito,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _pedido = await _service.confirmarCheckout(
        idTipoDocumento: idTipoDocumento,
        numeroDocumento: numeroDocumento,
        telefono: telefono,
        idTipoEntrega: idTipoEntrega,
        idDistrito: idDistrito,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void limpiarEstado() {
    _error = null;
    _pedido = null;
    notifyListeners();
  }
}
