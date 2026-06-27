import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridoo_customer/core/theme/colors.dart';
import 'package:ridoo_customer/data/providers/ride_provider.dart';

class ActiveRideSheet extends StatefulWidget {
  final Map<String, dynamic> ride;

  const ActiveRideSheet({super.key, required this.ride});

  @override
  State<ActiveRideSheet> createState() => _ActiveRideSheetState();
}

class _ActiveRideSheetState extends State<ActiveRideSheet> {
  int _selectedRating = 5;
  final TextEditingController _reviewController = TextEditingController();

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    final double dLat = (lat2 - lat1).abs();
    final double dLon = (lon2 - lon1).abs();
    return double.parse((dLat * 111 + dLon * 85 + 1.2).toStringAsFixed(2));
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'accepted':
        return 'Driver is heading to your location';
      case 'arrived':
        return 'Driver has arrived at pickup point';
      case 'started':
        return 'Trip in progress — Safe travels!';
      case 'completed':
        return 'Trip Completed';
      default:
        return 'Active Ride';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'accepted':
        return Colors.blue;
      case 'arrived':
        return AppColors.accentGreen;
      case 'started':
        return AppColors.primary;
      case 'completed':
      default:
        return AppColors.charcoalBlack;
    }
  }

  Widget _buildRatingView(BuildContext context, RideProvider provider) {
    final double finalPrice = double.tryParse(widget.ride['price']?.toString() ?? '18.60') ?? 18.60;
    
    final double baseFare = finalPrice * 0.20;
    final double distanceFare = finalPrice * 0.60;
    final double timeFare = finalPrice * 0.20;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.accentGreen,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, size: 40, color: Colors.white),
        ),
        const SizedBox(height: 16),
        const Text(
          'Ride Completed Successfully!',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.charcoalBlack),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              Text(
                'Total Fare Paid',
                style: TextStyle(fontSize: 13, color: Colors.grey[500], fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                '₹${finalPrice.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              
              _buildBreakdownRow('Base Fare', '₹${baseFare.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              _buildBreakdownRow('Distance Fare', '₹${distanceFare.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              _buildBreakdownRow('Time & Tolls', '₹${timeFare.toStringAsFixed(2)}'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        const Text(
          'Rate your experience',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.charcoalBlack),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final starVal = index + 1;
            return IconButton(
              onPressed: () {
                setState(() {
                  _selectedRating = starVal;
                });
              },
              icon: Icon(
                _selectedRating >= starVal ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 36,
                color: AppColors.accentYellow,
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _reviewController,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'Write a review (optional)...',
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final success = await provider.submitRating(
                _selectedRating,
                _reviewController.text.trim(),
              );
              if (success) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Thank you for rating!'), backgroundColor: AppColors.accentGreen),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Submit Feedback', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildBreakdownRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.charcoalBlack),
        ),
      ],
    );
  }

  Widget _buildActiveTripView(BuildContext context, RideProvider provider, Map<String, dynamic> driver) {
    final status = widget.ride['status'];
    final user = driver['user'] ?? {};
    final vehicle = driver['vehicle'] ?? {};
    final showCancel = status == 'accepted' || status == 'arrived';

    final double custLat = double.tryParse(widget.ride['pickup_latitude']?.toString() ?? '') ?? 12.971598;
    final double custLng = double.tryParse(widget.ride['pickup_longitude']?.toString() ?? '') ?? 77.594562;
    
    final double? drLat = double.tryParse(driver['current_latitude']?.toString() ?? '');
    final double? drLng = double.tryParse(driver['current_longitude']?.toString() ?? '');

    double? driverDistance;
    if (drLat != null && drLng != null) {
      driverDistance = _calculateDistance(custLat, custLng, drLat, drLng);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status.toString().toUpperCase(),
                style: TextStyle(
                  color: _getStatusColor(status),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _getStatusText(status),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
        if (driverDistance != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.12)),
            ),
            child: Row(
              children: [
                const Icon(Icons.directions_car_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 10),
                Text(
                  'Driver is $driverDistance km away from you',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),

        Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: const Icon(Icons.person, size: 28, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['name'] ?? 'Driver Partner',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: AppColors.accentYellow, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        driver['rating']?.toString() ?? '5.00',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '•  ${vehicle['color'] ?? 'White'} ${vehicle['make'] ?? 'Car'}',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Calling Driver Partner...'), backgroundColor: AppColors.primary),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.call_rounded, color: AppColors.primary, size: 20),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening Chat...'), backgroundColor: AppColors.primary),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.chat_bubble_rounded, color: AppColors.primary, size: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('License Plate', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey)),
              Text(
                vehicle['plate_number'] ?? 'KA-01-XX-0000',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('SOS Alert Dispatched to Emergency Contacts!'), backgroundColor: Colors.red),
                  );
                },
                icon: const Icon(Icons.warning_amber_rounded, color: Colors.red),
                label: const Text('SOS Alert', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            if (showCancel) ...[
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final success = await provider.cancelRide('User requested cancellation');
                    if (success) {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Ride Cancelled Successfully.'), backgroundColor: Colors.orange),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Cancel Ride', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final rideProvider = Provider.of<RideProvider>(context);
    final status = widget.ride['status'];
    final driver = widget.ride['driver'];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: status == 'completed'
          ? _buildRatingView(context, rideProvider)
          : (driver != null
              ? _buildActiveTripView(context, rideProvider, driver)
              : const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Updating driver details...', style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                )),
    );
  }
}
