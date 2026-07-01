import 'dart:convert';
import 'package:ridoo_customer/core/network/api_client.dart';

class AuthService {
  Future<Map<String, dynamic>> sendOtp(String phone) async {
    final response = await ApiClient.post('/auth/otp/send', {
      'phone': phone,
    });

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Failed to send OTP');
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String phone, String otp, String? fcmToken) async {
    final response = await ApiClient.post('/auth/otp/verify', {
      'phone': phone,
      'otp': otp,
      'fcm_token': fcmToken,
    });

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Invalid verification code');
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    String? phone,
    required String password,
    required String role,
    String? fcmToken,
  }) async {
    final response = await ApiClient.post('/auth/register', {
      'name': name,
      'email': email,
      if (phone != null) 'phone': phone,
      'password': password,
      'role': role,
      'fcm_token': fcmToken,
    });

    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Registration failed');
    }
  }

  Future<Map<String, dynamic>> login({
    String? email,
    String? phone,
    required String password,
    String? fcmToken,
  }) async {
    final response = await ApiClient.post('/auth/login', {
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      'password': password,
      'fcm_token': fcmToken,
    });

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Login failed');
    }
  }

  Future<Map<String, dynamic>> logout() async {
    final response = await ApiClient.post('/auth/logout', {});
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Logout failed');
    }
  }

  Future<Map<String, dynamic>> updateFcmToken(String fcmToken) async {
    final response = await ApiClient.post('/notifications/fcm-token', {
      'fcm_token': fcmToken,
    });
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Failed to update FCM token');
    }
  }
}
