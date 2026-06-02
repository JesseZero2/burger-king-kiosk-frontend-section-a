import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final int? statusCode;
  final String message;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() {
    if (statusCode == null) return message;
    return 'HTTP $statusCode: $message';
  }
}

class CreatedOrder {
  final int? id;
  final String? queueNumber;
  final Map<String, dynamic> raw;

  CreatedOrder({
    required this.id,
    required this.queueNumber,
    required this.raw,
  });

  factory CreatedOrder.fromJson(Map<String, dynamic> json) {
    final data = _extractOrderMap(json);

    final idValue = data['id'] ?? data['order_id'] ?? data['orderId'];
    final queueValue = data['queue_number'] ??
        data['queueNumber'] ??
        data['queue_no'] ??
        data['queue'];

    return CreatedOrder(
      id: int.tryParse(idValue?.toString() ?? ''),
      queueNumber: queueValue?.toString(),
      raw: json,
    );
  }

  static Map<String, dynamic> _extractOrderMap(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is Map) return Map<String, dynamic>.from(data);

    final order = json['order'];
    if (order is Map) return Map<String, dynamic>.from(order);

    return json;
  }
}

class ApiService {
  static const String baseUrl =
      'https://burger-kiosk-api-production.up.railway.app';

  static const String _apiKey =
      'sb_publishable_vHfCgfAO2Kff2kDBqotgLg_nUUGRAlS';

  static const Map<String, String> authHeaders = {
    'apikey': _apiKey,
    'Authorization': 'Bearer $_apiKey',
  };

  static const Map<String, String> jsonHeaders = {
    ...authHeaders,
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Future<Map<String, dynamic>> createPayment(
    Map<String, dynamic> payload,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/payments'),
      headers: jsonHeaders,
      body: jsonEncode(payload),
    );

    final body = _decodeResponse(response);

    if (body is Map<String, dynamic>) return body;

    throw ApiException('Invalid payment response format.');
  }

