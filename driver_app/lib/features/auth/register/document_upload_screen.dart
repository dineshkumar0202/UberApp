import 'package:flutter/material.dart';
import 'package:ridoo_driver/features/auth/register/verification_status_screen.dart';

class DocumentUploadScreen extends StatefulWidget {
  final String vehicleType;
  final String model;
  final String plateNumber;
  final String color;

  const DocumentUploadScreen({
    super.key,
    required this.vehicleType,
    required this.model,
    required this.plateNumber,
    required this.color,
  });

  @override
  State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  final Map<String, String?> _uploadedDocs = {
    'license': null,
    'insurance': null,
    'id_card': null,
    'rc_book': null,
  };

  bool _isSubmitting = false;

  void _simulateUpload(String docKey) {
    setState(() {
      _uploadedDocs[docKey] = 'uploading';
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _uploadedDocs[docKey] = '${docKey}_document.pdf';
        });
      }
    });
  }

  bool get _isAllUploaded => _uploadedDocs.values.every((val) => val != null && val != 'uploading');

  Future<void> _submit() async {
    if (!_isAllUploaded) return;

    setState(() {
      _isSubmitting = true;
    });

    // Simulate calling the driver document submission endpoint
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const VerificationStatusScreen(),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Document Upload', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step Indicator Row
              Row(
                children: [
                  _buildStepBubble('1', 'Vehicle', true, isDone: true),
                  _buildStepLine(true),
                  _buildStepBubble('2', 'Documents', true),
                  _buildStepLine(false),
                  _buildStepBubble('3', 'Status', false),
                ],
              ),
              const SizedBox(height: 36),

              const Text(
                'Upload Documents',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5),
              ),
              const SizedBox(height: 8),
              Text(
                'Upload clear verification documents in PDF format.',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 28),

              // Upload list
              _buildUploadBox(
                'license',
                'Driver\'s License',
                'Upload your driver license front in PDF format.',
                Icons.picture_as_pdf_rounded,
              ),
              const SizedBox(height: 16),

              _buildUploadBox(
                'insurance',
                'Vehicle Insurance Policy',
                'Upload active policy coverage details in PDF format.',
                Icons.picture_as_pdf_rounded,
              ),
              const SizedBox(height: 16),

              _buildUploadBox(
                'id_card',
                'Aadhaar Card / ID Proof',
                'Upload national identity proof PDF.',
                Icons.picture_as_pdf_rounded,
              ),
              const SizedBox(height: 16),

              _buildUploadBox(
                'rc_book',
                'RC Book / Logbook',
                'Upload vehicle registration book in PDF format.',
                Icons.picture_as_pdf_rounded,
              ),
              const SizedBox(height: 40),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: (_isAllUploaded && !_isSubmitting) ? _submit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF7C815),
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: Colors.grey[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          _isAllUploaded ? 'Submit for Verification' : 'Upload All PDF Documents',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _isAllUploaded ? Colors.black : Colors.grey[400],
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepBubble(String number, String label, bool isActive, {bool isDone = false}) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isDone
                ? const Color(0xFF25A365)
                : (isActive ? Colors.black : Colors.grey[200]),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : Text(
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
            color: isDone
                ? const Color(0xFF25A365)
                : (isActive ? Colors.black : Colors.grey[500]),
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(bool isDone) {
    return Expanded(
      child: Container(
        height: 2,
        color: isDone ? const Color(0xFF25A365) : Colors.grey[200],
        margin: const EdgeInsets.only(bottom: 16),
      ),
    );
  }

  Widget _buildUploadBox(String docKey, String title, String subtitle, IconData icon) {
    final status = _uploadedDocs[docKey];
    final isUploading = status == 'uploading';
    final isUploaded = status != null && !isUploading;

    return GestureDetector(
      onTap: (isUploading || isUploaded) ? null : () => _simulateUpload(docKey),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUploaded
                ? const Color(0xFF25A365)
                : (isUploading ? Colors.black : Colors.grey[200]!),
            width: isUploaded || isUploading ? 2 : 1,
          ),
          color: isUploaded
              ? const Color(0xFF25A365).withOpacity(0.02)
              : (isUploading ? Colors.black.withOpacity(0.02) : Colors.grey[50]),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUploaded
                    ? const Color(0xFF25A365).withOpacity(0.1)
                    : Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isUploaded ? const Color(0xFF25A365) : Colors.grey[600],
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isUploaded ? '$status (Ready)' : subtitle,
                    style: TextStyle(
                      color: isUploaded ? const Color(0xFF25A365) : Colors.grey[500],
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (isUploading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
              )
            else if (isUploaded)
              const Icon(Icons.check_circle, color: Color(0xFF25A365), size: 24)
            else
              Icon(Icons.file_upload_outlined, color: Colors.grey[400], size: 24),
          ],
        ),
      ),
    );
  }
}
