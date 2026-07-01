import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridoo_customer/data/providers/wallet_provider.dart';

class PaymentSheet extends StatefulWidget {
  final double amount;

  const PaymentSheet({super.key, required this.amount});

  @override
  State<PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<PaymentSheet> {
  String _selectedGateway = 'stripe'; // stripe or razorpay
  final _cardFormKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _processPayment() async {
    if (_selectedGateway == 'stripe') {
      if (!_cardFormKey.currentState!.validate()) return;
    }

    setState(() {
      _isProcessing = true;
    });

    final provider = Provider.of<WalletProvider>(context, listen: false);
    bool success = false;

    // Simulate network latency for payment gateway feel
    await Future.delayed(const Duration(seconds: 1));

    if (_selectedGateway == 'stripe') {
      success = await provider.topUpWithStripe(
        amount: widget.amount,
        cardNumber: _cardNumberController.text,
        expiry: _expiryController.text,
        cvv: _cvvController.text,
      );
    } else {
      success = await provider.topUpWithRazorpay(amount: widget.amount);
    }

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });

      if (success) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Payment failed'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Select Payment Method',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: _isProcessing ? null : () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Gateways selection
          Row(
            children: [
              Expanded(
                child: _buildGatewayOption(
                  id: 'stripe',
                  label: 'Stripe',
                  subLabel: 'Cards / Google Pay',
                  icon: Icons.credit_card_rounded,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildGatewayOption(
                  id: 'razorpay',
                  label: 'Razorpay',
                  subLabel: 'UPI / NetBanking',
                  icon: Icons.account_balance_wallet_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (_selectedGateway == 'stripe') ...[
            Form(
              key: _cardFormKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _cardNumberController,
                    decoration: InputDecoration(
                      labelText: 'Card Number',
                      hintText: '4242 4242 4242 4242',
                      prefixIcon: const Icon(Icons.payment),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (val) => val == null || val.length < 16
                        ? 'Invalid card number'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _expiryController,
                          decoration: InputDecoration(
                            labelText: 'Expiry Date',
                            hintText: 'MM/YY',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: TextInputType.datetime,
                          validator: (val) => val == null || !val.contains('/')
                              ? 'Required'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _cvvController,
                          decoration: InputDecoration(
                            labelText: 'CVV',
                            hintText: '123',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          validator: (val) =>
                              val == null || val.length < 3 ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.flash_on, color: Colors.amber),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Razorpay secure redirect top-up. Instantly load money using any UPI App or net banking credential.',
                      style: TextStyle(fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _processPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isProcessing
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      'Confirm Payment of ₹${widget.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
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

  Widget _buildGatewayOption({
    required String id,
    required String label,
    required String subLabel,
    required IconData icon,
  }) {
    final isSelected = _selectedGateway == id;
    return GestureDetector(
      onTap: () {
        if (!_isProcessing) {
          setState(() {
            _selectedGateway = id;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? Colors.grey[50] : Colors.white,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected ? Colors.black : Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.black : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subLabel,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? Colors.black54 : Colors.grey[400],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
