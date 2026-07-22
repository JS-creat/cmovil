import 'package:flutter/material.dart';
import 'package:lucky/models/auth_model.dart';
import 'package:lucky/services/auth_service.dart';
import 'package:lucky/utils/dio_client.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UsuarioModel? _usuario;
  String? _token;
  bool _isLoading = false;
  String? _error;
  bool _isChecking = true;

  UsuarioModel? get usuario => _usuario;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _usuario != null && (_usuario?.id ?? 0) > 0;
  bool get isChecking => _isChecking;

  // Getters para los datos de contacto
  String? get numeroDocumento => _usuario?.numeroDocumento;
  String? get telefono => _usuario?.telefono;
  int? get idTipoDocumento => _usuario?.idTipoDocumento;

  AuthProvider() {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    _isChecking = true;
    notifyListeners();

    // 🟢 FIX: usamos el mismo mecanismo de storage que AuthService
    // (clave 'token', vía PrefService), en vez de un storage paralelo
    // con otra clave ('auth_token') que Dio nunca llegaba a conocer.
    final tokenGuardado = await _authService.getStoredToken();

    if (tokenGuardado != null && tokenGuardado.isNotEmpty) {
      try {
        // 🟢 FIX: ahora sí le avisamos a Dio que use este token en el
        // header Authorization antes de pedir el perfil. Antes esto
        // nunca se llamaba acá, por lo que getPerfil() salía sin token,
        // el backend respondía 401 y eso disparaba un logout() que
        // borraba la sesión que se acababa de recuperar.
        ApiClient.setAuthToken(tokenGuardado);
        _token = tokenGuardado;

        final usuario = await _authService.getPerfil();

        if (usuario.id > 0) {
          _usuario = usuario;
        } else {
          await logout();
        }
      } catch (e) {
        debugPrint('Error recuperando perfil tras recarga: $e');
        await logout();
      }
    }

    _isChecking = false;
    notifyListeners();
  }

  Future<bool> login(String correo, String contrasena) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final request = LoginRequest(correo: correo, contrasena: contrasena);
      final response = await _authService.login(request);

      if (response.user != null && response.token != null) {
        if (response.user!.id <= 0) {
          throw Exception('ID de usuario inválido');
        }

        _usuario = response.user;
        _token = response.token;
        // El guardado en storage y el ApiClient.setAuthToken() ya los
        // hace _authService.login() -> _saveToken() internamente.

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Error al iniciar sesión';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(RegistroRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.register(request);

      if (response.user != null) {
        if (response.user!.id <= 0) {
          throw Exception('ID de usuario inválido');
        }

        if (response.token != null) {
          _usuario = response.user;
          _token = response.token;
          // El guardado en storage y el ApiClient.setAuthToken() ya los
          // hace _authService.register() -> _saveToken() internamente.
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Error al registrarse';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> cargarPerfil() async {
    if (!isLoggedIn) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final usuario = await _authService.getPerfil();

      if (usuario.id <= 0) {
        throw Exception('ID de usuario inválido');
      }

      _usuario = usuario;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> actualizarPerfil({
    required String nombres,
    required String apellidos,
    String? telefono,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final usuarioActualizado = await _authService.updatePerfil(
        nombres: nombres,
        apellidos: apellidos,
        telefono: telefono,
      );

      _usuario = usuarioActualizado;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> actualizarDatosContacto({
    required int idTipoDocumento,
    required String numeroDocumento,
    required String telefono,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final usuarioActualizado = await _authService.updateDatosContacto(
        idTipoDocumento: idTipoDocumento,
        numeroDocumento: numeroDocumento,
        telefono: telefono,
      );

      _usuario = usuarioActualizado;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();

    _usuario = null;
    _token = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}