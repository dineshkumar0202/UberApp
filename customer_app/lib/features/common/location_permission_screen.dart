import 'package:flutter/material.dart';
import 'package:ridoo_customer/core/theme/colors.dart';

class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() => _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> {
  bool _isProcessing = false;

  void _requestPermission() async {
    setState(() {
      _isProcessing = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });

      // Show mock success message and pop
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Permission Granted'),
          content: const Text('Ridoo has successfully acquired GPS coordinates! You can now request a ride.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Pop dialog
                Navigator.pop(context); // Pop screen
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.my_location_rounded,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Enable Location Access',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5),
              ),
              const SizedBox(height: 12),
              Text(
                'Ridoo requires location permissions to detect your current position, match you with nearby drivers, and provide turn-by-turn navigation tracking.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 14, height: 1.4),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _requestPermission,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Grant Location Access',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
                child: const Text('Not Now', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
