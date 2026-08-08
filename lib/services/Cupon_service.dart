import 'package:dio/dio.dart';
import 'package:lucky/models/Cupon_model.dart';
import 'package:lucky/utils/dio_client.dart';

class CuponService {
  final Dio _dio = ApiClient.dio;

  Future<List<CuponModel>> obtenerDisponibles() async {
    try {
      final response = await _dio.get('/cupones/disponibles');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => CuponModel.fromJson(json)).toList();
      }

      throw Exception(
        response.data['message'] ?? 'Error al cargar cupones',
      );
    } on DioException catch (e) {
      if (e.response?.data?['message'] != null) {
        throw Exception(e.response?.data['message']);
      }
      throw Exception('Error de conexión: ${e.message}');
    }
  }

  // 🟢 NUEVO: valida un código de cupón contra el monto actual del
  // carrito. Solo sirve para mostrarle al usuario el descuento ANTES de
  // pagar — el backend vuelve a calcular todo desde cero al confirmar el
  // pedido (POST /checkout/confirmar), así que este resultado nunca se
  // usa como fuente de verdad del monto a cobrar.
  Future<Map<String, dynamic>> validarCupon({
    required String codigo,
    required double montoCarrito,
  }) async {
    try {
      final response = await _dio.post(
        '/cupones/validar',
        data: {
          'codigo_cupon': codigo,
          'monto_carrito': montoCarrito,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      }

      throw Exception(response.data['message'] ?? 'Cupón no válido');
    } on DioException catch (e) {
      if (e.response?.data?['message'] != null) {
        throw Exception(e.response?.data['message']);
      }
      throw Exception('Error de conexión: ${e.message}');
    }
  }
}