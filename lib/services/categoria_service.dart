// lib/services/categoria_service.dart
import 'package:dio/dio.dart';
import 'package:lucky/utils/dio_client.dart';

class CategoriaService {
  final Dio _dio = ApiClient.dio;

  Future<List<Map<String, dynamic>>> getCategoriasPorGenero(
    int? generoId,
  ) async {
    try {
      final queryParams = <String, dynamic>{};
      if (generoId != null) {
        queryParams['genero_id'] = generoId;
      }

      final response = await _dio.get(
        '/categorias',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }
      return [];
    } catch (e) {
      print('Error obteniendo categorías: $e');
      return [];
    }
  }
}
