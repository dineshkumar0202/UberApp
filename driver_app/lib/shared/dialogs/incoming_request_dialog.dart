import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridoo_driver/data/providers/driver_ride_provider.dart';

class IncomingRequestDialog extends StatefulWidget {
  final Map<String, dynamic> request;

  const IncomingRequestDialog({super.key, required this.request});

  @override
  State<IncomingRequestDialog> createState() => _IncomingRequestDialogState();
}

class _IncomingRequestDialogState extends State<IncomingRequestDialog> {
  int _secondsRemaining = 15;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_secondsRemaining > 0) {
            _secondsRemaining--;
          } else {
            _timer?.cancel();
            // Automatically decline
            final provider = Provider.of<DriverRideProvider>(context, listen: false);
            provider.rejectRequest(widget.request['id']);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DriverRideProvider>(context, listen: false);
    final rideId = widget.request['id'];
    final pickup = widget.request['pickup_address'] ?? 'Pickup Address';
    final drop = widget.request['drop_address'] ?? 'Drop Address';
    final rideType = widget.request['ride_type'] ?? 'Economy';
    
    // Estimates calculation
    final distance = widget.request['distance_km'] != null 
        ? double.parse(widget.request['distance_km'].toString())
        : 3.5;
    
    final fare = widget.request['total_fare'] ?? (50 + (distance * 15)).round();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 16,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    rideType.toString().toUpperCase(),
                    style: const TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        value: _secondsRemaining / 15,
                        strokeWidth: 3,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                      ),
                    ),
                    Text(
                      '$_secondsRemaining',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'New Job Request!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Route Details Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.my_location, size: 16, color: Colors.green),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          pickup,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 16, color: Colors.redAccent),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          drop,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Fare and Distance info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ESTIMATED FARE',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹$fare',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'DISTANCE',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${distance.toStringAsFixed(1)} km',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _timer?.cancel();
                      provider.rejectRequest(rideId);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      side: const BorderSide(color: Colors.grey),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Decline', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      _timer?.cancel();
                      final messenger = ScaffoldMessenger.of(context);
                      final success = await provider.acceptRide(rideId);
                      if (success) {
                        messenger.showSnackBar(
                          const SnackBar(content: Text('Ride Accepted! Navigate to pickup.'), backgroundColor: Colors.green),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text('Accept', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
