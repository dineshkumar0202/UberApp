import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridoo_customer/core/theme/colors.dart';
import 'package:ridoo_customer/data/providers/ride_provider.dart';

class RideHistoryScreen extends StatefulWidget {
  const RideHistoryScreen({super.key});

  @override
  State<RideHistoryScreen> createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends State<RideHistoryScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() {
      _isLoading = true;
    });
    await Provider.of<RideProvider>(context, listen: false).fetchRideHistory();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showRideDetails(Map<String, dynamic> ride) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Ride Details',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: RIDO-${ride['id']}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 24),

                // Driver Details Row
                if (ride['driver'] != null) ...[
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: const Icon(Icons.person, color: AppColors.primary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ride['driver']['user']?['name'] ?? 'Driver Partner',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              ride['driver']['vehicle'] != null
                                  ? '${ride['driver']['vehicle']['color']} ${ride['driver']['vehicle']['make']} (${ride['driver']['vehicle']['plate_number']})'
                                  : 'Verified Driver',
                              style: TextStyle(color: Colors.grey[600], fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 36),
                ],

                // Route summary
                const Text('Route', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Column(
                      children: [
                        const Icon(Icons.radio_button_checked, color: AppColors.primary, size: 18),
                        Container(width: 2, height: 32, color: Colors.grey[300]),
                        const Icon(Icons.location_on, color: AppColors.accentOrange, size: 18),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ride['pickup_address'] ?? 'Pickup Address',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 28),
                          Text(
                            ride['drop_address'] ?? 'Drop Address',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 36),

                // Bill breakdown
                const Text('Fare Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 16),
                _buildReceiptRow('Base Fare', '₹${(double.parse(ride['fare'].toString()) * 0.3).toStringAsFixed(2)}'),
                const SizedBox(height: 10),
                _buildReceiptRow('Distance Rate', '₹${(double.parse(ride['fare'].toString()) * 0.5).toStringAsFixed(2)}'),
                const SizedBox(height: 10),
                _buildReceiptRow('Tolls & Taxes', '₹${(double.parse(ride['fare'].toString()) * 0.2).toStringAsFixed(2)}'),
                const Divider(height: 24),
                _buildReceiptRow(
                  'Total Paid',
                  '₹${double.parse(ride['fare'].toString()).toStringAsFixed(2)}',
                  isBold: true,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 16),
                _buildReceiptRow('Payment Method', (ride['payment_method'] ?? 'Wallet').toString().toUpperCase()),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 15 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isBold ? AppColors.charcoalBlack : Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color ?? AppColors.charcoalBlack,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final rideProvider = Provider.of<RideProvider>(context);
    final history = rideProvider.rideHistory;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Rides', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchHistory,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : history.isEmpty
                ? SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.7,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.directions_car_outlined, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          const Text(
                            'No Rides Found',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your completed and cancelled ride history will appear here.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[500], fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: history.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final ride = history[index];
                      final isCompleted = ride['status'] == 'completed';
                      final fare = double.parse(ride['fare']?.toString() ?? '0.0');

                      return GestureDetector(
                        onTap: () => _showRideDetails(ride),
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.local_taxi_rounded, color: AppColors.primary, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        (ride['ride_type'] ?? 'Economy').toString().toUpperCase(),
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isCompleted
                                          ? AppColors.accentGreen.withOpacity(0.1)
                                          : Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      (ride['status'] ?? 'Completed').toString().toUpperCase(),
                                      style: TextStyle(
                                        color: isCompleted ? AppColors.accentGreen : Colors.red,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              Row(
                                children: [
                                  const Icon(Icons.circle, color: AppColors.primary, size: 8),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      ride['pickup_address'] ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: Colors.grey[700], fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(Icons.circle, color: AppColors.accentOrange, size: 8),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      ride['drop_address'] ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: Colors.grey[700], fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    ride['created_at'] != null
                                        ? DateTime.parse(ride['created_at'])
                                            .toLocal()
                                            .toString()
                                            .substring(0, 16)
                                        : '',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                                  ),
                                  Text(
                                    '₹${fare.toStringAsFixed(2)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
