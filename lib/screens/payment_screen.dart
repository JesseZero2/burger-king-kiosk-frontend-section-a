import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import '../widgets/bk_app_bar.dart';
import 'success_screen.dart';

class PaymentScreen extends StatefulWidget {
  final String orderType;

  const PaymentScreen({
    super.key,
    required this.orderType,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String selectedPayment = 'Cash';

  final List<Map<String, dynamic>> paymentMethods = [
    {
      'name': 'Cash',
      'icon': Icons.payments,
      'description': 'Pay at the counter',
    },
    {
      'name': 'Card',
      'icon': Icons.credit_card,
      'description': 'Credit or debit card',
    },
    {
      'name': 'GCash',
      'icon': Icons.phone_android,
      'description': 'Mobile wallet payment',
    },
    {
      'name': 'Maya',
      'icon': Icons.account_balance_wallet,
      'description': 'Digital wallet payment',
    },
  ];

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
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Payment Method',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A1600),
                          ),
                        ),
                        const SizedBox(height: 20),

                        Expanded(
                          child: GridView.builder(
                            itemCount: paymentMethods.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 18,
                              mainAxisSpacing: 18,
                              childAspectRatio: 1.25,
                            ),
                            itemBuilder: (context, index) {
                              final method = paymentMethods[index];
                              final isSelected =
                                  selectedPayment == method['name'];

                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    selectedPayment = method['name'];
                                  });
                                },
                                borderRadius: BorderRadius.circular(24),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFFD62300)
                                        : const Color(0xFFFFF3D6),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFFFFC72C)
                                          : const Color(0xFFD62300),
                                      width: 3,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        method['icon'],
                                        size: 58,
                                        color: isSelected
                                            ? Colors.white
                                            : const Color(0xFFD62300),
                                      ),
                                      const SizedBox(height: 14),
                                      Text(
                                        method['name'],
                                        style: TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? Colors.white
                                              : const Color(0xFF4A1600),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        method['description'],
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isSelected
                                              ? Colors.white70
                                              : Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 24),

                Expanded(
                  flex: 4,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.97),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Payment Summary',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A1600),
                          ),
                        ),
                        const SizedBox(height: 18),

                        Text(
                          'Order Type: ${widget.orderType}',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black54,
                          ),
                        ),

                        const SizedBox(height: 20),
                        const Divider(),

                        _SummaryRow(
                          label: 'Subtotal',
                          value:
                              '₱${CartService.subtotal.toStringAsFixed(0)}',
                        ),
                        const SizedBox(height: 10),
                        _SummaryRow(
                          label: 'Tax',
                          value: '₱${CartService.tax.toStringAsFixed(0)}',
                        ),
                        const SizedBox(height: 10),
                        _SummaryRow(
                          label: 'Total',
                          value: '₱${CartService.total.toStringAsFixed(0)}',
                          isTotal: true,
                        ),

                        const Spacer(),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3D6),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            'Selected: $selectedPayment',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4A1600),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        SizedBox(
                          width: double.infinity,
                          height: 70,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SuccessScreen(
                                    orderType: widget.orderType,
                                    paymentMethod: selectedPayment,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD62300),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                            ),
                            child: const Text(
                              'PLACE ORDER',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
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

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 24 : 19,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: const Color(0xFF4A1600),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 30 : 21,
            fontWeight: FontWeight.bold,
            color: isTotal
                ? const Color(0xFFD62300)
                : const Color(0xFF4A1600),
          ),
        ),
      ],
    );
  }
}