// models/auth_model.dart
class UsuarioModel {
  final int id;
  final String nombres;
  final String apellidos;
  final String correo;
  final int idRol;
  final String? telefono;
  final String? numeroDocumento;
  final int? idTipoDocumento;
  final String? createdAt;
  final String? updatedAt;

  UsuarioModel({
    required this.id,
    required this.nombres,
    required this.apellidos,
    required this.correo,
    required this.idRol,
    this.telefono,
    this.numeroDocumento,
    this.idTipoDocumento,
    this.createdAt,
    this.updatedAt,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      id: json['id'] ?? json['id_usuario'] ?? 0,
      nombres: json['nombres'] ?? '',
      apellidos: json['apellidos'] ?? '',
      correo: json['correo'] ?? '',
      idRol: json['id_rol'] ?? 2,
      telefono: json['telefono'],
      numeroDocumento: json['numero_documento'],
      idTipoDocumento: json['id_tipo_documento'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  String get nombreCompleto => '$nombres $apellidos';
}

// Request para Login (usa correo y contrasena)
class LoginRequest {
  final String correo;
  final String contrasena;

  LoginRequest({required this.correo, required this.contrasena});

  Map<String, dynamic> toJson() {
    return {'correo': correo, 'contrasena': contrasena};
  }
}

// Request para Registro (usa nombres, apellidos, correo, contrasena)
class RegistroRequest {
  final String nombres;
  final String apellidos;
  final String correo;
  final String contrasena;
  final String? numeroDocumento;
  final String? telefono;
  final int? idTipoDocumento;

  RegistroRequest({
    required this.nombres,
    required this.apellidos,
    required this.correo,
    required this.contrasena,
    this.numeroDocumento,
    this.telefono,
    this.idTipoDocumento,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombres': nombres,
      'apellidos': apellidos,
      'correo': correo,
      'contrasena': contrasena,
      'numero_documento': numeroDocumento,
      'telefono': telefono,
      'id_tipo_documento': idTipoDocumento,
    };
  }
}

// Respuesta de Autenticación
class AuthResponse {
  final String? message;
  final UsuarioModel? user;
  final String? token;

  AuthResponse({this.message, this.user, this.token});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      message: json['message'],
      user: json['user'] != null ? UsuarioModel.fromJson(json['user']) : null,
      token: json['token'],
    );
  }
}
