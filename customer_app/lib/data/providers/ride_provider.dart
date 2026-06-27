import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ridoo_customer/core/network/api_client.dart';
import 'package:ridoo_customer/core/storage/local_storage.dart';
import 'package:ridoo_customer/data/services/socket_service.dart';

class RideProvider extends ChangeNotifier {
  final SocketService _socketService = SocketService();
  Map<String, dynamic>? _activeRide;
  bool _isSearching = false;
  String? _error;
  Timer? _pollingTimer;
  List<dynamic> _rideHistory = [];

  Map<String, dynamic>? get activeRide => _activeRide;
  bool get isSearching => _isSearching;
  String? get error => _error;
  List<dynamic> get rideHistory => _rideHistory;

  void _setError(String? err) {
    _error = err;
    notifyListeners();
  }

  Future<void> fetchRideHistory() async {
    _setError(null);
    try {
      final response = await ApiClient.get('/rides');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _rideHistory = data['data'] ?? [];
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Static list of mock locations to simulate coordinates and addresses
  final List<Map<String, dynamic>> mockLocations = [
    {
      'address': 'Kempegowda International Airport (BLR)',
      'latitude': 13.1986,
      'longitude': 77.7066,
    },
    {
      'address': 'Manyata Tech Park, Hebbal',
      'latitude': 13.0451,
      'longitude': 77.6266,
    },
    {
      'address': 'Indiranagar Metro Station',
      'latitude': 12.9784,
      'longitude': 77.6408,
    },
    {
      'address': 'MG Road Metro Station',
      'latitude': 12.9750,
      'longitude': 77.6000,
    },
    {
      'address': 'Forum Mall, Koramangala',
      'latitude': 12.9344,
      'longitude': 77.6111,
    },
    {
      'address': 'Phoenix Marketcity, Mahadevapura',
      'latitude': 12.9958,
      'longitude': 77.6964,
    },
    {
      'address': 'Majestic Railway Station',
      'latitude': 12.9781,
      'longitude': 77.5697,
    },
    {
      'address': 'UB City, Vittal Mallya Road',
      'latitude': 12.9719,
      'longitude': 77.5958,
    },
    {
      'address': 'Bannerghatta National Park',
      'latitude': 12.8009,
      'longitude': 77.5777,
    },
    {
      'address': 'Whitefield ITPL',
      'latitude': 12.9876,
      'longitude': 77.7376,
    },
    {
      'address': 'Lalbagh Botanical Garden',
      'latitude': 12.9507,
      'longitude': 77.5844,
    },
    {
      'address': 'Commercial Street, Shivaji Nagar',
      'latitude': 12.9822,
      'longitude': 77.6083,
    },
    {
      'address': 'Electronic City Phase 1',
      'latitude': 12.8452,
      'longitude': 77.6633,
    },
    {
      'address': 'Orion Mall, Rajajinagar',
      'latitude': 13.0111,
      'longitude': 77.5550,
    },
    {
      'address': 'HAL Aerospace Museum',
      'latitude': 12.9562,
      'longitude': 77.6727,
    },
  ];

  // Calculated estimates helper
  List<Map<String, dynamic>> getEstimates(double distanceKm) {
    final double factor = (distanceKm / 5.0).clamp(0.5, 4.0);
    return [
      {
        'id': 'economy',
        'name': 'Ridoo Economy',
        'icon': 'directions_car_rounded',
        'price': double.parse((12.50 * factor).toStringAsFixed(2)),
        'eta': (distanceKm * 2 + 2).round(),
      },
      {
        'id': 'comfort',
        'name': 'Ridoo Comfort',
        'icon': 'electric_car_rounded',
        'price': double.parse((18.20 * factor).toStringAsFixed(2)),
        'eta': (distanceKm * 2 + 1).round(),
      },
      {
        'id': 'premium',
        'name': 'Ridoo Premium',
        'icon': 'stars_rounded',
        'price': double.parse((24.60 * factor).toStringAsFixed(2)),
        'eta': (distanceKm * 1.8 + 1).round(),
      },
      {
        'id': 'xl',
        'name': 'Ridoo XL',
        'icon': 'airport_shuttle_rounded',
        'price': double.parse((34.10 * factor).toStringAsFixed(2)),
        'eta': (distanceKm * 2.2 + 3).round(),
      },
    ];
  }



  void startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_activeRide != null) {
        pollRideStatus(_activeRide!['id']);
      } else {
        timer.cancel();
      }
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  void _initSocketConnection(int rideId) {
    final token = LocalStorage.getToken();
    if (token != null) {
      _socketService.connect(token);
      _socketService.subscribeToRide(
        rideId,
        onLocationUpdate: (data) {
          if (_activeRide != null && _activeRide!['driver'] != null) {
            _activeRide!['driver']['current_latitude'] = data['latitude'];
            _activeRide!['driver']['current_longitude'] = data['longitude'];
            notifyListeners();
          }
        },
        onStatusUpdate: (data) {
          if (_activeRide != null) {
            _activeRide!['status'] = data['status'];
            if (data['payload'] != null) {
              _activeRide = data['payload'];
            }
            final status = _activeRide!['status'];
            if (status == 'completed' || status == 'cancelled') {
              stopPolling();
              _socketService.disconnect();
            }
            notifyListeners();
          }
        },
      );
    }
  }

  Future<void> checkAuthStatus() async {
    final token = LocalStorage.getToken();
    final user = LocalStorage.getUser();

    if (token != null && user != null && _activeRide != null) {
      _initSocketConnection(_activeRide!['id']);
    }
  }

  Future<bool> requestRide({
    required String pickupAddress,
    required double pickupLat,
    required double pickupLng,
    required String dropAddress,
    required double dropLat,
    required double dropLng,
    required String rideType,
    required String paymentMethod,
  }) async {
    _isSearching = true;
    _setError(null);
    notifyListeners();

    try {
      final response = await ApiClient.post('/rides', {
        'pickup_address': pickupAddress,
        'pickup_latitude': pickupLat,
        'pickup_longitude': pickupLng,
        'drop_address': dropAddress,
        'drop_latitude': dropLat,
        'drop_longitude': dropLng,
        'ride_type': rideType,
        'payment_method': paymentMethod,
      });

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        _activeRide = data;
        _isSearching = true;
        notifyListeners();
        _initSocketConnection(_activeRide!['id']);
        startPolling();
        return true;
      } else {
        throw Exception(data['message'] ?? 'Failed to request ride');
      }
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _isSearching = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> pollRideStatus(int rideId) async {
    try {
      final response = await ApiClient.get('/rides/$rideId');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _activeRide = data;

        final status = _activeRide!['status'];
        if (status != 'searching') {
          _isSearching = false;
        }

        if (status == 'completed' || status == 'cancelled') {
          stopPolling();
          _socketService.disconnect();
        } else {
          // Ensure socket remains connected/subscribed
          _initSocketConnection(rideId);
        }
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<bool> cancelRide(String reason) async {
    if (_activeRide == null) return false;
    _setError(null);

    try {
      final response = await ApiClient.post('/rides/${_activeRide!['id']}/cancel', {
        'reason': reason,
      });
      if (response.statusCode == 200) {
        _activeRide = null;
        _isSearching = false;
        stopPolling();
        _socketService.disconnect();
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to cancel ride');
      }
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  Future<bool> submitRating(int rating, String review) async {
    if (_activeRide == null) return false;
    _setError(null);

    try {
      final response = await ApiClient.post('/rides/${_activeRide!['id']}/rate', {
        'rating': rating,
        'review': review,
      });

      if (response.statusCode == 201) {
        _activeRide = null;
        _isSearching = false;
        _socketService.disconnect();
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to submit rating');
      }
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  void clearActiveRide() {
    _activeRide = null;
    _isSearching = false;
    stopPolling();
    _socketService.disconnect();
    notifyListeners();
  }

  @override
  void dispose() {
    stopPolling();
    _socketService.disconnect();
    super.dispose();
  }
}
