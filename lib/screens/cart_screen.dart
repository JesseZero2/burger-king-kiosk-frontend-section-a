import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import '../widgets/bk_app_bar.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  final String orderType;

  const CartScreen({
    super.key,
    required this.orderType,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isPhone = width < 700;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const BKAppBar(),
      body: SafeArea(
        child: CartService.items.isEmpty
            ? const Center(
                child: Text(
                  'Cart is Empty',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A1600),
                  ),
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.all(isPhone ? 10 : 14),
                      itemCount: CartService.items.length,
                      itemBuilder: (context, index) {
                        final item = CartService.items[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(isPhone ? 12 : 16),
                            child: isPhone
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Image.asset(
                                            item.product.image,
                                            width: 75,
                                            height: 75,
                                            fit: BoxFit.contain,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item.product.name,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    color: Color(0xFF4A1600),
                                                  ),
                                                ),
                                                Text(
                                                  '₱${item.unitPrice.toStringAsFixed(0)} each',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                                if (item.addons.isNotEmpty)
                                                  Text(
                                                    '+ ${item.addons.join(', ')}',
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Color(0xFFD62300),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    CartService
                                                        .decreaseQuantity(
                                                      item.product,
                                                    );
                                                  });
                                                },
                                                icon: const Icon(
                                                  Icons.remove_circle,
                                                ),
                                                color: const Color(0xFFD62300),
                                                iconSize: 34,
                                              ),
                                              Text(
                                                item.quantity.toString(),
                                                style: const TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    CartService
                                                        .increaseQuantity(
                                                      item.product,
                                                    );
                                                  });
                                                },
                                                icon: const Icon(
                                                  Icons.add_circle,
                                                ),
                                                color: const Color(0xFFD62300),
                                                iconSize: 34,
                                              ),
                                            ],
                                          ),
                                          Text(
                                            '₱${item.totalPrice.toStringAsFixed(0)}',
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFD62300),
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                CartService.removeFromCart(
                                                  item.product,
                                                );
                                              });
                                            },
                                            icon: const Icon(Icons.delete),
                                            color: Colors.black54,
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                : Row(
                                    children: [
                                      Image.asset(
                                        item.product.image,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.contain,
                                      ),
                                      const SizedBox(width: 15),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.product.name,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF4A1600),
                                              ),
                                            ),
                                            Text(
                                              '₱${item.unitPrice.toStringAsFixed(0)} each',
                                              style: const TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                            if (item.addons.isNotEmpty)
                                              Text(
                                                '+ ${item.addons.join(', ')}',
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Color(0xFFD62300),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            CartService.decreaseQuantity(
                                              item.product,
                                            );
                                          });
                                        },
                                        icon: const Icon(Icons.remove_circle),
                                        color: const Color(0xFFD62300),
                                        iconSize: 36,
                                      ),
                                      Text(
                                        item.quantity.toString(),
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            CartService.increaseQuantity(
                                              item.product,
                                            );
                                          });
                                        },
                                        icon: const Icon(Icons.add_circle),
                                        color: const Color(0xFFD62300),
                                        iconSize: 36,
                                      ),
                                      const SizedBox(width: 20),
                                      Text(
                                        '₱${item.totalPrice.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFD62300),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            CartService.removeFromCart(
                                              item.product,
                                            );
                                          });
                                        },
                                        icon: const Icon(Icons.delete),
                                        color: Colors.black54,
                                      ),
                                    ],
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(isPhone ? 16 : 22),
                    color: Colors.white,
                    child: Column(
                      children: [
                        _CartSummaryRow(
                          label: 'Subtotal',
                          value:
                              '₱${CartService.subtotal.toStringAsFixed(0)}',
                          isPhone: isPhone,
                        ),
                        _CartSummaryRow(
                          label: 'Tax',
                          value: '₱${CartService.tax.toStringAsFixed(0)}',
                          isPhone: isPhone,
                        ),
                        _CartSummaryRow(
                          label: 'Total',
                          value: '₱${CartService.total.toStringAsFixed(0)}',
                          isPhone: isPhone,
                          isTotal: true,
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: isPhone ? 58 : 65,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CheckoutScreen(
                                    orderType: widget.orderType,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD62300),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              'CHECKOUT',
                              style: TextStyle(
                                fontSize: isPhone ? 20 : 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _CartSummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isPhone;
  final bool isTotal;

  const _CartSummaryRow({
    required this.label,
    required this.value,
    required this.isPhone,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontSize: isTotal
                  ? isPhone
                      ? 23
                      : 30
                  : isPhone
                      ? 17
                      : 20,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: const Color(0xFF4A1600),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal
                  ? isPhone
                      ? 25
                      : 30
                  : isPhone
                      ? 17
                      : 20,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color:
                  isTotal ? const Color(0xFFD62300) : const Color(0xFF4A1600),
            ),
          ),
        ],
      ),
    );
  }
}