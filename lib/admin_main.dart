import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'admin/admin_shell.dart';
import 'admin/screens/dashboard_screen.dart';
import 'admin/screens/menu_list_screen.dart';
import 'admin/screens/add_edit_menu_item_screen.dart';
import 'admin/screens/orders_screen.dart';
import 'admin/screens/settings_screen.dart';
import 'features/menu/menu_item_model.dart';

void main() {
  runApp(const BurgerKingAdminApp());
}

class BurgerKingAdminApp extends StatelessWidget {
  const BurgerKingAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/admin',
      routes: [
        GoRoute(
          path: '/',
          redirect: (_, __) => '/admin',
        ),
        ShellRoute(
          builder: (context, state, child) => AdminShell(child: child),
          routes: [
            GoRoute(
              path: '/admin',
              builder: (context, state) => const DashboardScreen(),
            ),
            GoRoute(
              path: '/admin/menu',
              builder: (context, state) => const MenuListScreen(),
            ),
            GoRoute(
              path: '/admin/menu/add',
              builder: (context, state) => const AddEditMenuItemScreen(),
            ),
            GoRoute(
              path: '/admin/menu/edit/:id',
              builder: (context, state) {
                final item = state.extra as MenuItemModel?;
                return AddEditMenuItemScreen(menuItem: item);
              },
            ),
            GoRoute(
              path: '/admin/orders',
              builder: (context, state) => const OrdersScreen(),
            ),
            GoRoute(
              path: '/admin/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      title: 'Burger King Admin',
      theme: ThemeData(
        primaryColor: const Color(0xFFD62300),
        scaffoldBackgroundColor: const Color(0xFFF6F4F1),
      ),
    );
  }
}
