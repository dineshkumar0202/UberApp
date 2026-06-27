import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:ridoo_customer/core/config/app_config.dart';

class SocketService {
  WebSocketChannel? _channel;
  bool _isConnected = false;

  void connect(String token) {
    if (_isConnected) return;
    try {
      final uri = Uri.parse('${AppConfig.socketUrl}?token=$token');
      _channel = WebSocketChannel.connect(uri);
      _isConnected = true;
    } catch (_) {}
  }

  void subscribeToRide(
    int rideId, {
    required Function(Map<String, dynamic> data) onLocationUpdate,
    required Function(Map<String, dynamic> data) onStatusUpdate,
  }) {
    if (_channel == null) return;

    // Send subscribe message using Pusher/Reverb standard protocol
    final subscribeMessage = jsonEncode({
      'event': 'pusher:subscribe',
      'data': {
        'channel': 'private-ride.$rideId',
      }
    });
    _channel!.sink.add(subscribeMessage);

    _channel!.stream.listen(
      (message) {
        try {
          final payload = jsonDecode(message);
          final event = payload['event'];
          final data = payload['data'] is String ? jsonDecode(payload['data']) : payload['data'];

          // Laravel Echo default event namespaces
          if (event == 'App\\Events\\DriverLocationUpdated' || event == 'DriverLocationUpdated') {
            onLocationUpdate(data);
          } else if (event == 'App\\Events\\RideStatusUpdated' || event == 'RideStatusUpdated') {
            onStatusUpdate(data);
          }
        } catch (_) {}
      },
      onError: (err) {
        _isConnected = false;
      },
      onDone: () {
        _isConnected = false;
      },
      cancelOnError: false,
    );
  }

  void disconnect() {
    _channel?.sink.close();
    _isConnected = false;
  }
}
