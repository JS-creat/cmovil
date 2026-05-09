import 'package:dio/dio.dart';
import 'package:lucky/models/genero_model.dart';
import 'package:lucky/utils/dio_client.dart';

class GeneroService {
  final Dio _dio = ApiClient.dio;

  // Obtener todos los géneros
  Future<List<GeneroModel>> getGeneros() async {
    try {
      final response = await _dio.get('/generos');

      if (response.data['success'] == true) {
        final List<dynamic> lista = response.data['data'] ?? [];
        return lista.map((e) => GeneroModel.fromJson(e)).toList();
      }

      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw Exception('Error al cargar los géneros: $e');
    }
  }

  // Manejo de errores
  String _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Tiempo de conexión agotado';
      case DioExceptionType.sendTimeout:
        return 'Tiempo de envío agotado';
      case DioExceptionType.receiveTimeout:
        return 'Tiempo de recepción agotado';
      case DioExceptionType.badResponse:
        if (error.response?.statusCode == 404) {
          return 'Géneros no encontrados';
        } else if (error.response?.statusCode == 500) {
          return 'Error en el servidor';
        }
        return 'Error: ${error.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Petición cancelada';
      default:
        return 'Error de conexión: ${error.message}';
    }
  }
}
