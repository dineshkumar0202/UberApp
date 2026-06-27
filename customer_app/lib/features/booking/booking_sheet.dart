import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridoo_customer/core/theme/colors.dart';
import 'package:ridoo_customer/data/providers/ride_provider.dart';

class BookingSheet extends StatefulWidget {
  final double distanceKm;
  final Function(String rideType, String paymentMethod) onBook;
  final VoidCallback onCancel;

  const BookingSheet({
    super.key,
    required this.distanceKm,
    required this.onBook,
    required this.onCancel,
  });

  @override
  State<BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<BookingSheet> {
  String _selectedRideType = 'economy';
  String _selectedPaymentMethod = 'cash';

  IconData _getRideIcon(String iconName) {
    switch (iconName) {
      case 'electric_car_rounded':
        return Icons.electric_car_rounded;
      case 'stars_rounded':
        return Icons.stars_rounded;
      case 'airport_shuttle_rounded':
        return Icons.airport_shuttle_rounded;
      case 'directions_car_rounded':
      default:
        return Icons.directions_car_rounded;
    }
  }

  void _showSchedulePicker() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.charcoalBlack,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date == null) return;

    if (mounted) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppColors.primary,
                onPrimary: Colors.white,
                onSurface: AppColors.charcoalBlack,
              ),
            ),
            child: child!,
          );
        },
      );
      if (time == null) return;

      final scheduledDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: AppColors.accentGreen),
              SizedBox(width: 8),
              Text('Ride Scheduled', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            'Your Ridoo trip has been scheduled for:\n\n${scheduledDateTime.toString().substring(0, 16)}',
            style: const TextStyle(fontSize: 14, height: 1.4, fontWeight: FontWeight.w500),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onCancel();
              },
              child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    final estimates = rideProvider.getEstimates(widget.distanceKm);

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Choose a ride',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: widget.onCancel,
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Estimates list
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: estimates.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final estimate = estimates[index];
              final isSelected = _selectedRideType == estimate['id'];

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedRideType = estimate['id'];
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withOpacity(0.08) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getRideIcon(estimate['icon']),
                        size: 40,
                        color: isSelected ? AppColors.primary : Colors.black87,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              estimate['name'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'ETA: ${estimate['eta']} mins',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₹${estimate['price']}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Payment selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _selectedPaymentMethod,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'cash', child: Text('Cash Payment')),
                      DropdownMenuItem(value: 'wallet', child: Text('Wallet Balance')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedPaymentMethod = value;
                        });
                      }
                    },
                  ),
                ],
              ),
              Text(
                'Distance: ${widget.distanceKm.toStringAsFixed(1)} km',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Action Row
          Row(
            children: [
              Expanded(
                flex: 4,
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => widget.onBook(_selectedRideType, _selectedPaymentMethod),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Confirm Ride',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _showSchedulePicker,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary.withOpacity(0.08),
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                      padding: EdgeInsets.zero,
                    ),
                    child: const Icon(Icons.calendar_month_rounded, size: 24),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
