import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../services/api_service.dart';
import 'menu_item_model.dart';

const String baseUrl = '${ApiService.baseUrl}/api';

class MenuItemService {
  Future<List<MenuItemModel>> getMenuItems({String? category}) async {
    final query = category != null && category.isNotEmpty ? '?category=$category' : '';
    final response = await http.get(Uri.parse('$baseUrl/menu-items$query'), headers: ApiService.authHeaders);

    if (response.statusCode != 200) {
      throw Exception('Failed to load menu items');
    }

    final data = jsonDecode(response.body);
    if (data is List) {
      return data.map((item) => MenuItemModel.fromJson(item as Map<String, dynamic>)).toList();
    }

    return [];
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
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/menu-items'));
    request.headers.addAll(ApiService.authHeaders);
    request.fields.addAll({
      'name': name,
      'category': category,
      'price': price.toString(),
      'description': description,
      'is_available': isAvailable ? '1' : '0',
    });
    if (imageUrl != null && imageUrl.isNotEmpty) {
      request.fields['image_url'] = imageUrl;
    }
    if (imageBytes != null && imageFilename != null) {
      request.files.add(http.MultipartFile.fromBytes('image', imageBytes, filename: imageFilename));
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to create menu item');
    }

    return MenuItemModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
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
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/menu-items/$id'));
    request.headers.addAll(ApiService.authHeaders);
    request.fields.addAll({
      '_method': 'PUT',
      'name': name,
      'category': category,
      'price': price.toString(),
      'description': description,
      'is_available': isAvailable ? '1' : '0',
    });
    if (imageUrl != null && imageUrl.isNotEmpty) {
      request.fields['image_url'] = imageUrl;
    }
    if (imageBytes != null && imageFilename != null) {
      request.files.add(http.MultipartFile.fromBytes('image', imageBytes, filename: imageFilename));
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to update menu item');
    }

    return MenuItemModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> toggleAvailability(int id, bool isAvailable) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/menu-items/$id/availability'),
      headers: ApiService.jsonHeaders,
      body: jsonEncode({'is_available': isAvailable ? 1 : 0}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to update availability');
    }
  }

  Future<void> deleteMenuItem(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/menu-items/$id'), headers: ApiService.authHeaders);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to delete menu item');
    }
  }
}
