import 'package:flutter/material.dart';
import 'widgets/admin_sidebar.dart';

class AdminShell extends StatelessWidget {
  final Widget child;

  const AdminShell({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7E8),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(
            width: 250,
            child: AdminSidebar(),
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 82,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Burger King Admin Console',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4A1600),
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Manage menu items, orders, dashboard, and settings',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3D6),
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: const Color(0xFFFFC72C),
                            width: 2,
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.admin_panel_settings,
                              color: Color(0xFFD62300),
                              size: 22,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'ADMIN MODE',
                              style: TextStyle(
                                color: Color(0xFF4A1600),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF7E8),
                    ),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
