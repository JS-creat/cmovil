class ApiConfig {
  static const String baseUrl = 'http://localhost:8000';

  static const String apiUrl = '$baseUrl/api';
  static String get broadcastAuthUrl => '$baseUrl/api/broadcasting/auth';
  static String get chatMessageUrl => '$baseUrl/api/chat/message';
}
