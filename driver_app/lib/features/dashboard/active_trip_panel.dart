import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridoo_driver/data/providers/driver_ride_provider.dart';

class ActiveTripPanel extends StatelessWidget {
  final Map<String, dynamic> ride;

  const ActiveTripPanel({super.key, required this.ride});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DriverRideProvider>(context, listen: false);
    final status = ride['status'];
    final pickup = ride['pickup_address'] ?? 'Pickup';
    final drop = ride['drop_address'] ?? 'Drop';
    final customer = ride['customer'] ?? {};
    final customerName = customer['name'] ?? 'Passenger';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Current Ride',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  status.toString().toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Passenger info row
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey[200],
                child: const Icon(Icons.person, color: Colors.grey),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customerName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Payment method: ${ride['payment_method']?.toString().toUpperCase()}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  // Mock Phone Call
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Calling $customerName...')),
                  );
                },
                icon: const Icon(Icons.phone, color: Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Details depending on status
          if (status == 'accepted') ...[
            const Text(
              'PICKUP LOCATION',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 6),
            Text(
              pickup,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  await provider.arriveAtPickup();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Arrived at Pickup', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ] else if (status == 'arrived') ...[
            const Text(
              'PICKUP LOCATION (ARRIVED)',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 6),
            Text(
              pickup,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  await provider.startRide();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Start Trip', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ] else if (status == 'started') ...[
            const Text(
              'DESTINATION',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 6),
            Text(
              drop,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  final success = await provider.completeRide();
                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Trip Completed Successfully!'), backgroundColor: Colors.green),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('End Trip & Collect Fare', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
