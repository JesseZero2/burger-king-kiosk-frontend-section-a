import 'package:flutter/material.dart';
import '../widgets/bk_app_bar.dart';
import 'category_screen.dart';
import 'pickup_method_screen.dart';

class OrderTypeScreen extends StatelessWidget {
  const OrderTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isPhone = width < 700;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const BKAppBar(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 700),
              padding: EdgeInsets.all(isPhone ? 22 : 35),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: const Color(0xFFFFC72C),
                  width: 3,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'How would you like your order?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isPhone ? 26 : 34,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4A1600),
                    ),
                  ),
                  const SizedBox(height: 30),
                  isPhone
                      ? Column(
                          children: [
                            _OrderTypeButton(
                              title: 'TAKE OUT',
                              subtitle: 'Get your order to go',
                              icon: Icons.shopping_bag,
                              color: const Color(0xFFD62300),
                              isPhone: true,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const CategoryScreen(
                                      orderType: 'Take Out',
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 18),
                            _OrderTypeButton(
                              title: 'DINE IN',
                              subtitle: 'Enjoy your meal here',
                              icon: Icons.restaurant,
                              color: const Color(0xFF4A1600),
                              isPhone: true,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const PickupMethodScreen(
                                      orderType: 'Dine In',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: _OrderTypeButton(
                                title: 'TAKE OUT',
                                subtitle: 'Get your order to go',
                                icon: Icons.shopping_bag,
                                color: const Color(0xFFD62300),
                                isPhone: false,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const CategoryScreen(
                                        orderType: 'Take Out',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 25),
                            Expanded(
                              child: _OrderTypeButton(
                                title: 'DINE IN',
                                subtitle: 'Enjoy your meal here',
                                icon: Icons.restaurant,
                                color: const Color(0xFF4A1600),
                                isPhone: false,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const PickupMethodScreen(
                                        orderType: 'Dine In',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderTypeButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isPhone;

  const _OrderTypeButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.isPhone,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: isPhone ? 155 : 210,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: isPhone ? 50 : 70),
            SizedBox(height: isPhone ? 14 : 20),
            Text(
              title,
              style: TextStyle(
                fontSize: isPhone ? 22 : 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isPhone ? 13 : 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}