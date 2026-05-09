import 'package:shared_preferences/shared_preferences.dart';

class PrefService {
  static final PrefService _instance = PrefService._internal();
  factory PrefService() => _instance;
  PrefService._internal();

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);

  String? getString(String key, {String defaultValue = ''}) {
    return _prefs.getString(key) ?? defaultValue;
  }

  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);

  bool getBool(String key, {bool defaultValue = false}) {
    return _prefs.getBool(key) ?? defaultValue;
  }

  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);

  int? getInt(String key, {int defaultValue = 0}) {
    return _prefs.getInt(key) ?? defaultValue;
  }

  Future<bool> remove(String key) => _prefs.remove(key);

  Future<void> clearAll() => _prefs.clear();

  Future<void> saveUserId(String userId) async {
    await _prefs.setString('userId', userId);
  }

  String? getUserId() {
    return _prefs.getString('userId');
  }

  Future<void> setLoginStatus(bool status) async {
    await _prefs.setBool('isLoggedIn', status);
  }

  bool getLoginStatus() {
    return _prefs.getBool('isLoggedIn') ?? false;
  }

  Future<void> saveUserToken(String token) async {
    await _prefs.setString('userToken', token);
  }

  String? getUserToken() {
    return _prefs.getString('userToken');
  }

  Future<void> saveUserEmail(String email) async {
    await _prefs.setString('userEmail', email);
  }

  String? getUserEmail() {
    return _prefs.getString('userEmail');
  }

  Future<void> saveUserName(String name) async {
    await _prefs.setString('userName', name);
  }

  String? getUserName() {
    return _prefs.getString('userName');
  }

  Future<void> clearUserData() async {
    await _prefs.remove('userId');
    await _prefs.remove('userToken');
    await _prefs.remove('userEmail');
    await _prefs.remove('userName');
    await _prefs.remove('isLoggedIn');
  }
}
