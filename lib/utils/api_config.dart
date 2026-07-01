class ApiConfig {
  static const String baseUrl = 'https://www.bedenb.com';
  static const String apiUrl = '$baseUrl/api';

  static String get broadcastAuthUrl => '$apiUrl/broadcasting/auth';
  static String get chatMessageUrl => 'http://2.24.94.167:8000/api/chat';

  // NUEVO: Ruta dinámica para consultar un pedido por su ID
  static String pedidoDetalleUrl(dynamic id) => '$apiUrl/pedidos/$id';

  static String imagenProducto(String? filename) {
    if (filename == null || filename.trim().isEmpty) return '';
    final String clean = _extraerFilename(filename);
    if (clean.isEmpty) return '';
    return '$baseUrl/productos/$clean';
  }

  static String imagenBanner(String? filename) {
    if (filename == null || filename.trim().isEmpty) return '';
    final String clean = _extraerFilename(filename);
    if (clean.isEmpty) return '';
    return '$baseUrl/banners/$clean';
  }

  static String _extraerFilename(String raw) {
    final String trimmed = raw.trim();

    if (trimmed.contains('/')) {
      return trimmed.split('/').last;
    }

    return trimmed;
  }
}
