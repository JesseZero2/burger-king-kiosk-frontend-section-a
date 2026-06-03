import 'package:flutter/material.dart';

import '../../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<Map<String, dynamic>> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _summaryFuture = ApiService.getDashboardSummary();
  }

  void _refreshDashboard() {
    setState(() {
      _summaryFuture = ApiService.getDashboardSummary();
    });
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'ready':
        return const Color(0xFF1B8F3A);
      case 'completed':
        return const Color(0xFF455A64);
      case 'cancelled':
        return const Color(0xFFC62828);
      case 'pending':
        return const Color(0xFFFF9800);
      case 'preparing':
        return const Color(0xFFD62300);
      default:
        return const Color(0xFF7A2E12);
    }
  }

  String _money(dynamic value) {
    final amount = double.tryParse(value?.toString() ?? '0') ?? 0;
    return '₱${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _summaryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFD62300)),
          );
        }

        if (snapshot.hasError) {
          return _DashboardError(
            message: snapshot.error.toString(),
            onRetry: _refreshDashboard,
          );
        }

        final summary = snapshot.data ?? {};
        final recentOrders = (summary['recent_orders'] as List<dynamic>?) ?? [];
        final topSelling = (summary['top_selling'] as List<dynamic>?) ?? [];

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DashboardHero(onRefresh: _refreshDashboard),
              const SizedBox(height: 22),
              _StatGrid(
                stats: [
                  _StatData(
                    title: 'Orders Today',
                    value: '${summary['orders_today'] ?? 0}',
                    icon: Icons.receipt_long_rounded,
                    color: const Color(0xFFD62300),
                    note: 'Live kiosk orders',
                  ),
                  _StatData(
                    title: 'Revenue Today',
                    value: _money(summary['revenue_today']),
                    icon: Icons.payments_rounded,
                    color: const Color(0xFFF5A623),
                    note: 'Paid transactions',
                  ),
                  _StatData(
                    title: 'Active Menu Items',
                    value: '${summary['active_menu_items'] ?? 0}',
                    icon: Icons.restaurant_menu_rounded,
                    color: const Color(0xFF1976D2),
                    note: 'Available products',
                  ),
                  _StatData(
                    title: 'Active Promotions',
                    value: '${summary['active_promotions'] ?? 0}',
                    icon: Icons.local_offer_rounded,
                    color: const Color(0xFF1B8F3A),
                    note: 'Current promos',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _DashboardContentGrid(
                recentOrders: recentOrders,
                topSelling: topSelling,
                money: _money,
                statusColor: _statusColor,
              ),
            ],
          ),
        );
      },
    );
  }
}

Map<String, dynamic> _safeMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return {};
}

String _valueOf(
  Map<String, dynamic> data,
  List<String> keys, {
  String fallback = '—',
}) {
  for (final key in keys) {
    final value = data[key];
    final text = value?.toString().trim() ?? '';

    if (text.isNotEmpty && text.toLowerCase() != 'null') {
      return text;
    }
  }

  return fallback;
}

int _intOf(Map<String, dynamic> data, List<String> keys) {
  for (final key in keys) {
    final value = int.tryParse(data[key]?.toString() ?? '');

    if (value != null) return value;
  }

  return 0;
}

class _DashboardHero extends StatelessWidget {
  final VoidCallback onRefresh;

  const _DashboardHero({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF4A1600),
            Color(0xFFD62300),
            Color(0xFFFF8A00),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD62300).withValues(alpha: 0.25),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 760;

          final titleBlock = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
                ),
                child: const Text(
                  'ADMIN CONTROL PANEL',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Burger King Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Monitor today’s orders, sales, menu activity, and best sellers in one wider workspace.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.86),
                  fontSize: 16,
                  height: 1.35,
                ),
              ),
            ],
          );

          final actionBlock = Column(
            crossAxisAlignment:
                isCompact ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                ),
                child: const Icon(
                  Icons.lunch_dining_rounded,
                  color: Colors.white,
                  size: 42,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Refresh Dashboard'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFD62300),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 16,
                  ),
                  elevation: 0,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ],
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                titleBlock,
                const SizedBox(height: 22),
                actionBlock,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: titleBlock),
              const SizedBox(width: 32),
              actionBlock,
            ],
          );
        },
      ),
    );
  }
}

class _StatData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String note;

  const _StatData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.note,
  });
}

class _StatGrid extends StatelessWidget {
  final List<_StatData> stats;

  const _StatGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width >= 1120
            ? 4
            : width >= 680
                ? 2
                : 1;

        return GridView.builder(
          shrinkWrap: true,
          itemCount: stats.length,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 18,
            mainAxisSpacing: 18,
            mainAxisExtent: 148,
          ),
          itemBuilder: (context, index) {
            return _StatCard(data: stats[index]);
          },
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final _StatData data;

  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFFFD89A)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(21),
            ),
            child: Icon(data.icon, color: data.color, size: 34),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7A5C4A),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: data.color,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.note,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black45,
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

class _DashboardContentGrid extends StatelessWidget {
  final List<dynamic> recentOrders;
  final List<dynamic> topSelling;
  final String Function(dynamic value) money;
  final Color Function(String status) statusColor;

  const _DashboardContentGrid({
    required this.recentOrders,
    required this.topSelling,
    required this.money,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1080;

        if (!isWide) {
          return Column(
            children: [
              _RecentOrdersCard(
                orders: recentOrders,
                money: money,
                statusColor: statusColor,
              ),
              const SizedBox(height: 22),
              _TopSellingCard(items: topSelling),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: _RecentOrdersCard(
                orders: recentOrders,
                money: money,
                statusColor: statusColor,
              ),
            ),
            const SizedBox(width: 22),
            Expanded(
              flex: 5,
              child: _TopSellingCard(items: topSelling),
            ),
          ],
        );
      },
    );
  }
}

