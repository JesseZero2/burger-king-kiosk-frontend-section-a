import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/cart_service.dart';
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
  bool isSubmitting = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    Future.microtask(submitOrderAndPayment);
  }

  String get backendOrderType {
    final value = widget.orderType.toLowerCase();
    if (value.contains('take')) return 'take_out';
    return 'dine_in';
  }

  String get backendPaymentMethod {
    final value = widget.paymentMethod.toLowerCase();

    if (value.contains('gcash')) return 'gcash';
    if (value.contains('maya')) return 'maya';
    if (value.contains('card') || value.contains('credit')) return 'card';

    return 'cash';
  }

  Future<void> submitOrderAndPayment() async {
    setState(() {
      isSubmitting = true;
      errorMessage = null;
    });

    try {
      if (CartService.items.isEmpty) {
        throw ApiException('Cannot place order because cart is empty.');
      }

      final totalAmount = CartService.total;

      final orderPayload = {
        'order_type': backendOrderType,
        'items': CartService.items.map((item) {
          return {
            'product_id': item.product.id,
            'product_name': item.product.name,
            'quantity': item.quantity,
            'price': item.unitPrice,
          };
        }).toList(),
      };

      final createdOrder = await ApiService.createOrder(orderPayload);

      if (createdOrder.id == null) {
        throw ApiException('Order was created, but order ID was not returned.');
      }

      final paymentPayload = {
        'order_id': createdOrder.id,
        'payment_method': backendPaymentMethod,
        'amount': totalAmount,
      };

      await ApiService.createPayment(paymentPayload);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SuccessScreen(
            orderType: widget.orderType,
            paymentMethod: widget.paymentMethod,
            orderId: createdOrder.id,
            queueNumber: createdOrder.queueNumber,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isSubmitting = false;
        errorMessage = error.toString();
      });
    }
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
              Text(
                errorMessage == null ? 'PROCESSING PAYMENT' : 'ORDER FAILED',
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A1600),
                ),
              ),
              const SizedBox(height: 15),
              Text(
                errorMessage == null
                    ? 'Sending your order and payment to the kitchen system.'
                    : errorMessage!,
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
                      errorMessage == null ? Icons.payment : Icons.error,
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
              if (isSubmitting)
                const CircularProgressIndicator(
                  color: Color(0xFFD62300),
                  strokeWidth: 5,
                )
              else
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: submitOrderAndPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD62300),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'TRY AGAIN',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 25),
              Text(
                errorMessage == null
                    ? 'Please wait...'
                    : 'Please check backend/API.',
                style: const TextStyle(
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
