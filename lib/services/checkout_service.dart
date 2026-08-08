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

  Future<Map<String, dynamic>> confirmarCheckout({
    required int idTipoDocumento,
    required String numeroDocumento,
    required String telefono,
    required int idTipoEntrega,
    int? idDistrito,
    // 🟢 NUEVO: código de cupón opcional. El backend recalcula el
    // descuento por su cuenta (no confía en montos calculados en el
    // cliente), así que solo mandamos el código, nada más.
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