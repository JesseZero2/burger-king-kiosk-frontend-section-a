import 'package:flutter/material.dart';
import '../widgets/bk_app_bar.dart';
import 'queue_screen.dart';

class SuccessScreen extends StatelessWidget {
  final String orderType;
  final String paymentMethod;
  final int? orderId;
  final String? orderNumber;
  final String? queueNumber;

  const SuccessScreen({
    super.key,
    required this.orderType,
    required this.paymentMethod,
    this.orderId,
    this.orderNumber,
    this.queueNumber,
  });

  String get displayQueueNumber {
    if (queueNumber != null && queueNumber!.isNotEmpty) {
      return queueNumber!;
    }

    if (orderId != null) {
      return orderId.toString();
    }

    return '0000';
  }

  String get displayOrderNumber {
    if (orderNumber != null && orderNumber!.isNotEmpty) {
      return orderNumber!;
    }

    if (orderId != null) {
      return 'BK-$orderId';
    }

    return 'BK-0000';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BKAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/backgrounds/success_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Container(
            width: 620,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 110,
                  color: Color(0xFFD62300),
                ),
                const SizedBox(height: 20),
                const Text(
                  'ORDER SUCCESSFUL',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A1600),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'QUEUE NUMBER',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A1600),
                  ),
                ),
                Text(
                  displayQueueNumber,
                  style: const TextStyle(
                    fontSize: 70,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD62300),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Order Number: $displayOrderNumber',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black54,
                  ),
                ),
                if (orderId != null)
                  Text(
                    'Backend ID: $orderId',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black38,
                    ),
                  ),
                const SizedBox(height: 35),
                SizedBox(
                  width: double.infinity,
                  height: 65,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QueueScreen(
                            orderType: orderType,
                            paymentMethod: paymentMethod,
                            queueNumber: displayQueueNumber,
                            orderId: orderId,
                          ),
                        ),
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
                      'VIEW QUEUE NUMBER',
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
