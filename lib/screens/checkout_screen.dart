import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import '../widgets/bk_app_bar.dart';
import 'payment_processing_screen.dart';
import 'mock_payment_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final String orderType;

  const CheckoutScreen({
    super.key,
    required this.orderType,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String selectedPayment = 'Cash';

  final List<String> paymentMethods = [
    'Cash',
    'Card',
    'GCash',
    'Maya',
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isPhone = width < 700;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const BKAppBar(),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isPhone ? 14 : 24),
          child: isPhone
              ? SingleChildScrollView(
                  child: Column(
                    children: [
                      _OrderSummaryCard(orderType: widget.orderType),
                      const SizedBox(height: 16),
                      _PaymentMethodCard(
                        paymentMethods: paymentMethods,
                        selectedPayment: selectedPayment,
                        onSelect: (method) {
                          setState(() {
                            selectedPayment = method;
                          });
                        },
                        orderType: widget.orderType,
                      ),
                    ],
                  ),
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: SingleChildScrollView(
                        child: _OrderSummaryCard(
                          orderType: widget.orderType,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 1,
                      child: SingleChildScrollView(
                        child: _PaymentMethodCard(
                          paymentMethods: paymentMethods,
                          selectedPayment: selectedPayment,
                          onSelect: (method) {
                            setState(() {
                              selectedPayment = method;
                            });
                          },
                          orderType: widget.orderType,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  final String orderType;

  const _OrderSummaryCard({
    required this.orderType,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isPhone = width < 700;

    return Container(
      padding: EdgeInsets.all(isPhone ? 18 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFFFC72C),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: TextStyle(
              fontSize: isPhone ? 26 : 32,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF4A1600),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Order Type: $orderType',
            style: TextStyle(
              fontSize: isPhone ? 16 : 20,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: isPhone ? 260 : 250,
            child: ListView.builder(
              itemCount: CartService.items.length,
              itemBuilder: (context, index) {
                final item = CartService.items[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3D6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        item.product.image,
                        width: isPhone ? 50 : 60,
                        height: isPhone ? 50 : 60,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.fastfood,
                            color: Color(0xFFD62300),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.product.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: isPhone ? 15 : 17,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF4A1600),
                              ),
                            ),
                            Text(
                              '₱${item.unitPrice.toStringAsFixed(0)} x ${item.quantity}',
                              style: TextStyle(
                                fontSize: isPhone ? 13 : 14,
                                color: Colors.black54,
                              ),
                            ),
                            if (item.addons.isNotEmpty)
                              Text(
                                '+ ${item.addons.join(', ')}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFD62300),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '₱${item.totalPrice.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: isPhone ? 15 : 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFD62300),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const Divider(height: 28),
          _SummaryText(
            label: 'Subtotal',
            value: '₱${CartService.subtotal.toStringAsFixed(0)}',
          ),
          _SummaryText(
            label: 'Tax',
            value: '₱${CartService.tax.toStringAsFixed(0)}',
          ),
          _SummaryText(
            label: 'Total',
            value: '₱${CartService.total.toStringAsFixed(0)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final List<String> paymentMethods;
  final String selectedPayment;
  final ValueChanged<String> onSelect;
  final String orderType;

  const _PaymentMethodCard({
    required this.paymentMethods,
    required this.selectedPayment,
    required this.onSelect,
    required this.orderType,
  });

  IconData getPaymentIcon(String method) {
    if (method == 'Cash') return Icons.payments;
    if (method == 'Card') return Icons.credit_card;
    if (method == 'GCash') return Icons.phone_android;
    if (method == 'Maya') return Icons.account_balance_wallet;
    return Icons.payment;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isPhone = width < 700;

    return Container(
      padding: EdgeInsets.all(isPhone ? 18 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFFFC72C),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: TextStyle(
              fontSize: isPhone ? 25 : 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF4A1600),
            ),
          ),
          const SizedBox(height: 18),
          ...paymentMethods.map((method) {
            final isSelected = selectedPayment == method;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SizedBox(
                width: double.infinity,
                height: isPhone ? 58 : 60,
                child: ElevatedButton(
                  onPressed: () {
                    onSelect(method);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected
                        ? const Color(0xFFD62300)
                        : const Color(0xFFFFC72C),
                    foregroundColor:
                        isSelected ? Colors.white : const Color(0xFF4A1600),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(getPaymentIcon(method), size: 24),
                      const SizedBox(width: 10),
                      Text(
                        method,
                        style: TextStyle(
                          fontSize: isPhone ? 18 : 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          SizedBox(height: isPhone ? 14 : 24),
          SizedBox(
            width: double.infinity,
            height: isPhone ? 62 : 70,
            child: ElevatedButton(
              onPressed: () {
                final screen = selectedPayment == 'Cash'
                    ? PaymentProcessingScreen(
                        orderType: orderType,
                        paymentMethod: selectedPayment,
                      )
                    : MockPaymentScreen(
                        orderType: orderType,
                        paymentMethod: selectedPayment,
                      );

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => screen),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD62300),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                'PLACE ORDER',
                style: TextStyle(
                  fontSize: isPhone ? 20 : 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryText extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _SummaryText({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontSize: isTotal ? 24 : 18,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: const Color(0xFF4A1600),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 28 : 19,
              fontWeight: FontWeight.bold,
              color:
                  isTotal ? const Color(0xFFD62300) : const Color(0xFF4A1600),
            ),
          ),
        ],
      ),
    );
  }
}
