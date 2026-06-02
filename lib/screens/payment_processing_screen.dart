import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/bk_app_bar.dart';
import 'success_screen.dart';

class PaymentProcessingScreen extends StatefulWidget {
  final String orderType;
  final String paymentMethod;

  const PaymentProcessingScreen({
    super.key,
    required this.orderType,
    required this.paymentMethod,
  });

  @override
  State<PaymentProcessingScreen> createState() =>
      _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState extends State<PaymentProcessingScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SuccessScreen(
            orderType: widget.orderType,
            paymentMethod: widget.paymentMethod,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BKAppBar(),
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: const Color(0xFFFFC72C),
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'PROCESSING PAYMENT',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A1600),
                ),
              ),

              const SizedBox(height: 15),

              Text(
                widget.paymentMethod == 'Cash'
                    ? 'Please pay at the counter.'
                    : 'Please tap, insert, or scan your payment.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 35),

              Container(
                width: 260,
                height: 190,
                decoration: BoxDecoration(
                  color: const Color(0xFF4A1600),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.paymentMethod == 'Cash'
                          ? Icons.payments
                          : Icons.credit_card,
                      size: 85,
                      color: const Color(0xFFFFC72C),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      widget.paymentMethod,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              const CircularProgressIndicator(
                color: Color(0xFFD62300),
                strokeWidth: 5,
              ),

              const SizedBox(height: 25),

              const Text(
                'Please wait...',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD62300),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}