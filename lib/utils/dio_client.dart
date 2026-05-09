import 'package:dio/dio.dart';
import 'api_config.dart';

class ApiClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.apiUrl,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
    ),
  );

  static void setAuthToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  static void removeAuthToken() {
    dio.options.headers.remove('Authorization');
  }

  static bool get isAuthenticated {
    return dio.options.headers.containsKey('Authorization');
  }
}
