import 'package:flutter/material.dart';
import 'package:ridoo_driver/features/auth/register/document_upload_screen.dart';

class VehicleRegistrationScreen extends StatefulWidget {
  const VehicleRegistrationScreen({super.key});

  @override
  State<VehicleRegistrationScreen> createState() => _VehicleRegistrationScreenState();
}

class _VehicleRegistrationScreenState extends State<VehicleRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _plateController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();

  String _selectedVehicleType = 'economy'; // economy, comfort, premium, xl

  @override
  void dispose() {
    _modelController.dispose();
    _plateController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  void _proceed() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DocumentUploadScreen(
          vehicleType: _selectedVehicleType,
          model: _modelController.text.trim(),
          plateNumber: _plateController.text.trim(),
          color: _colorController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Vehicle Registration', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step Indicator Row
                Row(
                  children: [
                    _buildStepBubble('1', 'Vehicle', true),
                    _buildStepLine(false),
                    _buildStepBubble('2', 'Documents', false),
                    _buildStepLine(false),
                    _buildStepBubble('3', 'Status', false),
                  ],
                ),
                const SizedBox(height: 36),

                const Text(
                  'Your Vehicle Details',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  'Specify the vehicle you will be driving to transport passengers.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 28),

                // Vehicle Type Grid
                const Text(
                  'Select Vehicle Type',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildTypeCard('economy', 'Economy', Icons.directions_car_outlined)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTypeCard('comfort', 'Comfort', Icons.airline_seat_recline_extra_outlined)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildTypeCard('premium', 'Premium', Icons.star_outline_rounded)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTypeCard('xl', 'Ridoo XL', Icons.airport_shuttle_outlined)),
                  ],
                ),
                const SizedBox(height: 28),

                // Make/Model Input
                TextFormField(
                  controller: _modelController,
                  decoration: InputDecoration(
                    labelText: 'Vehicle Brand & Model',
                    hintText: 'e.g. Maruti Suzuki Swift / Toyota Camry',
                    prefixIcon: const Icon(Icons.drive_eta_outlined),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFF6C4DFF), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter vehicle make and model';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Plate Number Input
                TextFormField(
                  controller: _plateController,
                  decoration: InputDecoration(
                    labelText: 'License Plate Number',
                    hintText: 'e.g. MH-12-AB-1234',
                    prefixIcon: const Icon(Icons.numbers_outlined),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFF6C4DFF), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter license plate number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Color Input
                TextFormField(
                  controller: _colorController,
                  decoration: InputDecoration(
                    labelText: 'Vehicle Color',
                    hintText: 'e.g. White / Silver / Black',
                    prefixIcon: const Icon(Icons.color_lens_outlined),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFF6C4DFF), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter vehicle color';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _proceed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C4DFF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Continue to Document Upload',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepBubble(String number, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF6C4DFF) : Colors.grey[200],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? const Color(0xFF6C4DFF) : Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(bool isDone) {
    return Expanded(
      child: Container(
        height: 2,
        color: isDone ? const Color(0xFF6C4DFF) : Colors.grey[200],
        margin: const EdgeInsets.only(bottom: 16),
      ),
    );
  }

  Widget _buildTypeCard(String id, String label, IconData icon) {
    final isSelected = _selectedVehicleType == id;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedVehicleType = id;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF6C4DFF) : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? const Color(0xFF6C4DFF).withOpacity(0.05) : Colors.grey[50],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected ? const Color(0xFF6C4DFF) : Colors.grey[500],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? const Color(0xFF6C4DFF) : Colors.grey[700],
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
