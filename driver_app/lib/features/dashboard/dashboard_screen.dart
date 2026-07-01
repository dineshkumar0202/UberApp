import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridoo_driver/data/providers/auth_provider.dart';
import 'package:ridoo_driver/data/providers/driver_ride_provider.dart';
import 'package:ridoo_driver/features/dashboard/active_trip_panel.dart';
import 'package:ridoo_driver/shared/dialogs/incoming_request_dialog.dart';
import 'package:ridoo_driver/features/wallet/wallet_screen.dart';
import 'package:ridoo_driver/features/profile/profile_screen.dart';
import 'package:ridoo_driver/features/support/support_screen.dart';
import 'package:ridoo_driver/features/ratings/ratings_screen.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final rideProvider = Provider.of<DriverRideProvider>(context);
    final user = authProvider.user;
    final isOnline = rideProvider.isOnline;
    final activeRide = rideProvider.activeRide;
    final pendingRequests = rideProvider.pendingRequests;
    
    final isApproved = user?['driver']?['is_approved'] == true || 
                       user?['driver']?['is_approved'] == 1 || 
                       user?['driver']?['is_approved'] == '1';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _currentIndex == 0
          ? AppBar(
              backgroundColor: Colors.black,
              elevation: 0,
              title: const Text(
                'Ridoo Driver',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              actions: [
                IconButton(
                  onPressed: () async {
                    await rideProvider.toggleOnlineStatus(false);
                    await authProvider.logout();
                  },
                  icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                ),
              ],
            )
          : null,
      body: _currentIndex == 0
          ? Stack(
              children: [
          // Background/Body
          SafeArea(
            child: Column(
              children: [
                // Status bar
                Container(
                  color: isOnline ? Colors.green.shade700 : const Color(0xFFE05A00),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    children: [
                      Icon(
                        isOnline ? Icons.check_circle_outline_rounded : Icons.warning_amber_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          isOnline
                              ? 'You are online! Looking for ride requests...'
                              : 'You are offline! Go online to start accepting jobs.',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 28,
                        child: Switch.adaptive(
                          value: isOnline,
                          activeColor: Colors.white,
                          activeTrackColor: Colors.green.shade400,
                          onChanged: (value) async {
                            if (!isApproved) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Account pending admin approval. You cannot go online.'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                              return;
                            }
                            await rideProvider.toggleOnlineStatus(value);
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome & Profile Section
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: const Color(0xFFF7C815).withOpacity(0.15),
                              child: const Icon(Icons.person_rounded, size: 36, color: Colors.black87),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user?['name'] ?? 'Driver Partner',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Basic Vehicle (Verified)',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // Approval Banner or Pending Box (Replaced Navigation Grid)
                        if (isApproved) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF25A365).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFF25A365).withOpacity(0.3), width: 1.5),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF25A365),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
                                ),
                                const SizedBox(width: 16),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Approved Partner',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1E7E4E),
                                          fontSize: 15,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'congragilation your approve Driver in Rido',
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 13,
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.orange.withOpacity(0.3), width: 1.5),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Colors.orange,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.hourglass_empty_rounded, color: Colors.white, size: 22),
                                ),
                                const SizedBox(width: 16),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Approval Pending',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange,
                                          fontSize: 15,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Your documents are under review. Once approved, you can start accepting jobs.',
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 13,
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 28),

                        // Earnings Grid (only shown if not in active ride)
                        if (activeRide == null) ...[
                          const Text(
                            'Today\'s Stats',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  title: 'Earnings',
                                  value: '₹1,240',
                                  icon: Icons.currency_rupee,
                                  color: Colors.green.shade700,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildStatCard(
                                  title: 'Rides',
                                  value: '8 Completed',
                                  icon: Icons.directions_car,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  title: 'Rating',
                                  value: '4.95 ★',
                                  icon: Icons.star,
                                  color: const Color(0xFFF7C815),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildStatCard(
                                  title: 'Online Hours',
                                  value: '5.2h',
                                  icon: Icons.access_time_filled,
                                  color: Colors.teal,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // Status card placeholder
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                  spreadRadius: 1,
                                ),
                              ],
                              border: Border.all(color: Colors.grey[100]!),
                            ),
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF7C815).withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.explore_outlined,
                                    size: 36,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Looking for Ride Requests',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  isOnline
                                      ? 'Requests will show up here automatically. Coordinate: ${rideProvider.currentLat.toStringAsFixed(4)}, ${rideProvider.currentLng.toStringAsFixed(4)}'
                                      : 'Please go online to start receiving ride offers.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          // Map placeholder showing tracking
                          Container(
                            height: 300,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.navigation_outlined, size: 48, color: Colors.blueAccent),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Simulated Navigation Tracking Active',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'GPS: ${rideProvider.currentLat.toStringAsFixed(4)}, ${rideProvider.currentLng.toStringAsFixed(4)}',
                                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Pending request overlay dialog
          if (isOnline && pendingRequests.isNotEmpty && activeRide == null)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: IncomingRequestDialog(
                  request: pendingRequests.first,
                ),
              ),
            ),

          // Active ride controls at bottom
          if (activeRide != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ActiveTripPanel(
                ride: activeRide,
              ),
            ),
              ],
            )
          : (_currentIndex == 1
              ? const WalletScreen()
              : (_currentIndex == 2
                  ? const RatingsScreen()
                  : const ProfileScreen())),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_rounded),
            label: 'Ratings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLink({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7C815).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.black87, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
