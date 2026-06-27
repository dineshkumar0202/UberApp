import 'package:flutter/material.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _withdrawFormKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _upiController = TextEditingController();
  final TextEditingController _bankAccountController = TextEditingController();
  final TextEditingController _bankIfscController = TextEditingController();

  double _balance = 12450.00;
  String _selectedPayoutMethod = 'upi'; // upi or bank
  bool _isProcessing = false;

  final List<Map<String, dynamic>> _transactions = [
    {'type': 'trip', 'desc': 'Trip RIDO-103 Fare Credit', 'amount': 450.00, 'date': '2026-06-27 12:30'},
    {'type': 'trip', 'desc': 'Trip RIDO-102 Fare Credit', 'amount': 380.00, 'date': '2026-06-27 10:15'},
    {'type': 'bonus', 'desc': 'Weekend Active Incentive', 'amount': 500.00, 'date': '2026-06-26 18:00'},
    {'type': 'payout', 'desc': 'Payout to Bank Account', 'amount': -5000.00, 'date': '2026-06-25 09:00'},
    {'type': 'trip', 'desc': 'Trip RIDO-101 Fare Credit', 'amount': 410.00, 'date': '2026-06-25 08:30'},
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _upiController.dispose();
    _bankAccountController.dispose();
    _bankIfscController.dispose();
    super.dispose();
  }

  void _triggerWithdrawal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Form(
            key: _withdrawFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Withdraw Earnings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 16),

                // Method toggle
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('UPI Payout')),
                        selected: _selectedPayoutMethod == 'upi',
                        onSelected: (val) {
                          setModalState(() {
                            _selectedPayoutMethod = 'upi';
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Bank Transfer')),
                        selected: _selectedPayoutMethod == 'bank',
                        onSelected: (val) {
                          setModalState(() {
                            _selectedPayoutMethod = 'bank';
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Amount
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Amount (₹)',
                    hintText: 'Enter amount to withdraw',
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                  validator: (val) {
                    final amount = double.tryParse(val ?? '');
                    if (amount == null || amount <= 0) return 'Enter a valid amount';
                    if (amount > _balance) return 'Insufficient balance';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                if (_selectedPayoutMethod == 'upi') ...[
                  TextFormField(
                    controller: _upiController,
                    decoration: InputDecoration(
                      labelText: 'UPI ID',
                      hintText: 'driver@upi',
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Enter UPI ID' : null,
                  ),
                ] else ...[
                  TextFormField(
                    controller: _bankAccountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Bank Account Number',
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Enter account number' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _bankIfscController,
                    decoration: InputDecoration(
                      labelText: 'IFSC Code',
                      hintText: 'SBIN0001234',
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Enter IFSC Code' : null,
                  ),
                ],
                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isProcessing
                        ? null
                        : () async {
                            if (!_withdrawFormKey.currentState!.validate()) return;
                            Navigator.pop(context);
                            _executeWithdrawal();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C4DFF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Withdraw Payout', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _executeWithdrawal() async {
    setState(() {
      _isProcessing = true;
    });

    final amount = double.parse(_amountController.text);

    // Simulate payment payout processing latency
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isProcessing = false;
        _balance -= amount;
        _transactions.insert(0, {
          'type': 'payout',
          'desc': _selectedPayoutMethod == 'upi'
              ? 'Payout to ${_upiController.text}'
              : 'Payout to Bank A/c ${_bankAccountController.text.substring(_bankAccountController.text.length - 4)}',
          'amount': -amount,
          'date': DateTime.now().toString().substring(0, 16),
        });
      });

      _amountController.clear();
      _upiController.clear();
      _bankAccountController.clear();
      _bankIfscController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payout of ₹${amount.toStringAsFixed(2)} processed successfully!'),
          backgroundColor: const Color(0xFF25A365),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Earnings Wallet', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C4DFF), Color(0xFF8E77FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF6C4DFF).withOpacity(0.25), blurRadius: 15, offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TOTAL EARNINGS',
                        style: TextStyle(color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.5),
                      ),
                      const Icon(Icons.account_balance_wallet, color: Colors.white),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${_balance.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton.icon(
                    onPressed: _triggerWithdrawal,
                    icon: const Icon(Icons.outbox_rounded, size: 18),
                    label: const Text('Withdraw Money'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF6C4DFF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),

            const Text('Earnings History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _transactions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final tx = _transactions[index];
                final isCredit = tx['amount'] > 0;
                final amt = tx['amount'] as double;

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: isCredit ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                        child: Icon(
                          isCredit ? Icons.arrow_upward : Icons.arrow_downward,
                          color: isCredit ? Colors.green : Colors.red,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tx['desc'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 2),
                            Text(tx['date'], style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                          ],
                        ),
                      ),
                      Text(
                        '${isCredit ? "+" : ""} ₹${amt.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isCredit ? Colors.green : Colors.red,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
