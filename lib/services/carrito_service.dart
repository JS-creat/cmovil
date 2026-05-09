import 'package:dio/dio.dart';
import 'package:lucky/models/carrito_model.dart';
import 'package:lucky/utils/dio_client.dart';
import 'package:lucky/services/auth_service.dart';

class CarritoService {
  final Dio _dio = ApiClient.dio;
  final AuthService _authService = AuthService();

  Future<void> _ensureToken() async {
    final token = await _authService.getStoredToken();
    if (token != null && token.isNotEmpty) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  Future<CarritoModel> obtenerCarrito(int idUsuario) async {
    try {
      await _ensureToken();

      final response = await _dio.get(
        '/carrito',
        queryParameters: {'id_usuario': idUsuario},
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return CarritoModel.fromJson(response.data['data']);
      }

      return await crearCarrito(idUsuario);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<CarritoModel> crearCarrito(int idUsuario) async {
    try {
      await _ensureToken();

      final response = await _dio.post(
        '/carrito/crear',
        data: {'id_usuario': idUsuario},
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return CarritoModel.fromJson(response.data['data']);
      }

      throw Exception('No se pudo crear el carrito');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<CarritoModel> agregarProducto({
    required int idUsuario,
    required int idVariante,
    int cantidad = 1,
  }) async {
    try {
      await _ensureToken();

      final response = await _dio.post(
        '/carrito/agregar',
        data: {
          'id_usuario': idUsuario,
          'id_variante': idVariante,
          'cantidad': cantidad,
        },
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return CarritoModel.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'Error al agregar producto');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<CarritoModel> actualizarCantidad({
    required int idUsuario,
    required int idDetalleCarrito,
    required int cantidad,
  }) async {
    try {
      await _ensureToken();

      final response = await _dio.put(
        '/carrito/actualizar',
        data: {
          'id_usuario': idUsuario,
          'id_detalle_carrito': idDetalleCarrito,
          'cantidad': cantidad,
        },
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return CarritoModel.fromJson(response.data['data']);
      }

      throw Exception(
        response.data['message'] ?? 'Error al actualizar cantidad',
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<CarritoModel> eliminarProducto({
    required int idUsuario,
    required int idDetalleCarrito,
  }) async {
    try {
      await _ensureToken();

      final response = await _dio.delete(
        '/carrito/eliminar',
        data: {'id_usuario': idUsuario, 'id_detalle_carrito': idDetalleCarrito},
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return CarritoModel.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'Error al eliminar producto');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> limpiarCarrito(int idUsuario) async {
    try {
      await _ensureToken();

      final response = await _dio.delete(
        '/carrito/limpiar',
        data: {'id_usuario': idUsuario},
      );

      return response.data['success'] == true;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> verificarStock(int idVariante, int cantidad) async {
    try {
      final response = await _dio.get(
        '/variantes/$idVariante/verificar-stock',
        queryParameters: {'cantidad': cantidad},
      );

      return response.data['disponible'] ?? false;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<double> obtenerTotal(int idCarrito) async {
    try {
      await _ensureToken();

      final response = await _dio.get('/carrito/$idCarrito/total');
      return (response.data['total'] ?? 0).toDouble();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    if (error.response != null) {
      if (error.response?.data != null &&
          error.response?.data['message'] != null) {
        return error.response?.data['message'];
      }
      return 'Error ${error.response?.statusCode}';
    }
    return 'Error de conexión: ${error.message}';
  }
}
