import 'package:flutter/material.dart';
import 'package:ridoo_driver/core/storage/local_storage.dart';
import 'package:ridoo_driver/data/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _isAuthenticated = false;
  Map<String, dynamic>? _user;
  String? _token;
  String? _error;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get user => _user;
  String? get token => _token;
  String? get error => _error;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? err) {
    _error = err;
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    final token = LocalStorage.getToken();
    final user = LocalStorage.getUser();

    if (token != null && user != null) {
      _token = token;
      _user = user;
      _isAuthenticated = true;
    } else {
      _token = null;
      _user = null;
      _isAuthenticated = false;
    }
    notifyListeners();
  }

  Future<bool> sendOtp(String phone) async {
    _setLoading(true);
    _setError(null);
    try {
      await _authService.sendOtp(phone);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  // Returns true if registered, false if OTP verified but needs registration
  Future<bool?> verifyOtp(String phone, String otp) async {
    _setLoading(true);
    _setError(null);
    try {
      final fcmToken = LocalStorage.getFcmToken();
      final response = await _authService.verifyOtp(phone, otp, fcmToken);
      
      final bool registered = response['registered'] ?? false;
      
      if (registered) {
        _token = response['token'];
        _user = response['user'];
        _isAuthenticated = true;
        
        await LocalStorage.saveToken(_token!);
        await LocalStorage.saveUser(_user!);
      }
      
      _setLoading(false);
      notifyListeners();
      return registered;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return null;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final fcmToken = LocalStorage.getFcmToken();
      final response = await _authService.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        role: 'driver',
        fcmToken: fcmToken,
      );

      _token = response['token'];
      _user = response['user'];
      _isAuthenticated = true;

      await LocalStorage.saveToken(_token!);
      await LocalStorage.saveUser(_user!);

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> login(String phone, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      final fcmToken = LocalStorage.getFcmToken();
      final response = await _authService.login(phone, password, fcmToken);

      _token = response['token'];
      _user = response['user'];
      _isAuthenticated = true;

      await LocalStorage.saveToken(_token!);
      await LocalStorage.saveUser(_user!);

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();
    } catch (_) {}

    _token = null;
    _user = null;
    _isAuthenticated = false;
    await LocalStorage.clearAll();
    _setLoading(false);
  }

  Future<void> updateFcmToken(String fcmToken) async {
    await LocalStorage.saveFcmToken(fcmToken);
    if (_isAuthenticated) {
      try {
        await _authService.updateFcmToken(fcmToken);
      } catch (_) {}
    }
  }
}
