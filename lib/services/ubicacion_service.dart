import 'package:dio/dio.dart';
import 'package:lucky/models/ubicacion_item.dart';
import 'package:lucky/services/auth_service.dart';
import 'package:lucky/utils/dio_client.dart';

class UbicacionService {
  final Dio _dio = ApiClient.dio;
  final AuthService _authService = AuthService();

  Future<List<UbicacionItem>> obtenerTiposDocumento() async {
    try {
      final response = await _dio.get('/ubicaciones/tipos-documento');

      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((e) => UbicacionItem.fromJson(e)).toList();
      }

      throw Exception('No se pudieron cargar los tipos de documento');
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<List<UbicacionItem>> obtenerDepartamentos() async {
    try {
      final response = await _dio.get('/ubicaciones/departamentos');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List data = response.data['data'];
        return data.map((e) => UbicacionItem.fromJson(e)).toList();
      }

      throw Exception('No se pudieron cargar los departamentos');
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<List<UbicacionItem>> obtenerProvincias(int idDepartamento) async {
    try {
      final response = await _dio.get(
        '/ubicaciones/provincias/$idDepartamento',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List data = response.data['data'];
        return data.map((e) => UbicacionItem.fromJson(e)).toList();
      }

      throw Exception('No se pudieron cargar las provincias');
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<List<UbicacionItem>> obtenerDistritos(int idProvincia) async {
    try {
      final response = await _dio.get('/ubicaciones/distritos/$idProvincia');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List data = response.data['data'];
        return data.map((e) => UbicacionItem.fromJson(e)).toList();
      }

      throw Exception('No se pudieron cargar los distritos');
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// Calcular costo de envío para un distrito específico
  /// Retorna un mapa con: costo_envio, nombre_agencia, tiempo_estimado, subtotal, total_con_envio
  Future<Map<String, dynamic>> calcularCostoEnvio(int idDistrito) async {
    try {
      await _ensureToken();

      final response = await _dio.post(
        '/checkout/calcular-envio',
        data: {'id_distrito': idDistrito},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      }

      throw Exception(
        response.data['message'] ?? 'Error al calcular el costo de envío',
      );
    } on DioException catch (e) {
      if (e.response?.data?['message'] != null) {
        throw Exception(e.response?.data['message']);
      }
      throw Exception('Error de conexión: ${e.message}');
    }
  }

  /// Asegurar que el token de autenticación esté presente en las cabeceras
  Future<void> _ensureToken() async {
    final token = await _authService.getStoredToken();
    if (token != null && token.isNotEmpty) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;

      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }

      return 'Error ${e.response?.statusCode}: ${e.response?.statusMessage}';
    }

    return 'Error de conexión: ${e.message}';
  }
}
