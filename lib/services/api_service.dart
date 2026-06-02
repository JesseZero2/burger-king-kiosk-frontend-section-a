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
    if (data is Map<String, dynamic>) return data;

    final order = json['order'];
    if (order is Map<String, dynamic>) return order;

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
    if (body is Map<String, dynamic>) return body;
    throw ApiException('Invalid order response format.');
  }

  static Future<List<dynamic>> getOrders({String? status, DateTime? date}) async {
    final query = <String>[];
    if (status != null && status.isNotEmpty && status != 'all') {
      query.add('status=$status');
    }
    if (date != null) {
      query.add('date=${date.toIso8601String().split('T').first}');
    }
    final uri = Uri.parse('$baseUrl/api/orders${query.isEmpty ? '' : '?${query.join('&')}'}');
    final response = await http.get(uri, headers: jsonHeaders);

    final body = _decodeResponse(response);
    if (body is List) return body;
    if (body is Map<String, dynamic> && body['data'] is List) {
      return body['data'] as List;
    }
    return [];
  }

  static Future<Map<String, dynamic>> getDashboardSummary() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/dashboard/summary'),
      headers: jsonHeaders,
    );

    final body = _decodeResponse(response);
    if (body is Map<String, dynamic>) return body;
    throw ApiException('Invalid dashboard summary response format.');
  }

  static Future<Map<String, dynamic>> getSettings() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/settings'),
      headers: jsonHeaders,
    );

    final body = _decodeResponse(response);
    if (body is Map<String, dynamic>) return body;
    throw ApiException('Invalid settings response format.');
  }

  static Future<Map<String, dynamic>> updateSettings(Map<String, dynamic> payload) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/settings'),
      headers: jsonHeaders,
      body: jsonEncode(payload),
    );

    final body = _decodeResponse(response);
    if (body is Map<String, dynamic>) return body;
    throw ApiException('Invalid update settings response format.');
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
    if (body is Map<String, dynamic>) return body;
    throw ApiException('Invalid status update response format.');
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
