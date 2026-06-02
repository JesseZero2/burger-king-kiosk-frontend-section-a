import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({super.key});

  List<_AdminNavItem> get _items => const [
        _AdminNavItem(label: 'Dashboard', icon: Icons.dashboard, path: '/admin'),
        _AdminNavItem(label: 'Menu', icon: Icons.restaurant_menu, path: '/admin/menu'),
        _AdminNavItem(label: 'Orders', icon: Icons.receipt_long, path: '/admin/orders'),
        _AdminNavItem(label: 'Settings', icon: Icons.settings, path: '/admin/settings'),
      ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).location;

    return Container(
      color: const Color(0xFFFFFFFF),
      child: Column(
        children: [
          Container(
            height: 100,
            color: const Color(0xFFD62300),
            alignment: Alignment.center,
            child: const Text(
              'Burger King Admin',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: _items.map((item) {
                final active = location == item.path || location.startsWith('${item.path}/');
                return ListTile(
                  leading: Icon(item.icon, color: active ? const Color(0xFFD62300) : Colors.black54),
                  title: Text(
                    item.label,
                    style: TextStyle(
                      color: active ? const Color(0xFFD62300) : Colors.black87,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  tileColor: active ? const Color.fromARGB(31, 245, 166, 35) : null,
                  hoverColor: const Color.fromARGB(46, 245, 166, 35),
                  onTap: () => context.go(item.path),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminNavItem {
  final String label;
  final IconData icon;
  final String path;
  const _AdminNavItem({required this.label, required this.icon, required this.path});
}
