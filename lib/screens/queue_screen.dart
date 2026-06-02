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
        return 'Your order is ready';
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
        return Colors.green;
      case 'completed':
        return Colors.blueGrey;
      case 'cancelled':
        return Colors.red;
      default:
        return const Color(0xFFD62300);
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
        child: Center(
          child: Container(
            width: 650,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.96),
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
                const SizedBox(height: 25),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD62300),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    widget.queueNumber,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  statusTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Status: ${currentStatus.toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF4A1600),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (orderNumber != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Order Number: $orderNumber',
                    style: const TextStyle(fontSize: 17),
                  ),
                ],
                if (isLoading) ...[
                  const SizedBox(height: 12),
                  const CircularProgressIndicator(
                    color: Color(0xFFD62300),
                  ),
                ],
                if (errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Text(
                  'Order Type: ${widget.orderType}',
                  style: const TextStyle(fontSize: 20),
                ),
                Text(
                  'Payment Method: ${widget.paymentMethod}',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Please wait for your number to be called.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 35),
                SizedBox(
                  width: double.infinity,
                  height: 65,
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
    );
  }
}
