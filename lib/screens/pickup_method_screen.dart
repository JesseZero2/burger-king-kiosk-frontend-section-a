import 'package:flutter/material.dart';
import '../widgets/bk_app_bar.dart';
import 'category_screen.dart';

class PickupMethodScreen extends StatelessWidget {
  final String orderType;

  const PickupMethodScreen({
    super.key,
    required this.orderType,
  });

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
                    'How would you like to receive your order?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isPhone ? 25 : 34,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4A1600),
                    ),
                  ),
                  const SizedBox(height: 30),
                  _PickupButton(
                    title: 'PICK UP AT COUNTER',
                    icon: Icons.storefront,
                    color: const Color(0xFFD62300),
                    isPhone: isPhone,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CategoryScreen(
                            orderType: '$orderType - Pick Up At Counter',
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  _PickupButton(
                    title: 'DELIVER TO TABLE',
                    icon: Icons.table_restaurant,
                    color: const Color(0xFF4A1600),
                    isPhone: isPhone,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CategoryScreen(
                            orderType: '$orderType - Deliver To Table',
                          ),
                        ),
                      );
                    },
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

class _PickupButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final bool isPhone;
  final VoidCallback onTap;

  const _PickupButton({
    required this.title,
    required this.icon,
    required this.color,
    required this.isPhone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: isPhone ? 120 : 140,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: isPhone
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 42),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 60),
                  const SizedBox(width: 20),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}