import 'package:flutter/material.dart';

import '../../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final Future<Map<String, dynamic>> _summaryFuture = _fetchSummary();

  Future<Map<String, dynamic>> _fetchSummary() async {
    return ApiService.getDashboardSummary();
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(13, 0, 0, 0),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.black54)),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _summaryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final summary = snapshot.data ?? {};
        final ordersToday = summary['orders_today']?.toString() ?? '0';
        final revenueToday = summary['revenue_today']?.toString() ?? '0.00';
        final activeItems = summary['active_menu_items']?.toString() ?? '0';
        final activePromotions = summary['active_promotions']?.toString() ?? '0';
        final recentOrders = (summary['recent_orders'] as List<dynamic>?) ?? [];
        final topSelling = (summary['top_selling'] as List<dynamic>?) ?? [];

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Dashboard', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.2,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStatCard('Orders Today', ordersToday, const Color(0xFFD62300)),
                  _buildStatCard('Revenue Today', '₱$revenueToday', const Color(0xFFF5A623)),
                  _buildStatCard('Active Menu Items', activeItems, Colors.blueAccent),
                  _buildStatCard('Active Promotions', activePromotions, Colors.green),
                ],
              ),
              const SizedBox(height: 24),
              Text('Recent Orders', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Card(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Order #')),
                      DataColumn(label: Text('Customer')),
                      DataColumn(label: Text('Total')),
                      DataColumn(label: Text('Status')),
                    ],
                    rows: recentOrders.map((order) {
                      final item = order as Map<String, dynamic>;
                      return DataRow(cells: [
                        DataCell(Text('${item['order_number'] ?? item['id'] ?? '—'}')),
                        DataCell(Text('${item['customer_name'] ?? 'Guest'}')),
                        DataCell(Text('₱${item['total'] ?? '0.00'}')),
                        DataCell(Text('${item['status'] ?? '—'}')),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Top Selling Items', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Card(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Item')),
                      DataColumn(label: Text('Category')),
                      DataColumn(label: Text('Sold')),
                    ],
                    rows: topSelling.map((item) {
                      final row = item as Map<String, dynamic>;
                      return DataRow(cells: [
                        DataCell(Text('${row['name'] ?? '—'}')),
                        DataCell(Text('${row['category'] ?? '—'}')),
                        DataCell(Text('${row['sold'] ?? '0'}')),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
