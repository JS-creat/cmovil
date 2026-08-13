import 'package:dio/dio.dart';
import 'package:lucky/services/auth_service.dart';
import 'package:lucky/utils/dio_client.dart';

class CheckoutService {
  final Dio _dio = ApiClient.dio;
  final AuthService _authService = AuthService();

  Future<void> _ensureToken() async {
    final token = await _authService.getStoredToken();
    if (token != null && token.isNotEmpty) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  // 🟢 CAMBIADO: antes este método asumía que el pedido quedaba
  // "confirmado" apenas respondía el backend (sin pago real de por
  // medio). Ahora el backend crea el pedido como "Pendiente" y devuelve
  // 'init_point' — la URL de Mercado Pago que hay que abrir en un
  // WebView para que el usuario pague de verdad. El pedido recién pasa
  // a "Confirmado" cuando Mercado Pago aprueba el pago (ver PagoService
  // en el backend), no acá.
  Future<Map<String, dynamic>> confirmarCheckout({
    required int idTipoDocumento,
    required String numeroDocumento,
    required String telefono,
    required int idTipoEntrega,
    int? idDistrito,
    String? codigoCupon,
  }) async {
    try {
      await _ensureToken();

      final response = await _dio.post(
        '/checkout/confirmar',
        data: {
          'id_tipo_documento': idTipoDocumento,
          'numero_documento': numeroDocumento,
          'telefono': telefono,
          'id_tipo_entrega': idTipoEntrega,
          'id_distrito': idTipoEntrega == 2 ? idDistrito : null,
          if (codigoCupon != null && codigoCupon.trim().isNotEmpty)
            'codigo_cupon': codigoCupon.trim(),
        },
      );

      if (response.data['success'] == true) {
        // 'data' ahora incluye: id_pedido, numero_pedido, subtotal,
        // costo_envio, monto_descuento, codigo_cupon, total_pedido,
        // e init_point (la URL de pago de Mercado Pago).
        return response.data['data'];
      }

      throw Exception(response.data['message'] ?? 'Error al confirmar pedido');
    } on DioException catch (e) {
      if (e.response != null &&
          e.response?.data != null &&
          e.response?.data['message'] != null) {
        throw Exception(e.response?.data['message']);
      }

      throw Exception('Error de conexión: ${e.message}');
    }
  }
}