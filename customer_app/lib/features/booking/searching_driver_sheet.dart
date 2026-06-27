import 'package:flutter/material.dart';
import 'package:ridoo_customer/core/theme/colors.dart';

class SearchingDriverSheet extends StatefulWidget {
  final String pickupAddress;
  final String dropAddress;
  final VoidCallback onCancel;

  const SearchingDriverSheet({
    super.key,
    required this.pickupAddress,
    required this.dropAddress,
    required this.onCancel,
  });

  @override
  State<SearchingDriverSheet> createState() => _SearchingDriverSheetState();
}

class _SearchingDriverSheetState extends State<SearchingDriverSheet> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 12),
          // Radar pulse animation
          Stack(
            alignment: Alignment.center,
            children: [
              // Pulse ring 1
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Container(
                    width: 180 * _animationController.value,
                    height: 180 * _animationController.value,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(1.0 - _animationController.value),
                      shape: BoxShape.circle,
                    ),
                  );
                },
              ),
              // Pulse ring 2 (delayed by 0.5)
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  double val = (_animationController.value + 0.5) % 1.0;
                  return Container(
                    width: 180 * val,
                    height: 180 * val,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(1.0 - val),
                      shape: BoxShape.circle,
                    ),
                  );
                },
              ),
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.charcoalBlack,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.directions_car_filled_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'Finding your driver...',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Contacting nearby drivers partner...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          
          // Address details card
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
                    const Icon(Icons.my_location, size: 18, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.pickupAddress,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
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
                    const Icon(Icons.location_on_rounded, size: 18, color: Colors.redAccent),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.dropAddress,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Cancel Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: widget.onCancel,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Cancel Ride',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
