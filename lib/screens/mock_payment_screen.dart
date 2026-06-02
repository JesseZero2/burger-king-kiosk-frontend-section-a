import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import '../widgets/bk_app_bar.dart';
import 'payment_processing_screen.dart';

class MockPaymentScreen extends StatefulWidget {
  final String orderType;
  final String paymentMethod;

  const MockPaymentScreen({
    super.key,
    required this.orderType,
    required this.paymentMethod,
  });

  @override
  State<MockPaymentScreen> createState() => _MockPaymentScreenState();
}

class _MockPaymentScreenState extends State<MockPaymentScreen> {
  bool isProcessing = false;

  bool get isCard => widget.paymentMethod == 'Card';

  void confirmMockPayment() async {
    setState(() => isProcessing = true);

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentProcessingScreen(
          orderType: widget.orderType,
          paymentMethod: widget.paymentMethod,
        ),
      ),
    );
  }

  IconData get paymentIcon {
    if (widget.paymentMethod == 'Card') return Icons.credit_card;
    if (widget.paymentMethod == 'Maya') return Icons.account_balance_wallet;
    return Icons.phone_android;
  }

  String get title => '${widget.paymentMethod} Payment';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BKAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/backgrounds/app_pattern.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                width: 760,
                padding: const EdgeInsets.all(34),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.98),
                  borderRadius: BorderRadius.circular(34),
                  border: Border.all(
                    color: const Color(0xFFFFC72C),
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF3D6),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        paymentIcon,
                        size: 56,
                        color: Color(0xFFD62300),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A1600),
                      ),
                    ),
                    const SizedBox(height: 28),
                    if (isCard) ...[
                      const _InputBox(
                        label: 'Cardholder Name',
                        hint: 'Juan Dela Cruz',
                        icon: Icons.person,
                      ),
                      const SizedBox(height: 14),
                      const _InputBox(
                        label: 'Card Number',
                        hint: '1234 5678 9012 3456',
                        icon: Icons.credit_card,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 14),
                      const Row(
                        children: [
                          Expanded(
                            child: _InputBox(
                              label: 'Expiry Date',
                              hint: 'MM/YY',
                              icon: Icons.calendar_month,
                              keyboardType: TextInputType.datetime,
                            ),
                          ),
                          SizedBox(width: 14),
                          Expanded(
                            child: _InputBox(
                              label: 'CVV',
                              hint: '123',
                              icon: Icons.lock,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      _InputBox(
                        label: '${widget.paymentMethod} Mobile Number',
                        hint: '09XX XXX XXXX',
                        icon: Icons.phone_android,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 14),
                      const _InputBox(
                        label: 'Verification Code',
                        hint: 'Enter 6-digit code',
                        icon: Icons.verified_user,
                        keyboardType: TextInputType.number,
                      ),
                    ],
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3D6),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Amount to Pay',
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4A1600),
                            ),
                          ),
                          Text(
                            '₱${CartService.total.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD62300),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    SizedBox(
                      width: double.infinity,
                      height: 72,
                      child: ElevatedButton(
                        onPressed: isProcessing ? null : confirmMockPayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD62300),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        child: Text(
                          isProcessing ? 'PROCESSING...' : 'PAY NOW',
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InputBox extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;

  const _InputBox({
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFFD62300)),
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFFFF8E8),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}