  static Future<List<Map<String, dynamic>>> getMenuItems() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/menu-items'),
      headers: jsonHeaders,
    );

    final body = _decodeResponse(response);

    if (body is List) {
      return body
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    if (body is Map<String, dynamic> && body['data'] is List) {
      return (body['data'] as List)
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    return [];
  }

  static Future<Map<String, dynamic>> getMenuItem(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/menu-items/$id'),
      headers: jsonHeaders,
    );

    final body = _decodeResponse(response);

    if (body is Map<String, dynamic>) {
      if (body['data'] is Map) {
        return Map<String, dynamic>.from(body['data']);
      }
      return body;
    }

    throw ApiException('Invalid menu item response format.');
  }

  static Future<Map<String, dynamic>> getOrder(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/orders/$id'),
      headers: jsonHeaders,
    );

    final body = _decodeResponse(response);

    if (body is Map<String, dynamic>) return _normalizeOrder(body);

    throw ApiException('Invalid order response format.');
  }

  static Future<List<dynamic>> getOrders({
    String? status,
    DateTime? date,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/orders'),
      headers: jsonHeaders,
    );

    final body = _decodeResponse(response);
    List<dynamic> rawOrders = [];

    if (body is List) {
      rawOrders = body;
    } else if (body is Map<String, dynamic> && body['data'] is List) {
      rawOrders = body['data'] as List;
    }

    var orders = rawOrders
        .whereType<Map>()
        .map((order) => _normalizeOrder(Map<String, dynamic>.from(order)))
        .toList();

    if (status != null && status.isNotEmpty && status != 'all') {
      orders = orders.where((order) {
        return order['status']?.toString().toLowerCase() ==
            status.toLowerCase();
      }).toList();
    }

    if (date != null) {
      final selectedDate =
          '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      orders = orders.where((order) {
        final createdAt = order['created_at']?.toString() ?? '';
        return createdAt.startsWith(selectedDate);
      }).toList();
    }

    return orders;
  }

  static Future<Map<String, dynamic>> getDashboardSummary() async {
    final orders = await getOrders();
    final menuItems = await getMenuItems();

    double toDouble(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0.0;
    }

    final today = DateTime.now();
    final todayText =
        '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final ordersToday = orders.where((rawOrder) {
      final order = Map<String, dynamic>.from(rawOrder as Map);
      final createdAt = order['created_at']?.toString() ?? '';
      return createdAt.startsWith(todayText);
    }).toList();

    final revenueToday = ordersToday.fold<double>(0, (sum, rawOrder) {
      final order = Map<String, dynamic>.from(rawOrder as Map);
      return sum + toDouble(order['total']);
    });

    final activeItems = menuItems.where((item) {
      return item['available'] == true ||
          item['available'] == 1 ||
          item['is_available'] == true ||
          item['is_available'] == 1;
    }).length;

    final soldMap = <String, Map<String, dynamic>>{};

    for (final rawOrder in orders) {
      final order = Map<String, dynamic>.from(rawOrder as Map);
      final items = (order['items'] as List<dynamic>?) ?? [];

      for (final rawItem in items) {
        if (rawItem is! Map) continue;

        final item = Map<String, dynamic>.from(rawItem);
        final name = item['product_name']?.toString() ??
            item['name']?.toString() ??
            'Unknown Item';

        final quantity = int.tryParse(item['quantity']?.toString() ?? '') ?? 0;

        soldMap.putIfAbsent(name, () {
          return {
            'name': name,
            'category': 'Menu Item',
            'sold': 0,
          };
        });

        soldMap[name]!['sold'] = (soldMap[name]!['sold'] as int) + quantity;
      }
    }

    final topSelling = soldMap.values.toList()
      ..sort((a, b) => (b['sold'] as int).compareTo(a['sold'] as int));

    return {
      'orders_today': ordersToday.length,
      'revenue_today': revenueToday.toStringAsFixed(2),
      'active_menu_items': activeItems,
      'active_promotions': 0,
      'recent_orders': orders.take(5).toList(),
      'top_selling': topSelling.take(5).toList(),
    };
  }

  static Future<Map<String, dynamic>> getSettings() async {
    return {
      'store_name': 'Burger King Kiosk',
      'operating_hours': '9:00 AM - 9:00 PM',
      'tax_rate': 12,
      'payment_methods': ['cash', 'gcash', 'maya', 'card'],
    };
  }

  static Future<Map<String, dynamic>> updateSettings(
    Map<String, dynamic> payload,
  ) async {
    return {
      'success': true,
      'message': 'Settings saved locally for demo.',
      ...payload,
    };
  }

  static Future<CreatedOrder> createOrder(Map<String, dynamic> payload) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/orders'),
      headers: jsonHeaders,
      body: jsonEncode(payload),
    );

    final body = _decodeResponse(response);

    if (body is Map<String, dynamic>) return CreatedOrder.fromJson(body);

    throw ApiException('Invalid create order response format.');
  }

  static Future<Map<String, dynamic>> updateOrderStatus(
    int id,
    String status,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/orders/$id/status'),
      headers: jsonHeaders,
      body: jsonEncode({'status': status}),
    );

    final body = _decodeResponse(response);

    if (body is Map<String, dynamic>) return _normalizeOrder(body);

    throw ApiException('Invalid status update response format.');
  }

  static Map<String, dynamic> _normalizeOrder(Map<String, dynamic> order) {
    final normalized = Map<String, dynamic>.from(order);

    final items = normalized['items'];
    if (items is List) {
      normalized['items'] = items.map((rawItem) {
        if (rawItem is! Map) return rawItem;

        final item = Map<String, dynamic>.from(rawItem);
        item['name'] ??= item['product_name'] ?? 'Unknown Item';
        return item;
      }).toList();
    }

    return normalized;
  }

  static dynamic _decodeResponse(http.Response response) {
    dynamic body;

    try {
      body = response.body.isEmpty ? null : jsonDecode(response.body);
    } catch (_) {
      body = response.body;
    }

    final isSuccess = response.statusCode >= 200 && response.statusCode < 300;
    if (isSuccess) return body;

    String message = 'Request failed.';
    if (body is Map<String, dynamic>) {
      message = body['message']?.toString() ??
          body['error']?.toString() ??
          body.toString();
    } else if (body != null) {
      message = body.toString();
    }

    throw ApiException(message, statusCode: response.statusCode);
  }
}
