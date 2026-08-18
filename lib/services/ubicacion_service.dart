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

  // 🟢 Helper: convierte cualquier valor numérico que venga del JSON
  // (int o double) a double de forma segura. Un JSON como
  // "costo_envio": 25 se decodifica en Dart como int, no double — y un
  // `as double` directo sobre eso explota con
  // "type 'int' is not a subtype of type 'double'" en modo release
  // (Chrome en modo debug es más permisivo y no siempre lo detecta).
  double _toDouble(dynamic valor) {
    if (valor == null) return 0.0;
    if (valor is double) return valor;
    if (valor is int) return valor.toDouble();
    if (valor is String) return double.tryParse(valor) ?? 0.0;
    return 0.0;
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
        final Map<String, dynamic> data = response.data['data'];

        // 🟢 FIX: normalizamos los campos numéricos acá, en el único
        // lugar donde se parsea esta respuesta, para que la pantalla
        // (informacion_compra.dart) siempre reciba un double real y
        // pueda seguir usando `as double` sin que explote en el celular.
        return {
          ...data,
          'costo_envio': _toDouble(data['costo_envio']),
          'subtotal': _toDouble(data['subtotal']),
          'total_con_envio': _toDouble(data['total_con_envio']),
        };
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