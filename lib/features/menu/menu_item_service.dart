import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../services/api_service.dart';
import 'menu_item_model.dart';

const String baseUrl = '${ApiService.baseUrl}/api';

class MenuItemService {
  List<dynamic> _extractList(dynamic body) {
    if (body is List) return body;

    if (body is Map<String, dynamic>) {
      if (body['data'] is List) return body['data'] as List;
      if (body['menu_items'] is List) return body['menu_items'] as List;
      if (body['items'] is List) return body['items'] as List;
    }

    return [];
  }

  Map<String, dynamic> _extractItem(dynamic body) {
    if (body is Map<String, dynamic>) {
      if (body['data'] is Map) {
        return Map<String, dynamic>.from(body['data']);
      }

      if (body['menu_item'] is Map) {
        return Map<String, dynamic>.from(body['menu_item']);
      }

      if (body['item'] is Map) {
        return Map<String, dynamic>.from(body['item']);
      }

      return body;
    }

    throw Exception('Invalid menu item response');
  }

  String _errorMessage(http.Response response, String fallback) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map && body['message'] != null) {
        return body['message'].toString();
      }
    } catch (_) {}

    return '$fallback. HTTP ${response.statusCode}';
  }

  Future<List<MenuItemModel>> getMenuItems({String? category}) async {
    final query = category != null && category.isNotEmpty && category != 'all'
        ? '?category=$category'
        : '';

    final response = await http.get(
      Uri.parse('$baseUrl/menu-items$query'),
      headers: ApiService.jsonHeaders,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_errorMessage(response, 'Failed to load menu items'));
    }

    final body = jsonDecode(response.body);
    final list = _extractList(body);

    return list
        .whereType<Map>()
        .map((item) => MenuItemModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<MenuItemModel> createMenuItem({
    required String name,
    required String category,
    required double price,
    required String description,
    required bool isAvailable,
    String? imageUrl,
    Uint8List? imageBytes,
    String? imageFilename,
  }) async {
    final payload = {
      'name': name,
      'category': category,
      'price': price,
      'description': description,
      'is_available': isAvailable ? 1 : 0,
      'available': isAvailable ? 1 : 0,
      'image_url': imageUrl ?? '',
    };

    final response = await http.post(
      Uri.parse('$baseUrl/menu-items'),
      headers: ApiService.jsonHeaders,
      body: jsonEncode(payload),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_errorMessage(response, 'Failed to create menu item'));
    }

    return MenuItemModel.fromJson(_extractItem(jsonDecode(response.body)));
  }

  Future<MenuItemModel> updateMenuItem({
    required int id,
    required String name,
    required String category,
    required double price,
    required String description,
    required bool isAvailable,
    String? imageUrl,
    Uint8List? imageBytes,
    String? imageFilename,
  }) async {
    final payload = {
      'name': name,
      'category': category,
      'price': price,
      'description': description,
      'is_available': isAvailable ? 1 : 0,
      'available': isAvailable ? 1 : 0,
      'image_url': imageUrl ?? '',
    };

    final response = await http.put(
      Uri.parse('$baseUrl/menu-items/$id'),
      headers: ApiService.jsonHeaders,
      body: jsonEncode(payload),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_errorMessage(response, 'Failed to update menu item'));
    }

    return MenuItemModel.fromJson(_extractItem(jsonDecode(response.body)));
  }

  Future<void> toggleAvailability(int id, bool isAvailable) async {
    final current = await getMenuItems();
    final item = current.firstWhere((menuItem) => menuItem.id == id);

    await updateMenuItem(
      id: item.id,
      name: item.name,
      category: item.category,
      price: item.price,
      description: item.description,
      isAvailable: isAvailable,
      imageUrl: item.imageUrl,
    );
  }

  Future<void> deleteMenuItem(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/menu-items/$id'),
      headers: ApiService.jsonHeaders,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_errorMessage(response, 'Failed to delete menu item'));
    }
  }
}
