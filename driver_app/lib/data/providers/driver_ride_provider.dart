import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ridoo_driver/core/network/api_client.dart';
import 'package:ridoo_driver/core/storage/local_storage.dart';
import 'package:ridoo_driver/data/services/socket_service.dart';

class DriverRideProvider extends ChangeNotifier {
  final SocketService _socketService = SocketService();
  bool _isOnline = false;
  Map<String, dynamic>? _activeRide;
  List<Map<String, dynamic>> _pendingRequests = [];
  Timer? _pollingTimer;
  double _currentLat = 12.9716; // Bangalore MG Road default
  double _currentLng = 77.5946;

  StreamSubscription<Position>? _positionStreamSubscription;

  bool get isOnline => _isOnline;
  Map<String, dynamic>? get activeRide => _activeRide;
  List<Map<String, dynamic>> get pendingRequests => _pendingRequests;
  double get currentLat => _currentLat;
  double get currentLng => _currentLng;

  Future<void> _startGpsTracking() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      _positionStreamSubscription?.cancel();
      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen((Position position) {
        _currentLat = position.latitude;
        _currentLng = position.longitude;
        notifyListeners();
        syncLocation(_currentLat, _currentLng);
      });
    } catch (_) {}
  }

  void _stopGpsTracking() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  void startPolling() {
    _startGpsTracking();
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_isOnline) {
        if (_positionStreamSubscription == null) {
          _simulateLocationMovement();
          syncLocation(_currentLat, _currentLng);
        }

        if (_activeRide == null) {
          pollPendingRequests();
        } else {
          pollActiveRideStatus(_activeRide!['id']);
        }
      } else {
        timer.cancel();
      }
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  void _initSocketConnection() {
    final token = LocalStorage.getToken();
    final user = LocalStorage.getUser();
    
    if (token != null && user != null && user['driver'] != null) {
      _socketService.connect(token);
      _socketService.subscribeToDriver(
        user['driver']['id'],
        onRideRequested: (rideData) {
          final alreadyExists = _pendingRequests.any((req) => req['id'] == rideData['id']);
          if (!alreadyExists) {
            _pendingRequests.add(rideData);
            notifyListeners();
          }
        },
      );
    }
  }

  void _simulateLocationMovement() {
    if (_activeRide == null) {
      _currentLat += (0.0001 - (0.0002 * (DateTime.now().millisecond % 100) / 100));
      _currentLng += (0.0001 - (0.0002 * (DateTime.now().millisecond % 50) / 50));
    } else {
      final status = _activeRide!['status'];
      double targetLat;
      double targetLng;

      if (status == 'accepted') {
        targetLat = double.parse(_activeRide!['pickup_latitude'].toString());
        targetLng = double.parse(_activeRide!['pickup_longitude'].toString());
      } else if (status == 'started') {
        targetLat = double.parse(_activeRide!['drop_latitude'].toString());
        targetLng = double.parse(_activeRide!['drop_longitude'].toString());
      } else {
        return;
      }

      final latStep = (targetLat - _currentLat) * 0.15;
      final lngStep = (targetLng - _currentLng) * 0.15;

      if (latStep.abs() < 0.0002 && lngStep.abs() < 0.0002) {
        _currentLat = targetLat;
        _currentLng = targetLng;
      } else {
        _currentLat += latStep;
        _currentLng += lngStep;
      }
    }
  }

  Future<void> syncLocation(double lat, double lng) async {
    try {
      await ApiClient.post('/driver/location', {
        'latitude': lat,
        'longitude': lng,
      });
    } catch (_) {}
  }

  Future<bool> toggleOnlineStatus(bool online) async {
    try {
      final path = online ? '/driver/online' : '/driver/offline';
      final response = await ApiClient.post(path, {});
      if (response.statusCode == 200) {
        _isOnline = online;
        if (online) {
          _currentLat = 12.9716;
          _currentLng = 77.5946;
          await syncLocation(_currentLat, _currentLng);
          _initSocketConnection();
          startPolling();
        } else {
          _stopGpsTracking();
          stopPolling();
          _socketService.disconnect();
          _pendingRequests.clear();
        }
        notifyListeners();
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<void> pollPendingRequests() async {
    try {
      final response = await ApiClient.get('/driver/rides/pending');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _pendingRequests = data.cast<Map<String, dynamic>>();
        notifyListeners();
        _initSocketConnection(); // Ensure socket connection is alive
      }
    } catch (_) {}
  }

  Future<void> pollActiveRideStatus(int rideId) async {
    try {
      final response = await ApiClient.get('/rides/$rideId');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _activeRide = data;

        final status = _activeRide!['status'];
        if (status == 'cancelled') {
          _activeRide = null;
          pollPendingRequests();
        }
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<bool> acceptRide(int rideId) async {
    try {
      final response = await ApiClient.post('/rides/$rideId/accept', {});
      if (response.statusCode == 200) {
        _activeRide = jsonDecode(response.body);
        _pendingRequests.clear();
        notifyListeners();
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<bool> arriveAtPickup() async {
    if (_activeRide == null) return false;
    try {
      final response = await ApiClient.post('/rides/${_activeRide!['id']}/arrive', {});
      if (response.statusCode == 200) {
        _activeRide = jsonDecode(response.body);
        notifyListeners();
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<bool> startRide() async {
    if (_activeRide == null) return false;
    try {
      final response = await ApiClient.post('/rides/${_activeRide!['id']}/start', {});
      if (response.statusCode == 200) {
        _activeRide = jsonDecode(response.body);
        notifyListeners();
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<bool> completeRide() async {
    if (_activeRide == null) return false;
    try {
      final response = await ApiClient.post('/rides/${_activeRide!['id']}/complete', {});
      if (response.statusCode == 200) {
        _activeRide = null;
        notifyListeners();
        return true;
      }
    } catch (_) {}
    return false;
  }

  void rejectRequest(int rideId) {
    _pendingRequests.removeWhere((req) => req['id'] == rideId);
    notifyListeners();
  }

  @override
  void dispose() {
    _stopGpsTracking();
    stopPolling();
    _socketService.disconnect();
    super.dispose();
  }
}
