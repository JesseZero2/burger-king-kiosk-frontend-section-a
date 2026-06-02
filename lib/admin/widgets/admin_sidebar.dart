import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({
    super.key,
    this.collapsed = false,
  });

  /// Optional support for collapsed sidebar layouts.
  /// Existing usage like const AdminSidebar() will still work.
  final bool collapsed;

  static const _bkRed = Color(0xFFD62300);
  static const _bkOrange = Color(0xFFFF8732);
  static const _bkYellow = Color(0xFFFFC72C);
  static const _bkCream = Color(0xFFFFF3D6);
  static const _bkBrown = Color(0xFF4A1600);
  static const _bkDarkBrown = Color(0xFF2B0D00);
  static const _bkCardBrown = Color(0xFF5A1F0C);

  /// Uses your local Burger King logo from assets.zip.
  /// Make sure pubspec.yaml includes either:
  /// assets/logo/app_icon.png
  /// or the whole assets folder: assets/
  static const _logoAsset = 'assets/logo/app_icon.png';

  List<_AdminNavItem> get _items => const [
        _AdminNavItem(
          label: 'Dashboard',
          subtitle: 'Overview',
          icon: Icons.dashboard_rounded,
          path: '/admin',
        ),
        _AdminNavItem(
          label: 'Menu',
          subtitle: 'Food items',
          icon: Icons.restaurant_menu_rounded,
          path: '/admin/menu',
        ),
        _AdminNavItem(
          label: 'Orders',
          subtitle: 'Kitchen queue',
          icon: Icons.receipt_long_rounded,
          path: '/admin/orders',
        ),
        _AdminNavItem(
          label: 'Settings',
          subtitle: 'Local setup',
          icon: Icons.settings_rounded,
          path: '/admin/settings',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).location;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCollapsed = collapsed || constraints.maxWidth < 130;

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _bkDarkBrown,
                _bkBrown,
                Color(0xFF371000),
              ],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _SidebarHeader(isCollapsed: isCollapsed),
                const SizedBox(height: 18),
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(
                      horizontal: isCollapsed ? 10 : 16,
                    ),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      final active = _isActiveRoute(location, item.path);

                      return _SidebarTile(
                        item: item,
                        active: active,
                        isCollapsed: isCollapsed,
                        onTap: () {
                          if (!active) context.go(item.path);
                        },
                      );
                    },
                  ),
                ),
                _SidebarFooter(isCollapsed: isCollapsed),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _isActiveRoute(String location, String path) {
    // Dashboard must only be active on /admin.
    // Without this special case, /admin/orders also starts with /admin/,
    // so Dashboard and Orders both look selected. Ang kulit, so fixed na.
    if (path == '/admin') {
      return location == '/admin';
    }

    return location == path || location.startsWith('$path/');
  }
}

class _SidebarHeader extends StatelessWidget {
  const _SidebarHeader({required this.isCollapsed});

  final bool isCollapsed;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(
        isCollapsed ? 10 : 16,
        18,
        isCollapsed ? 10 : 16,
        0,
      ),
      padding: EdgeInsets.all(isCollapsed ? 10 : 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AdminSidebar._bkRed,
            AdminSidebar._bkOrange,
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AdminSidebar._bkRed.withValues(alpha: 0.30),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: isCollapsed ? const _LogoBadge(size: 54) : const _ExpandedHeader(),
    );
  }
}

class _ExpandedHeader extends StatelessWidget {
  const _ExpandedHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const _LogoBadge(size: 64),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _AutoFitHeaderText(
                    text: 'Burger King',
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                  SizedBox(height: 7),
                  _AutoFitHeaderText(
                    text: 'Admin Control Panel',
                    fontSize: 12.5,
                    color: AdminSidebar._bkCream,
                    fontWeight: FontWeight.w800,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.local_fire_department_rounded,
                color: AdminSidebar._bkYellow,
                size: 21,
              ),
              SizedBox(width: 8),
              Expanded(
                child: _AutoFitHeaderText(
                  text: 'Flame-grilled operations',
                  fontSize: 12.5,
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AutoFitHeaderText extends StatelessWidget {
  const _AutoFitHeaderText({
    required this.text,
    required this.fontSize,
    required this.color,
    required this.fontWeight,
  });

  final String text;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        maxLines: 1,
        softWrap: false,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          height: 1,
          fontWeight: fontWeight,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}

class _LogoBadge extends StatelessWidget {
  const _LogoBadge({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.08),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(
          color: AdminSidebar._bkCream.withValues(alpha: 0.95),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.22),
        child: Image.asset(
          AdminSidebar._logoAsset,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AdminSidebar._bkCream,
              borderRadius: BorderRadius.circular(size * 0.22),
            ),
            child: const Text(
              'BK',
              style: TextStyle(
                color: AdminSidebar._bkRed,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  const _SidebarTile({
    required this.item,
    required this.active,
    required this.isCollapsed,
    required this.onTap,
  });

  final _AdminNavItem item;
  final bool active;
  final bool isCollapsed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: isCollapsed ? item.label : '',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: EdgeInsets.symmetric(
              horizontal: isCollapsed ? 0 : 15,
              vertical: isCollapsed ? 13 : 14,
            ),
            decoration: BoxDecoration(
              color: active
                  ? AdminSidebar._bkCream
                  : AdminSidebar._bkCardBrown.withValues(alpha: 0.68),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: active
                    ? AdminSidebar._bkYellow.withValues(alpha: 0.98)
                    : Colors.white.withValues(alpha: 0.08),
                width: active ? 1.4 : 1,
              ),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment:
                  isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: active
                        ? AdminSidebar._bkRed
                        : AdminSidebar._bkYellow.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    item.icon,
                    color: active ? Colors.white : AdminSidebar._bkYellow,
                    size: 24,
                  ),
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: active ? AdminSidebar._bkRed : Colors.white,
                            fontSize: 16,
                            height: 1,
                            fontWeight: active ? FontWeight.w900 : FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          item.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: active
                                ? AdminSidebar._bkBrown.withValues(alpha: 0.78)
                                : AdminSidebar._bkCream.withValues(alpha: 0.78),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 180),
                    opacity: active ? 1 : 0.45,
                    child: Icon(
                      active
                          ? Icons.radio_button_checked_rounded
                          : Icons.chevron_right_rounded,
                      color: active ? AdminSidebar._bkRed : AdminSidebar._bkCream,
                      size: active ? 18 : 22,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarFooter extends StatelessWidget {
  const _SidebarFooter({required this.isCollapsed});

  final bool isCollapsed;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      margin: EdgeInsets.fromLTRB(
        isCollapsed ? 10 : 16,
        10,
        isCollapsed ? 10 : 16,
        18,
      ),
      padding: EdgeInsets.all(isCollapsed ? 10 : 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.075),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: isCollapsed
          ? const Icon(
              Icons.verified_user_rounded,
              color: AdminSidebar._bkYellow,
              size: 25,
            )
          : Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AdminSidebar._bkYellow.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.verified_user_rounded,
                    color: AdminSidebar._bkYellow,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 11),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Access',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Secure kiosk manager',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AdminSidebar._bkCream,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
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

class _AdminNavItem {
  final String label;
  final String subtitle;
  final IconData icon;
  final String path;

  const _AdminNavItem({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.path,
  });
}
