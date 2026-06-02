import 'dart:async';

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/cart_service.dart';
import '../widgets/bk_app_bar.dart';
import 'welcome_screen.dart';

class QueueScreen extends StatefulWidget {
  final String orderType;
  final String paymentMethod;
  final String queueNumber;
  final int? orderId;

  const QueueScreen({
    super.key,
    required this.orderType,
    required this.paymentMethod,
    required this.queueNumber,
    this.orderId,
  });

  @override
  State<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen> {
  Timer? _timer;
  String currentStatus = 'preparing';
  String? orderNumber;
  String? errorMessage;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchOrderStatus();

    if (widget.orderId != null) {
      _timer = Timer.periodic(
        const Duration(seconds: 5),
        (_) => fetchOrderStatus(),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Map<String, dynamic> _extractOrderMap(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is Map) return Map<String, dynamic>.from(data);

    final order = json['order'];
    if (order is Map) return Map<String, dynamic>.from(order);

    return json;
  }

  Future<void> fetchOrderStatus() async {
    if (widget.orderId == null) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await ApiService.getOrder(widget.orderId!);
      final order = _extractOrderMap(response);

      if (!mounted) return;

      setState(() {
        currentStatus = order['status']?.toString() ?? currentStatus;
        orderNumber = order['order_number']?.toString();
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = error.toString();
      });
    }
  }

  String get statusTitle {
    switch (currentStatus) {
      case 'pending':
        return 'Order received';
      case 'preparing':
        return 'Your order is being prepared';
      case 'ready':
        return 'Your order is ready for pickup';
      case 'completed':
        return 'Order completed';
      case 'cancelled':
        return 'Order cancelled';
      default:
        return 'Checking order status';
    }
  }

  Color get statusColor {
    switch (currentStatus) {
      case 'ready':
        return const Color(0xFF1B8F3A);
      case 'completed':
        return Colors.blueGrey;
      case 'cancelled':
        return Colors.red;
      case 'pending':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFFD62300);
    }
  }

  Color get statusBackgroundColor {
    switch (currentStatus) {
      case 'ready':
        return const Color(0xFFE7F8EC);
      case 'completed':
        return const Color(0xFFECEFF1);
      case 'cancelled':
        return const Color(0xFFFFEBEE);
      case 'pending':
        return const Color(0xFFFFF3E0);
      default:
        return const Color(0xFFFFF3D6);
    }
  }

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
              padding: const EdgeInsets.all(18),
              child: Container(
                width: 650,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.97),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: const Color(0xFFFFC72C),
                    width: 4,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'YOUR QUEUE NUMBER',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A1600),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 26),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD62300),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        widget.queueNumber,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 62,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      statusTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: statusBackgroundColor,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: statusColor, width: 2),
                      ),
                      child: Text(
                        currentStatus.toUpperCase(),
                        style: TextStyle(
                          fontSize: 17,
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    if (orderNumber != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Order Number: $orderNumber',
                        style: const TextStyle(fontSize: 17),
                      ),
                    ],
                    if (isLoading) ...[
                      const SizedBox(height: 10),
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Color(0xFFD62300),
                          strokeWidth: 3,
                        ),
                      ),
                    ],
                    if (errorMessage != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 13,
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    Text(
                      'Order Type: ${widget.orderType}',
                      style: const TextStyle(fontSize: 20),
                    ),
                    Text(
                      'Payment Method: ${widget.paymentMethod}',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Please wait for your number to be called.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 62,
                      child: ElevatedButton(
                        onPressed: () {
                          CartService.clearCart();

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const WelcomeScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD62300),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'NEW ORDER',
                          style: TextStyle(
                            fontSize: 22,
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
