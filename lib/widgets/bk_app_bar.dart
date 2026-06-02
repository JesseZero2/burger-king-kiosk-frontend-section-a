import 'package:flutter/material.dart';

class BKAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final VoidCallback? onCartPressed;
  final int cartCount;

  const BKAppBar({
    super.key,
    this.onCartPressed,
    this.cartCount = 0,
  });

  @override
  Size get preferredSize => const Size.fromHeight(95);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF4A1600),
      elevation: 2,

      toolbarHeight: 95,

      centerTitle: false,
      titleSpacing: 0,

      title: SizedBox(
        width: 500,
        child: Image.asset(
          'assets/ui/appbar_banner.png',
          fit: BoxFit.contain,
        ),
      ),

      actions: [
        if (onCartPressed != null)
          Padding(
            padding: const EdgeInsets.only(
              right: 16,
            ),
            child: IconButton(
              onPressed: onCartPressed,
              icon: Stack(
                children: [
                  const Icon(
                    Icons.shopping_cart,
                    size: 34,
                    color: Color(0xFFD62300),
                  ),

                  if (cartCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFC72C),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            cartCount.toString(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4A1600),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}