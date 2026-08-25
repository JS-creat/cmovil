import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lucky/models/auth_model.dart';
import 'package:lucky/services/pref_service.dart';
import 'package:lucky/utils/dio_client.dart';

class AuthService {
  final Dio _dio = ApiClient.dio;
  final PrefService _prefs = PrefService();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '623271174588-73s87gn8a30ipv67ci96a9a9ri81ekge.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  Future<void> _saveToken(String token) async {
    await _prefs.setString('token', token);
    ApiClient.setAuthToken(token);
  }

  Future<String?> getStoredToken() async {
    return _prefs.getString('token', defaultValue: '');
  }

  Future<void> removeToken() async {
    await _prefs.remove('token');
    ApiClient.removeAuthToken();
  }

  Future<bool> isLoggedIn() async {
    final token = await getStoredToken();
    return token != null && token.isNotEmpty;
  }

  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _dio.post('/login', data: request.toJson());

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(response.data);

        if (authResponse.token != null) {
          await _saveToken(authResponse.token!);
        }

        return authResponse;
      } else {
        throw Exception('Error en el login: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<AuthResponse> register(RegistroRequest request) async {
    try {
      final response = await _dio.post('/register', data: request.toJson());

      if (response.statusCode == 201) {
        final authResponse = AuthResponse.fromJson(response.data);

        if (authResponse.token != null) {
          await _saveToken(authResponse.token!);
        }

        return authResponse;
      } else {
        throw Exception('Error en el registro: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<UsuarioModel> getPerfil() async {
    try {
      final response = await _dio.get('/perfil');

      if (response.statusCode == 200) {
        return UsuarioModel.fromJson(response.data);
      } else {
        throw Exception('Error al obtener perfil');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<UsuarioModel> updatePerfil({
    required String nombres,
    required String apellidos,
    String? telefono,
  }) async {
    try {
      final response = await _dio.put(
        '/perfil',
        data: {
          'nombres': nombres,
          'apellidos': apellidos,
          'telefono': telefono,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return UsuarioModel.fromJson(response.data['user']);
      } else {
        throw Exception(
          response.data['message'] ?? 'Error al actualizar perfil',
        );
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<UsuarioModel> updateDatosContacto({
    required int idTipoDocumento,
    required String numeroDocumento,
    required String telefono,
  }) async {
    try {
      final response = await _dio.put(
        '/perfil/datos-contacto',
        data: {
          'id_tipo_documento': idTipoDocumento,
          'numero_documento': numeroDocumento,
          'telefono': telefono,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return UsuarioModel.fromJson(response.data['data']);
      } else {
        throw Exception(
          response.data['message'] ?? 'Error al actualizar datos de contacto',
        );
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<AuthResponse> loginWithGoogle() async {
    try {
      // 1. Iniciar flujo de Google Sign In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw 'Inicio de sesión cancelado';
      }

      // 2. Obtener los tokens de autenticación
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw 'No se obtuvo el token de autenticación de Google';
      }

      // 3. Enviar token a Laravel Backend
      final response = await _dio.post(
        '/login/google',
        data: {'id_token': idToken},
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(response.data);
        if (authResponse.token != null) {
          await _saveToken(authResponse.token!);
        }
        return authResponse;
      } else {
        throw 'Error en autenticación backend';
      }
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<void> logout() async {
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
    } catch (_) {}
    await removeToken();
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;

      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }

      if (data is Map && data['errors'] != null) {
        final errors = data['errors'] as Map;
        if (errors.isNotEmpty) {
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            return firstError.first.toString();
          }
        }
      }

      return 'Error ${e.response?.statusCode}: ${e.response?.statusMessage}';
    } else {
      return 'Error de conexión: ${e.message}';
    }
  }
}