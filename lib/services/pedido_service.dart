import 'package:dio/dio.dart';
import 'package:lucky/utils/dio_client.dart';

class PedidoService {
  final Dio _dio = ApiClient.dio;

  Future<List<dynamic>> obtenerMisPedidos() async {
    try {
      final response = await _dio.get('/mis-pedidos');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      }

      throw Exception(response.data['message'] ?? 'Error al cargar pedidos');
    } on DioException catch (e) {
      if (e.response?.data?['message'] != null) {
        throw Exception(e.response?.data['message']);
      }
      throw Exception('Error de conexión: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> obtenerDetallePedido(int idPedido) async {
    try {
      final response = await _dio.get('/pedidos/$idPedido');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      }

      throw Exception(
        response.data['message'] ?? 'Error al cargar detalle del pedido',
      );
    } on DioException catch (e) {
      if (e.response?.data?['message'] != null) {
        throw Exception(e.response?.data['message']);
      }
      throw Exception('Error de conexión: ${e.message}');
    }
  }
}
