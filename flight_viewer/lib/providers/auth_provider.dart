import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  static const String _authTokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userFirstNameKey = 'user_first_name';
  static const String _userLastNameKey = 'user_last_name';

  String? _authToken;
  String? _userId;
  String? _userEmail;
  String? _userFirstName;
  String? _userLastName;
  bool _isLoading = false;

  String? get authToken => _authToken;
  String? get userId => _userId;
  String? get userEmail => _userEmail;
  String? get userFirstName => _userFirstName;
  String? get userLastName => _userLastName;
  String get fullName => '${_userFirstName ?? ''} ${_userLastName ?? ''}'.trim();
  bool get isAuthenticated => _authToken != null && _userId != null;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _loadAuthData();
  }

  Future<void> _loadAuthData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _authToken = prefs.getString(_authTokenKey);
      _userId = prefs.getString(_userIdKey);
      _userEmail = prefs.getString(_userEmailKey);
      _userFirstName = prefs.getString(_userFirstNameKey);
      _userLastName = prefs.getString(_userLastNameKey);
    } catch (e) {
      // If there's an error loading auth data, clear everything
      await _clearAuthData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login({
    required String token,
    required String userId,
    required String email,
    required String firstName,
    required String lastName,
  }) async {
    _authToken = token;
    _userId = userId;
    _userEmail = email;
    _userFirstName = firstName;
    _userLastName = lastName;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, token);
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_userEmailKey, email);
    await prefs.setString(_userFirstNameKey, firstName);
    await prefs.setString(_userLastNameKey, lastName);
  }

  Future<void> logout() async {
    await _clearAuthData();
    notifyListeners();
  }

  Future<void> _clearAuthData() async {
    _authToken = null;
    _userId = null;
    _userEmail = null;
    _userFirstName = null;
    _userLastName = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userFirstNameKey);
    await prefs.remove(_userLastNameKey);
  }

  Future<void> updateUserInfo({
    String? firstName,
    String? lastName,
    String? email,
  }) async {
    if (firstName != null) _userFirstName = firstName;
    if (lastName != null) _userLastName = lastName;
    if (email != null) _userEmail = email;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    if (firstName != null) await prefs.setString(_userFirstNameKey, firstName);
    if (lastName != null) await prefs.setString(_userLastNameKey, lastName);
    if (email != null) await prefs.setString(_userEmailKey, email);
  }
}