// services/favorito_service.dart - ACTUALIZADO
import 'package:dio/dio.dart';
import 'package:lucky/utils/dio_client.dart';
import 'package:lucky/services/auth_service.dart';

class FavoritoService {
  final Dio _dio = ApiClient.dio;
  final AuthService _authService = AuthService();

  Future<void> _ensureToken() async {
    final token = await _authService.getStoredToken();
    if (token != null && token.isNotEmpty) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  // Obtener favoritos del usuario
  Future<List<Map<String, dynamic>>> obtenerFavoritos(int idUsuario) async {
    try {
      await _ensureToken();
      final response = await _dio.get(
        '/favoritos',
        queryParameters: {'id_usuario': idUsuario},
      );

      if (response.data['success'] == true) {
        return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
      }
      return [];
    } catch (e) {
      print('Error obteniendo favoritos: $e');
      return [];
    }
  }

  // Agregar a favoritos
  Future<bool> agregarFavorito(int idUsuario, int idProducto) async {
    try {
      await _ensureToken();
      final response = await _dio.post(
        '/favoritos/agregar',
        data: {'id_usuario': idUsuario, 'id_producto': idProducto},
      );
      return response.data['success'] == true;
    } catch (e) {
      print('Error agregando favorito: $e');
      return false;
    }
  }

  // Eliminar de favoritos
  Future<bool> eliminarFavorito(int idUsuario, int idProducto) async {
    try {
      await _ensureToken();
      final response = await _dio.delete(
        '/favoritos/eliminar',
        data: {'id_usuario': idUsuario, 'id_producto': idProducto},
      );
      return response.data['success'] == true;
    } catch (e) {
      print('Error eliminando favorito: $e');
      return false;
    }
  }
}
