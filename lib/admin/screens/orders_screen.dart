import 'package:flutter/material.dart';

import '../../services/api_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _statusOptions = const ['all', 'pending', 'preparing', 'ready', 'completed'];
  String _selectedStatus = 'all';
  DateTime? _selectedDate;
  late Future<List<dynamic>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _loadOrders();
  }

  Future<List<dynamic>> _loadOrders() async {
    return ApiService.getOrders(status: _selectedStatus, date: _selectedDate);
  }

  void _refresh() {
    setState(() => _ordersFuture = _loadOrders());
  }

  Future<void> _updateStatus(int orderId, String status) async {
    await ApiService.updateOrderStatus(orderId, status);
    _refresh();
  }

  void _showDetails(Map<String, dynamic> order) {
    final items = (order['items'] as List<dynamic>?) ?? [];
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order ${order['order_number'] ?? order['id']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total: ₱${order['total'] ?? '0.00'}'),
            const SizedBox(height: 8),
            Text('Status: ${order['status'] ?? 'unknown'}'),
            const SizedBox(height: 12),
            const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...items.map((item) {
              final row = item as Map<String, dynamic>;
              return Text('- ${row['name'] ?? ''} x${row['quantity'] ?? 1}');
            }),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              final navigator = Navigator.of(context);
              await _updateStatus(order['id'] as int, value);
              if (mounted) navigator.pop();
            },
            itemBuilder: (context) => _statusOptions
                .where((status) => status != 'all')
                .map((status) => PopupMenuItem(value: status, child: Text(status.capitalize())))
                .toList(),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text('Change Status'),
            ),
          ),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Orders', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _selectedStatus,
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Status'),
                items: _statusOptions.map((status) => DropdownMenuItem(value: status, child: Text(status.capitalize()))).toList(),
                onChanged: (value) {
                  _selectedStatus = value ?? 'all';
                  _refresh();
                },
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? DateTime.now(),
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  _selectedDate = picked;
                  _refresh();
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD62300)),
              child: Text(_selectedDate == null ? 'Select Date' : _selectedDate!.toIso8601String().split('T').first),
            ),
            const SizedBox(width: 12),
            IconButton(onPressed: () {
              _selectedDate = null;
              _refresh();
            }, icon: const Icon(Icons.clear, color: Colors.black54)),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: FutureBuilder<List<dynamic>>(
            future: _ordersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final orders = snapshot.data ?? [];
              if (orders.isEmpty) {
                return const Center(child: Text('No orders found.'));
              }
              return ListView.separated(
                itemCount: orders.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final order = orders[index] as Map<String, dynamic>;
                  return Card(
                    child: ListTile(
                      onTap: () => _showDetails(order),
                      title: Text('Order ${order['order_number'] ?? order['id']}'),
                      subtitle: Text('${order['items']?.length ?? 0} items · ₱${order['total'] ?? '0.00'}'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _statusColor('${order['status'] ?? ''}').withAlpha(41),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('${order['status'] ?? 'unknown'}', style: TextStyle(color: _statusColor('${order['status'] ?? ''}'))),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'preparing':
        return Colors.blue;
      case 'ready':
        return Colors.teal;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

extension on String {
  String capitalize() => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
