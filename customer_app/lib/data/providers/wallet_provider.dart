import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ridoo_customer/core/network/api_client.dart';

class WalletProvider extends ChangeNotifier {
  double _balance = 0.0;
  List<dynamic> _transactions = [];
  bool _isLoading = false;
  String? _error;

  double get balance => _balance;
  List<dynamic> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? err) {
    _error = err;
    notifyListeners();
  }

  Future<void> fetchWallet() async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await ApiClient.get('/wallet/dashboard');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _balance = double.parse(data['balance'].toString());
        _transactions = data['transactions'] ?? [];
      } else {
        throw Exception('Failed to load wallet dashboard');
      }
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> topUpWithStripe({
    required double amount,
    required String cardNumber,
    required String expiry,
    required String cvv,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      // 1. Create Stripe intent on backend
      final intentResponse = await ApiClient.post('/payment/stripe/intent', {
        'amount': amount,
      });
      if (intentResponse.statusCode != 200) {
        final data = jsonDecode(intentResponse.body);
        throw Exception(data['message'] ?? 'Stripe Intent Failed');
      }
      final intentData = jsonDecode(intentResponse.body);
      final clientSecret = intentData['client_secret'];

      // 2. Confirm the Stripe payment on backend
      final confirmResponse = await ApiClient.post('/payment/stripe/confirm', {
        'client_secret': clientSecret,
        'amount': amount,
      });

      if (confirmResponse.statusCode == 200) {
        await fetchWallet();
        return true;
      } else {
        final data = jsonDecode(confirmResponse.body);
        throw Exception(data['message'] ?? 'Stripe Confirmation Failed');
      }
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> topUpWithRazorpay({
    required double amount,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      // 1. Create Razorpay order on backend
      final orderResponse = await ApiClient.post('/payment/razorpay/order', {
        'amount': amount,
      });
      if (orderResponse.statusCode != 200) {
        final data = jsonDecode(orderResponse.body);
        throw Exception(data['message'] ?? 'Razorpay Order Failed');
      }
      final orderData = jsonDecode(orderResponse.body);
      final orderId = orderData['order_id'];

      // 2. Confirm payment on backend
      final confirmResponse = await ApiClient.post('/payment/razorpay/confirm', {
        'order_id': orderId,
        'payment_id': 'pay_razor_${orderId.toString().replaceAll('order_', '')}',
        'amount': amount,
      });

      if (confirmResponse.statusCode == 200) {
        await fetchWallet();
        return true;
      } else {
        final data = jsonDecode(confirmResponse.body);
        throw Exception(data['message'] ?? 'Razorpay Confirmation Failed');
      }
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }
}