class _RecentOrdersCard extends StatelessWidget {
  final List<dynamic> orders;
  final String Function(dynamic value) money;
  final Color Function(String status) statusColor;

  const _RecentOrdersCard({
    required this.orders,
    required this.money,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    final visibleOrders = orders.take(7).map(_safeMap).toList();

    return _SectionCard(
      title: 'Recent Orders',
      subtitle: 'Latest kiosk transactions',
      icon: Icons.receipt_long_rounded,
      minHeight: 470,
      child: visibleOrders.isEmpty
          ? const _EmptyMessage(message: 'No recent orders found.')
          : Column(
              children: [
                ...visibleOrders.map((order) {
                  final orderNumber = _valueOf(
                    order,
                    ['order_number', 'queue_number', 'id'],
                  );
                  final customer = _valueOf(
                    order,
                    ['customer_name', 'customer', 'name'],
                    fallback: 'Guest',
                  );
                  final status = _valueOf(order, ['status'], fallback: 'pending');
                  final total = order['total'] ??
                      order['total_amount'] ??
                      order['grand_total'] ??
                      order['amount'];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _OrderTile(
                      orderNumber: orderNumber,
                      customer: customer,
                      total: money(total),
                      status: status,
                      color: statusColor(status),
                    ),
                  );
                }),
              ],
            ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  final String orderNumber;
  final String customer;
  final String total;
  final String status;
  final Color color;

  const _OrderTile({
    required this.orderNumber,
    required this.customer,
    required this.total,
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8EC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFE0A8)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 560;

          final orderInfo = Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFD62300).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.shopping_bag_rounded,
                  color: Color(0xFFD62300),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #$orderNumber',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF4A1600),
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      customer,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

          final orderMeta = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                total,
                style: const TextStyle(
                  color: Color(0xFF4A1600),
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 12),
              _StatusBadge(label: status, color: color),
            ],
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                orderInfo,
                const SizedBox(height: 14),
                orderMeta,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: orderInfo),
              const SizedBox(width: 16),
              orderMeta,
            ],
          );
        },
      ),
    );
  }
}

class _TopSellingCard extends StatelessWidget {
  final List<dynamic> items;

  const _TopSellingCard({required this.items});

  @override
  Widget build(BuildContext context) {
    final parsedItems = items.take(7).map(_safeMap).toList();
    final maxSold = parsedItems.fold<int>(1, (highest, item) {
      final sold = _intOf(
        item,
        ['sold', 'quantity_sold', 'total_sold', 'orders_count', 'count'],
      );
      return sold > highest ? sold : highest;
    });

    return _SectionCard(
      title: 'Top Selling Items',
      subtitle: 'Best performers today',
      icon: Icons.local_fire_department_rounded,
      minHeight: 470,
      child: parsedItems.isEmpty
          ? const _EmptyMessage(message: 'No top selling items yet.')
          : Column(
              children: List.generate(parsedItems.length, (index) {
                final item = parsedItems[index];
                final name = _valueOf(
                  item,
                  ['name', 'item_name', 'menu_item_name', 'product_name'],
                );
                final category = _valueOf(
                  item,
                  ['category', 'category_name', 'type'],
                  fallback: 'Menu item',
                );
                final sold = _intOf(
                  item,
                  ['sold', 'quantity_sold', 'total_sold', 'orders_count', 'count'],
                );

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _TopSellingTile(
                    rank: index + 1,
                    name: name,
                    category: category,
                    sold: sold,
                    maxSold: maxSold,
                  ),
                );
              }),
            ),
    );
  }
}

class _TopSellingTile extends StatelessWidget {
  final int rank;
  final String name;
  final String category;
  final int sold;
  final int maxSold;

  const _TopSellingTile({
    required this.rank,
    required this.name,
    required this.category,
    required this.sold,
    required this.maxSold,
  });

  @override
  Widget build(BuildContext context) {
    final widthFactor = (sold / maxSold).clamp(0.08, 1.0).toDouble();

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: rank == 1 ? const Color(0xFFFFF3D6) : const Color(0xFFFFF8EC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFE0A8)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: rank == 1
                  ? const Color(0xFFD62300)
                  : const Color(0xFFD62300).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              '$rank',
              style: TextStyle(
                color: rank == 1 ? Colors.white : const Color(0xFFD62300),
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF4A1600),
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: Stack(
                    children: [
                      Container(
                        height: 7,
                        color: const Color(0xFFFFE0A8),
                      ),
                      FractionallySizedBox(
                        widthFactor: widthFactor,
                        child: Container(
                          height: 7,
                          color: const Color(0xFFD62300),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$sold',
                style: const TextStyle(
                  color: Color(0xFFD62300),
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
              const Text(
                'sold',
                style: TextStyle(color: Colors.black45, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;
  final double minHeight;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
    required this.minHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: minHeight),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFFFD89A)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFD62300).withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: const Color(0xFFD62300), size: 27),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF4A1600),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black45,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 11,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _EmptyMessage extends StatelessWidget {
  final String message;

  const _EmptyMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 275,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8EC),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFE0A8)),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.black54,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DashboardError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _DashboardError({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: const Color(0xFFFFD89A)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFD62300),
              size: 44,
            ),
            const SizedBox(height: 14),
            const Text(
              'Dashboard failed to load',
              style: TextStyle(
                color: Color(0xFF4A1600),
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD62300),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
