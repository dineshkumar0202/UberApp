import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ridoo_customer/core/theme/colors.dart';
import 'package:ridoo_customer/data/providers/auth_provider.dart';
import 'package:ridoo_customer/data/providers/ride_provider.dart';
import 'package:ridoo_customer/features/booking/booking_sheet.dart';
import 'package:ridoo_customer/features/booking/searching_driver_sheet.dart';
import 'package:ridoo_customer/features/ride_tracking/active_ride_sheet.dart';
import 'package:ridoo_customer/features/wallet/wallet_screen.dart';
import 'package:ridoo_customer/features/profile/profile_screen.dart';
import 'package:ridoo_customer/features/ride_history/ride_history_screen.dart';
import 'package:ridoo_customer/features/support/support_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ridoo_customer/features/sos/sos_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? _mapController;
  LatLng? _liveLatLng;
  bool _showLocationPicker = false;
  Map<String, dynamic>? _pickupLocation;
  Map<String, dynamic>? _dropLocation;
  Map<String, dynamic>? _stopLocation;
  bool _isChoosingStop = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final List<Map<String, dynamic>> _recentSearches = [
    {
      'address': 'Koramangala Club, Bengaluru',
      'latitude': 12.9348,
      'longitude': 77.6189,
    },
    {
      'address': 'Commercial Street, Tasker Town',
      'latitude': 12.9822,
      'longitude': 77.6083,
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndGetLiveLocation();
    });
  }

  Future<void> _checkAndGetLiveLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      
      if (permission == LocationPermission.deniedForever) return;

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );

      setState(() {
        _liveLatLng = LatLng(position.latitude, position.longitude);
        _pickupLocation = {
          'address': 'Current Location (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})',
          'latitude': position.latitude,
          'longitude': position.longitude,
        };
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          15,
        ),
      );
    } catch (_) {}
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    final double dLat = (lat2 - lat1).abs();
    final double dLon = (lon2 - lon1).abs();
    return double.parse((dLat * 111 + dLon * 85 + 1.2).toStringAsFixed(2));
  }

  List<LatLng> decodePolylinePoints(String encodedPolyline) {
    try {
      final bytes = base64Decode(encodedPolyline);
      final decodedJson = jsonDecode(utf8.decode(bytes)) as List;
      return decodedJson.map((coord) => LatLng(coord[0] as double, coord[1] as double)).toList();
    } catch (e) {
      return [];
    }
  }

  void _resetFlow() {
    setState(() {
      _showLocationPicker = false;
      _pickupLocation = null;
      _dropLocation = null;
      _stopLocation = null;
      _isChoosingStop = false;
    });
  }

  void _showMockLocationPicker() {
    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    setState(() {
      _pickupLocation ??= rideProvider.mockLocations[3]; // MG Road
      _showLocationPicker = true;
    });
  }

  void _selectSavedPlace(Map<String, dynamic> location) {
    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    setState(() {
      _pickupLocation ??= rideProvider.mockLocations[3]; // MG Road
      _dropLocation = location;
      _showLocationPicker = false;
    });
  }

  Widget _buildHeaderButton({required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildSavedPlaceChip({required IconData icon, required String label, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.primary, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.charcoalBlack,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleMap(Map<String, dynamic>? activeRide, RideProvider rideProvider) {
    final Set<Marker> markers = {};
    final Set<Polyline> polylines = {};
    LatLng center = const LatLng(12.971598, 77.594562); // Bengaluru MG Road

    double? pLat, pLng, dLat, dLng;
    String? pAddr, dAddr;

    if (activeRide != null) {
      pLat = double.tryParse(activeRide['pickup_latitude']?.toString() ?? '');
      pLng = double.tryParse(activeRide['pickup_longitude']?.toString() ?? '');
      dLat = double.tryParse(activeRide['drop_latitude']?.toString() ?? '');
      dLng = double.tryParse(activeRide['drop_longitude']?.toString() ?? '');
      pAddr = activeRide['pickup_address'];
      dAddr = activeRide['drop_address'];

      final driver = activeRide['driver'];
      if (driver != null) {
        final drLat = double.tryParse(driver['current_latitude']?.toString() ?? '');
        final drLng = double.tryParse(driver['current_longitude']?.toString() ?? '');
        if (drLat != null && drLng != null) {
          markers.add(
            Marker(
              markerId: const MarkerId('driver'),
              position: LatLng(drLat, drLng),
              infoWindow: const InfoWindow(title: 'Driver Location'),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
            ),
          );
        }
      }
    } else {
      pLat = _pickupLocation?['latitude'] as double?;
      pLng = _pickupLocation?['longitude'] as double?;
      dLat = _dropLocation?['latitude'] as double?;
      dLng = _dropLocation?['longitude'] as double?;
      pAddr = _pickupLocation?['address'];
      dAddr = _dropLocation?['address'];
    }

    if (pLat != null && pLng != null) {
      center = LatLng(pLat, pLng);
      markers.add(
        Marker(
          markerId: const MarkerId('pickup'),
          position: LatLng(pLat, pLng),
          infoWindow: InfoWindow(title: 'Pickup: $pAddr'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );

      // Nearby drivers within 2 km of the pickup location
      if (activeRide == null) {
        final List<Map<String, dynamic>> allPotentialDrivers = [
          {
            'id': 'nearby_driver_1',
            'title': 'Ridoo Economy',
            'latitude': pLat + 0.0045,
            'longitude': pLng + 0.0032,
          },
          {
            'id': 'nearby_driver_2',
            'title': 'Ridoo Comfort',
            'latitude': pLat - 0.0028,
            'longitude': pLng + 0.0055,
          },
          {
            'id': 'nearby_driver_3',
            'title': 'Ridoo XL',
            'latitude': pLat + 0.0061,
            'longitude': pLng - 0.0041,
          },
          {
            'id': 'nearby_driver_4',
            'title': 'Ridoo Premium',
            'latitude': pLat - 0.0052,
            'longitude': pLng - 0.0038,
          },
          {
            'id': 'far_driver',
            'title': 'Far Driver (Ridoo Premium)',
            'latitude': pLat + 0.035, // ~4km away
            'longitude': pLng + 0.025,
          }
        ];

        for (final dr in allPotentialDrivers) {
          final double dist = _calculateDistance(pLat, pLng, dr['latitude'] as double, dr['longitude'] as double);
          if (dist <= 2.0) {
            markers.add(
              Marker(
                markerId: MarkerId(dr['id']),
                position: LatLng(dr['latitude'] as double, dr['longitude'] as double),
                infoWindow: InfoWindow(
                  title: 'Available (${dr['title']})',
                  snippet: '${dist.toStringAsFixed(2)} km away',
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
              ),
            );
          }
        }
      }
    }

    if (_stopLocation != null && activeRide == null) {
      markers.add(
        Marker(
          markerId: const MarkerId('stop'),
          position: LatLng(_stopLocation!['latitude'] as double, _stopLocation!['longitude'] as double),
          infoWindow: InfoWindow(title: 'Stop: ${_stopLocation!['address']}'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        ),
      );
    }

    if (dLat != null && dLng != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('drop'),
          position: LatLng(dLat, dLng),
          infoWindow: InfoWindow(title: 'Destination: $dAddr'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );

      if (pLat != null && pLng != null) {
        List<LatLng> polylinePoints = [];
        if (activeRide != null && activeRide['polyline'] != null) {
          polylinePoints = decodePolylinePoints(activeRide['polyline']);
        }

        if (polylinePoints.isEmpty) {
          if (_stopLocation != null && activeRide == null) {
            polylinePoints = [
              LatLng(pLat, pLng),
              LatLng((pLat + (_stopLocation!['latitude'] as double)) / 2 + 0.0005, (pLng + (_stopLocation!['longitude'] as double)) / 2 - 0.0005),
              LatLng(_stopLocation!['latitude'] as double, _stopLocation!['longitude'] as double),
              LatLng(((_stopLocation!['latitude'] as double) + dLat) / 2 + 0.0005, ((_stopLocation!['longitude'] as double) + dLng) / 2 - 0.0005),
              LatLng(dLat, dLng),
            ];
          } else {
            polylinePoints = [
              LatLng(pLat, pLng),
              LatLng((pLat + dLat) / 2 + 0.001, (pLng + dLng) / 2 - 0.001),
              LatLng(dLat, dLng),
            ];
          }
        }

        polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            color: AppColors.primary,
            width: 5,
            points: polylinePoints,
          ),
        );
      }
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: center,
        zoom: 13,
      ),
      markers: markers,
      polylines: polylines,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      onMapCreated: (controller) {
        _mapController = controller;
        double? cpLat, cpLng, cdLat, cdLng;
        if (activeRide != null) {
          cpLat = double.tryParse(activeRide['pickup_latitude']?.toString() ?? '');
          cpLng = double.tryParse(activeRide['pickup_longitude']?.toString() ?? '');
          cdLat = double.tryParse(activeRide['drop_latitude']?.toString() ?? '');
          cdLng = double.tryParse(activeRide['drop_longitude']?.toString() ?? '');
        } else {
          cpLat = _pickupLocation?['latitude'] as double?;
          cpLng = _pickupLocation?['longitude'] as double?;
          cdLat = _dropLocation?['latitude'] as double?;
          cdLng = _dropLocation?['longitude'] as double?;
        }

        if (cpLat != null && cpLng != null && cdLat != null && cdLng != null) {
          controller.animateCamera(
            CameraUpdate.newLatLngBounds(
              LatLngBounds(
                southwest: LatLng(
                  cpLat < cdLat ? cpLat : cdLat,
                  cpLng < cdLng ? cpLng : cdLng,
                ),
                northeast: LatLng(
                  cpLat > cdLat ? cpLat : cdLat,
                  cpLng > cdLng ? cpLng : cdLng,
                ),
              ),
              70,
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final rideProvider = Provider.of<RideProvider>(context);
    final user = authProvider.user;

    final activeRide = rideProvider.activeRide;
    final isSearching = rideProvider.isSearching;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Full-screen map background
          Positioned.fill(
            child: _buildGoogleMap(activeRide, rideProvider),
          ),

          // Live Location floating trigger button
          Positioned(
            right: 16,
            bottom: activeRide != null
                ? 290
                : (_dropLocation != null ? 360 : 210),
            child: FloatingActionButton(
              onPressed: _checkAndGetLiveLocation,
              backgroundColor: Colors.white,
              mini: true,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.my_location_rounded, color: AppColors.primary, size: 22),
            ),
          ),

          // 2. Greeting, Search & Saved Places Floating overlay
          if (activeRide == null && !isSearching && _dropLocation == null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    children: [
                      // Translucent Greeting Card
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome back 👋',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    user?['name'] ?? 'Rider',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.charcoalBlack,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              children: [
                                _buildHeaderButton(
                                  icon: Icons.account_balance_wallet_rounded,
                                  color: AppColors.primary,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const WalletScreen()),
                                    );
                                  },
                                ),
                                const SizedBox(width: 4),
                                _buildHeaderButton(
                                  icon: Icons.history_rounded,
                                  color: AppColors.primary,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const RideHistoryScreen()),
                                    );
                                  },
                                ),
                                const SizedBox(width: 4),
                                _buildHeaderButton(
                                  icon: Icons.help_outline_rounded,
                                  color: AppColors.primary,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const SupportScreen()),
                                    );
                                  },
                                ),
                                const SizedBox(width: 4),
                                _buildHeaderButton(
                                  icon: Icons.sos_rounded,
                                  color: Colors.red,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const SosScreen()),
                                    );
                                  },
                                ),
                                const SizedBox(width: 4),
                                _buildHeaderButton(
                                  icon: Icons.person_rounded,
                                  color: AppColors.primary,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const ProfileScreen()),
                                    );
                                  },
                                ),
                                const SizedBox(width: 4),
                                _buildHeaderButton(
                                  icon: Icons.logout_rounded,
                                  color: Colors.redAccent,
                                  onTap: () async {
                                    rideProvider.clearActiveRide();
                                    await authProvider.logout();
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Search Card
                      GestureDetector(
                        onTap: _showMockLocationPicker,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search_rounded, color: AppColors.primary, size: 24),
                              const SizedBox(width: 12),
                              Text(
                                'Where to?',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Saved places row
                      Row(
                        children: [
                          _buildSavedPlaceChip(
                            icon: Icons.home_rounded,
                            label: 'Home',
                            onTap: () => _selectSavedPlace(rideProvider.mockLocations[3]), // MG Road
                          ),
                          const SizedBox(width: 8),
                          _buildSavedPlaceChip(
                            icon: Icons.work_rounded,
                            label: 'Work',
                            onTap: () => _selectSavedPlace(rideProvider.mockLocations[2]), // Indiranagar
                          ),
                          const SizedBox(width: 8),
                          _buildSavedPlaceChip(
                            icon: Icons.flight_takeoff_rounded,
                            label: 'Airport',
                            onTap: () => _selectSavedPlace(rideProvider.mockLocations[0]), // BLR Airport
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 3. Promo Banner Floating overlay at bottom
          if (activeRide == null && !isSearching && _dropLocation == null)
            Positioned(
              bottom: 24,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.accentOrange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.percent_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '50% OFF FIRST RIDE',
                            style: TextStyle(
                              color: AppColors.accentYellow,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Claim your premium Ridoo discount!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
                  ],
                ),
              ),
            ),

          // 4. Mock Location Picker overlay
          if (_showLocationPicker && _pickupLocation != null) ...[
            Positioned.fill(
              child: GestureDetector(
                onTap: _resetFlow,
                child: Container(
                  color: Colors.black.withOpacity(0.4),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Where to?',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                        ),
                        IconButton(
                          onPressed: _resetFlow,
                          icon: const Icon(Icons.close_rounded, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {
                        _checkAndGetLiveLocation();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Resetting pickup to your current live GPS location...'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.my_location_rounded, color: Colors.green, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pickup: ${_pickupLocation!['address']}',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.green),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (_liveLatLng != null) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      '${_calculateDistance(_liveLatLng!.latitude, _liveLatLng!.longitude, _pickupLocation!['latitude'] as double, _pickupLocation!['longitude'] as double).toStringAsFixed(2)} km from live location',
                                      style: TextStyle(fontSize: 11, color: Colors.green[700], fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'GPS',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Display nearby drivers sorted by distance
                    Builder(
                      builder: (context) {
                        final double? pLat = _pickupLocation?['latitude'] as double?;
                        final double? pLng = _pickupLocation?['longitude'] as double?;
                        if (pLat == null || pLng == null) return const SizedBox();

                        final List<Map<String, dynamic>> allPotentialDrivers = [
                          {
                            'title': 'Ridoo Economy',
                            'latitude': pLat + 0.0045,
                            'longitude': pLng + 0.0032,
                            'icon': Icons.local_taxi_rounded,
                          },
                          {
                            'title': 'Ridoo Comfort',
                            'latitude': pLat - 0.0028,
                            'longitude': pLng + 0.0055,
                            'icon': Icons.directions_car_rounded,
                          },
                          {
                            'title': 'Ridoo XL',
                            'latitude': pLat + 0.0061,
                            'longitude': pLng - 0.0041,
                            'icon': Icons.airport_shuttle_rounded,
                          },
                          {
                            'title': 'Ridoo Premium',
                            'latitude': pLat - 0.0052,
                            'longitude': pLng - 0.0038,
                            'icon': Icons.stars_rounded,
                          },
                          {
                            'title': 'Far Driver',
                            'latitude': pLat + 0.035, // ~4km away
                            'longitude': pLng + 0.025,
                            'icon': Icons.directions_car_rounded,
                          }
                        ];

                        // Calculate distances and filter within 2km
                        final List<Map<String, dynamic>> nearbyDrivers = allPotentialDrivers
                            .map((dr) {
                              final double dist = _calculateDistance(pLat, pLng, dr['latitude'] as double, dr['longitude'] as double);
                              return {...dr, 'distance': dist};
                            })
                            .where((dr) => (dr['distance'] as double) <= 2.0)
                            .toList();

                        // Sort by distance (ascending)
                        nearbyDrivers.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));

                        if (nearbyDrivers.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              'No drivers available nearby (within 2 km)',
                              style: TextStyle(fontSize: 12, color: Colors.red[600], fontWeight: FontWeight.bold),
                            ),
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.airport_shuttle_rounded, size: 14, color: AppColors.primary),
                                const SizedBox(width: 6),
                                Text(
                                  'DRIVERS WITHIN 2 KM (${nearbyDrivers.length} Available)',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 10, letterSpacing: 0.5),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            SizedBox(
                              height: 64,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: nearbyDrivers.length,
                                itemBuilder: (context, index) {
                                  final dr = nearbyDrivers[index];
                                  final double dist = dr['distance'] as double;
                                  return Container(
                                    margin: const EdgeInsets.only(right: 10),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      border: Border.all(color: Colors.grey[200]!),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(dr['icon'] as IconData, size: 24, color: AppColors.primary),
                                        const SizedBox(width: 8),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              dr['title'],
                                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.charcoalBlack),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${dist.toStringAsFixed(2)} km away',
                                              style: TextStyle(fontSize: 10, color: Colors.grey[600], fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        );
                      },
                    ),

                    if (_stopLocation != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on_rounded, color: Colors.orange, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Stop: ${_stopLocation!['address']}',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.orange),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.close_rounded, color: Colors.grey, size: 18),
                              onPressed: () {
                                setState(() {
                                  _stopLocation = null;
                                  _isChoosingStop = false;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    if (_stopLocation == null && !_isChoosingStop) ...[
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _isChoosingStop = true;
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add Stop', style: TextStyle(fontWeight: FontWeight.bold)),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: _isChoosingStop ? 'Enter stop address...' : 'Enter drop-off address...',
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        suffixIcon: _isChoosingStop
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded, color: Colors.grey),
                                onPressed: () {
                                  setState(() {
                                    _isChoosingStop = false;
                                    _searchController.clear();
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'SUGGESTIONS',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 11, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 6),
                    Builder(
                      builder: (context) {
                        final List<Map<String, dynamic>> filteredLocations = rideProvider.mockLocations
                            .where((loc) => loc['address'] != _pickupLocation!['address'])
                            .where((loc) => loc['address'].toString().toLowerCase().contains(_searchQuery.toLowerCase()))
                            .toList();

                        if (filteredLocations.isEmpty && _searchQuery.trim().isNotEmpty) {
                          filteredLocations.add({
                            'address': _searchQuery.trim(),
                            'latitude': 12.9716 + 0.005,
                            'longitude': 77.5946 - 0.005,
                          });
                        }

                        return SizedBox(
                          height: 160,
                          child: ListView.separated(
                            itemCount: filteredLocations.length,
                            separatorBuilder: (context, index) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final loc = filteredLocations[index];
                              final isCustom = loc['address'] == _searchQuery.trim();
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(
                                  isCustom ? Icons.add_location_alt_rounded : Icons.location_on_outlined,
                                  color: isCustom ? AppColors.primary : Colors.redAccent,
                                ),
                                title: Text(
                                  loc['address'],
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () {
                                  setState(() {
                                    if (_isChoosingStop) {
                                      _stopLocation = loc;
                                      _isChoosingStop = false;
                                      _searchController.clear();
                                      _searchQuery = '';
                                    } else {
                                      _dropLocation = loc;
                                      _searchController.clear();
                                      _searchQuery = '';
                                      _showLocationPicker = false;
                                    }
                                  });
                                },
                              );
                            },
                          ),
                        );
                      }
                    ),
                  ],
                ),
              ),
            ),
          ],

          // 5. Booking Estimating Bottom Sheet
          if (_pickupLocation != null && _dropLocation != null && activeRide == null && !isSearching)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BookingSheet(
                distanceKm: _calculateDistance(
                      _pickupLocation!['latitude'] as double,
                      _pickupLocation!['longitude'] as double,
                      _dropLocation!['latitude'] as double,
                      _dropLocation!['longitude'] as double,
                    ) +
                    (_stopLocation != null
                        ? _calculateDistance(
                            _pickupLocation!['latitude'] as double,
                            _pickupLocation!['longitude'] as double,
                            _stopLocation!['latitude'] as double,
                            _stopLocation!['longitude'] as double,
                          )
                        : 0.0),
                onCancel: _resetFlow,
                onBook: (rideType, paymentMethod) async {
                  await rideProvider.requestRide(
                    pickupAddress: _pickupLocation!['address'],
                    pickupLat: _pickupLocation!['latitude'],
                    pickupLng: _pickupLocation!['longitude'],
                    dropAddress: _stopLocation != null
                        ? '${_stopLocation!['address']} ➔ ${_dropLocation!['address']}'
                        : _dropLocation!['address'],
                    dropLat: _dropLocation!['latitude'],
                    dropLng: _dropLocation!['longitude'],
                    rideType: rideType,
                    paymentMethod: paymentMethod,
                  );
                },
              ),
            ),

          // 6. Searching Loader overlay
          if (isSearching)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SearchingDriverSheet(
                pickupAddress: _pickupLocation?['address'] ?? 'Pickup',
                dropAddress: _dropLocation?['address'] ?? 'Destination',
                onCancel: () async {
                  if (activeRide != null) {
                    await rideProvider.cancelRide('User cancelled while searching');
                  }
                  _resetFlow();
                },
              ),
            ),

          // 7. Active Ride tracking details overlay
          if (activeRide != null && !isSearching)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ActiveRideSheet(
                ride: activeRide,
              ),
            ),
        ],
      ),
    );
  }
}
