import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:ridoo_driver/core/config/app_config.dart';

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

  void subscribeToDriver(
    int driverId, {
    required Function(Map<String, dynamic> data) onRideRequested,
  }) {
    if (_channel == null) return;

    // Send subscribe message using Pusher/Reverb standard protocol
    final subscribeMessage = jsonEncode({
      'event': 'pusher:subscribe',
      'data': {
        'channel': 'private-driver.$driverId',
      }
    });
    _channel!.sink.add(subscribeMessage);

    _channel!.stream.listen(
      (message) {
        try {
          final payload = jsonDecode(message);
          final event = payload['event'];
          final data = payload['data'] is String ? jsonDecode(payload['data']) : payload['data'];

          // Laravel Echo default event name
          if (event == 'App\\Events\\RideRequested' || event == 'RideRequested') {
            final ride = data['ride'];
            if (ride != null) {
              onRideRequested(ride);
            }
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
