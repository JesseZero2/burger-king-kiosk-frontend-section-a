import 'package:flutter/material.dart';
import '../widgets/bk_app_bar.dart';
import 'queue_screen.dart';

class SuccessScreen extends StatelessWidget {
  final String orderType;
  final String paymentMethod;

  const SuccessScreen({
    super.key,
    required this.orderType,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    final int orderNumber = DateTime.now().millisecondsSinceEpoch % 10000;
    final String queueNumber = 'BK-$orderNumber';

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
                const SizedBox(height: 15),
                const Text(
                  'Your order has been placed.',
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.black54,
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
                            queueNumber: queueNumber,
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