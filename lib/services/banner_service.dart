import 'package:dio/dio.dart';
import 'package:lucky/models/banner_model.dart';
import 'package:lucky/utils/dio_client.dart';

class BannerService {
  final Dio _dio = ApiClient.dio;

  Future<List<BannerModel>> obtenerBanners() async {
    try {
      final response = await _dio.get('/banners');

      if (response.data['success'] == true) {
        final List bannersJson = response.data['data'] ?? [];
        return bannersJson.map((json) => BannerModel.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      print('Error obteniendo banners: $e');
      return [];
    }
  }

  Future<BannerModel?> obtenerBannerPorId(int id) async {
    try {
      final response = await _dio.get('/banners/$id');

      if (response.data['success'] == true && response.data['data'] != null) {
        return BannerModel.fromJson(response.data['data']);
      }

      return null;
    } catch (e) {
      print('Error obteniendo banner: $e');
      return null;
    }
  }
}
