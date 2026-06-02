import 'package:flutter/material.dart';

import '../../services/api_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  static const _bkRed = Color(0xFFD62300);
  static const _bkBrown = Color(0xFF3A1607);
  static const _bkCream = Color(0xFFFFF1CC);
  static const _pageBg = Color(0xFFF8F5F0);

  final _statusOptions = const [
    'all',
    'pending',
    'preparing',
    'ready',
    'completed',
  ];

  String _selectedStatus = 'all';
  DateTime? _selectedDate;
  late Future<List<dynamic>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _loadOrders();
  }

  Future<List<dynamic>> _loadOrders() {
    return ApiService.getOrders(status: _selectedStatus, date: _selectedDate);
  }

  void _refresh() {
    if (!mounted) return;

    setState(() {
      _ordersFuture = _loadOrders();
    });
  }

  Future<void> _updateStatus(int orderId, String status) async {
    try {
      await ApiService.updateOrderStatus(orderId, status);

      if (!mounted) return;

      setState(() {
        _ordersFuture = _loadOrders();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order status changed to ${status.capitalize()}')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update order: $error')),
      );
    }
  }

  void _showDetails(Map<String, dynamic> order) {
    final items = _items(order);
    final orderId = _orderId(order);
    final status = _text(order['status'], fallback: 'unknown');

    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: _bkRed,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.receipt_long,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order ${_orderNumber(order)}',
                            style: const TextStyle(
                              color: _bkBrown,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${items.length} item${items.length == 1 ? '' : 's'} • ${_dateText(order)}',
                            style: TextStyle(
                              color: _bkBrown.withAlpha(160),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _StatusPill(status: status, color: _statusColor(status)),
                  ],
                ),
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: _bkCream.withAlpha(190),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFFFD77A)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _DetailMetric(
                          label: 'Total Amount',
                          value: _peso(order['total']),
                          icon: Icons.payments,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _DetailMetric(
                          label: 'Payment',
                          value: _text(order['payment_method'], fallback: 'N/A').capitalize(),
                          icon: Icons.credit_card,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _DetailMetric(
                          label: 'Order Type',
                          value: _text(order['order_type'], fallback: 'Kiosk').capitalize(),
                          icon: Icons.storefront,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Items',
                  style: TextStyle(
                    color: _bkBrown,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: items.isEmpty
                          ? [
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Text('No item details available.'),
                              ),
                            ]
                          : items.map((item) => _ItemRow(item: item)).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _bkBrown,
                          side: BorderSide(color: _bkBrown.withAlpha(70)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text('Close'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (orderId != null)
                      PopupMenuButton<String>
                        (
                        onSelected: (value) {
                          Navigator.of(context).pop();
                          _updateStatus(orderId, value);
                        },
                        itemBuilder: (context) => _statusOptions
                            .where((value) => value != 'all')
                            .map(
                              (value) => PopupMenuItem(
                                value: value,
                                child: Text(value.capitalize()),
                              ),
                            )
                            .toList(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: _bkRed,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.sync, color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Change Status',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _pageBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(onRefresh: _refresh),
          const SizedBox(height: 18),
          _FilterBar(
            statusOptions: _statusOptions,
            selectedStatus: _selectedStatus,
            selectedDate: _selectedDate,
            onStatusChanged: (value) {
              setState(() {
                _selectedStatus = value;
                _ordersFuture = _loadOrders();
              });
            },
            onDatePicked: (value) {
              setState(() {
                _selectedDate = value;
                _ordersFuture = _loadOrders();
              });
            },
            onClearDate: () {
              setState(() {
                _selectedDate = null;
                _ordersFuture = _loadOrders();
              });
            },
          ),
          const SizedBox(height: 18),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _ordersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(
                    child: CircularProgressIndicator(color: _bkRed),
                  );
                }

                if (snapshot.hasError) {
                  return _ErrorState(
                    message: 'Error: ${snapshot.error}',
                    onRetry: _refresh,
                  );
                }

                final orders = snapshot.data ?? [];
                final mappedOrders = orders
                    .whereType<Map>()
                    .map((order) => Map<String, dynamic>.from(order))
                    .toList();

                return Column(
                  children: [
                    _StatsRow(orders: mappedOrders),
                    const SizedBox(height: 18),
                    Expanded(
                      child: mappedOrders.isEmpty
                          ? const _EmptyState()
                          : ListView.separated(
                              padding: const EdgeInsets.only(bottom: 24),
                              itemCount: mappedOrders.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final order = mappedOrders[index];
                                return _OrderCard(
                                  order: order,
                                  statusColor: _statusColor(
                                    _text(order['status'], fallback: ''),
                                  ),
                                  onTap: () => _showDetails(order),
                                  onStatusSelected: (status) {
                                    final id = _orderId(order);
                                    if (id == null) return;
                                    _updateStatus(id, status);
                                  },
                                  statusOptions: _statusOptions,
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static int? _orderId(Map<String, dynamic> order) {
    final value = order['id'];
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  static String _orderNumber(Map<String, dynamic> order) {
    final orderNumber = order['order_number'];
    if (orderNumber != null && orderNumber.toString().trim().isNotEmpty) {
      return orderNumber.toString();
    }
    return '#${order['id'] ?? '----'}';
  }

  static List<Map<String, dynamic>> _items(Map<String, dynamic> order) {
    final rawItems = order['items'];
    if (rawItems is! List) return [];
    return rawItems
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  static String _text(dynamic value, {String fallback = ''}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  static String _peso(dynamic value) {
    if (value == null) return '₱0.00';
    final number = value is num ? value.toDouble() : double.tryParse(value.toString());
    if (number == null) return '₱$value';
    return '₱${number.toStringAsFixed(2)}';
  }

  static double _totalValue(Map<String, dynamic> order) {
    final value = order['total'];
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _dateText(Map<String, dynamic> order) {
    final value = order['created_at'] ?? order['updated_at'] ?? order['date'];
    if (value == null) return 'Today';
    final parsed = DateTime.tryParse(value.toString());
    if (parsed == null) return value.toString();
    final month = parsed.month.toString().padLeft(2, '0');
    final day = parsed.day.toString().padLeft(2, '0');
    final year = parsed.year.toString();
    return '$year-$month-$day';
  }

  static Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFF8A00);
      case 'preparing':
        return const Color(0xFF1976D2);
      case 'ready':
        return const Color(0xFF00897B);
      case 'completed':
        return const Color(0xFF1B8F3A);
      default:
        return Colors.grey;
    }
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onRefresh;

  const _Header({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD62300), Color(0xFFFF8732)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD62300).withAlpha(45),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(235),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.receipt_long, color: Color(0xFFD62300), size: 32),
          ),
          const SizedBox(width: 18),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Orders Queue',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Track kiosk orders, kitchen progress, and completion status.',
                  style: TextStyle(
                    color: Color(0xFFFFF1CC),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFFD62300),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final List<String> statusOptions;
  final String selectedStatus;
  final DateTime? selectedDate;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<DateTime> onDatePicked;
  final VoidCallback onClearDate;

  const _FilterBar({
    required this.statusOptions,
    required this.selectedStatus,
    required this.selectedDate,
    required this.onStatusChanged,
    required this.onDatePicked,
    required this.onClearDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFE2B8)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: statusOptions.map((status) {
                final selected = status == selectedStatus;
                return ChoiceChip(
                  selected: selected,
                  label: Text(status.capitalize()),
                  selectedColor: const Color(0xFFD62300),
                  backgroundColor: const Color(0xFFFFF1CC),
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : const Color(0xFF3A1607),
                    fontWeight: FontWeight.w900,
                  ),
                  side: BorderSide(
                    color: selected
                        ? const Color(0xFFD62300)
                        : const Color(0xFFFFD77A),
                  ),
                  onSelected: (_) => onStatusChanged(status),
                );
              }).toList(),
            ),
          ),
          const SizedBox(width: 14),
          OutlinedButton.icon(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) onDatePicked(picked);
            },
            icon: const Icon(Icons.calendar_month),
            label: Text(selectedDate == null ? 'Select Date' : _dateLabel(selectedDate!)),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF3A1607),
              side: const BorderSide(color: Color(0xFFFF8732)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          if (selectedDate != null) ...[
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Clear date',
              onPressed: onClearDate,
              icon: const Icon(Icons.close, color: Color(0xFFD62300)),
            ),
          ],
        ],
      ),
    );
  }

  String _dateLabel(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}

class _StatsRow extends StatelessWidget {
  final List<Map<String, dynamic>> orders;

  const _StatsRow({required this.orders});

  @override
  Widget build(BuildContext context) {
    final totalSales = orders.fold<double>(
      0,
      (sum, order) => sum + _OrdersScreenState._totalValue(order),
    );

    final cards = [
      _StatCard(
        title: 'Total Orders',
        value: orders.length.toString(),
        icon: Icons.shopping_bag,
        accent: const Color(0xFFD62300),
      ),
      _StatCard(
        title: 'Preparing',
        value: _countStatus('preparing').toString(),
        icon: Icons.local_fire_department,
        accent: const Color(0xFF1976D2),
      ),
      _StatCard(
        title: 'Ready',
        value: _countStatus('ready').toString(),
        icon: Icons.room_service,
        accent: const Color(0xFF00897B),
      ),
      _StatCard(
        title: 'Sales Total',
        value: '₱${totalSales.toStringAsFixed(2)}',
        icon: Icons.payments,
        accent: const Color(0xFFFF8A00),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 900;
        if (isCompact) {
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: cards
                .map((card) => SizedBox(
                      width: (constraints.maxWidth - 12) / 2,
                      child: card,
                    ))
                .toList(),
          );
        }

        return Row(
          children: cards
              .map(
                (card) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: card,
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  int _countStatus(String status) {
    return orders
        .where(
          (order) => _OrdersScreenState
              ._text(order['status'])
              .toLowerCase() == status.toLowerCase(),
        )
        .length;
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color accent;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFE2B8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accent.withAlpha(28),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF7A4D32),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF3A1607),
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
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

class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final Color statusColor;
  final VoidCallback onTap;
  final ValueChanged<String> onStatusSelected;
  final List<String> statusOptions;

  const _OrderCard({
    required this.order,
    required this.statusColor,
    required this.onTap,
    required this.onStatusSelected,
    required this.statusOptions,
  });

  @override
  Widget build(BuildContext context) {
    final items = _OrdersScreenState._items(order);
    final status = _OrdersScreenState._text(order['status'], fallback: 'unknown');

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFFFE2B8), width: 1.3),
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFD62300),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.fastfood, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 18),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order ${_OrdersScreenState._orderNumber(order)}',
                      style: const TextStyle(
                        color: Color(0xFF3A1607),
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${items.length} item${items.length == 1 ? '' : 's'} • ${_OrdersScreenState._dateText(order)}',
                      style: const TextStyle(
                        color: Color(0xFF7A4D32),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  _OrdersScreenState._peso(order['total']),
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Color(0xFF3A1607),
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 18),
              _StatusPill(status: status, color: statusColor),
              const SizedBox(width: 10),
              PopupMenuButton<String>(
                tooltip: 'Change status',
                onSelected: onStatusSelected,
                itemBuilder: (context) => statusOptions
                    .where((value) => value != 'all')
                    .map(
                      (value) => PopupMenuItem(
                        value: value,
                        child: Text(value.capitalize()),
                      ),
                    )
                    .toList(),
                icon: const Icon(Icons.more_vert, color: Color(0xFF3A1607)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;
  final Color color;

  const _StatusPill({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: color.withAlpha(28),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: color.withAlpha(70)),
      ),
      child: Text(
        status.capitalize(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _DetailMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DetailMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFD62300).withAlpha(25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFFD62300), size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF7A4D32),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF3A1607),
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

class _ItemRow extends StatelessWidget {
  final Map<String, dynamic> item;

  const _ItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final name = _OrdersScreenState._text(
      item['name'] ?? item['menu_item_name'] ?? item['product_name'],
      fallback: 'Menu item',
    );
    final quantity = _OrdersScreenState._text(item['quantity'], fallback: '1');
    final price = item['price'] ?? item['subtotal'] ?? item['total'];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE2B8)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1CC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.lunch_dining, color: Color(0xFFD62300), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: Color(0xFF3A1607),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            'x$quantity',
            style: const TextStyle(
              color: Color(0xFF7A4D32),
              fontWeight: FontWeight.w900,
            ),
          ),
          if (price != null) ...[
            const SizedBox(width: 18),
            Text(
              _OrdersScreenState._peso(price),
              style: const TextStyle(
                color: Color(0xFF3A1607),
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(34),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFFFE2B8)),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long, size: 54, color: Color(0xFFD62300)),
            SizedBox(height: 12),
            Text(
              'No orders found.',
              style: TextStyle(
                color: Color(0xFF3A1607),
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Try changing the status or date filter.',
              style: TextStyle(color: Color(0xFF7A4D32)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFFFC5B8)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFD62300), size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
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

extension on String {
  String capitalize() => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
