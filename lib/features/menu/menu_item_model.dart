class MenuItemModel {
  final int id;
  final String name;
  final String category;
  final String description;
  final double price;
  final bool isAvailable;
  final String imageUrl;

  MenuItemModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.isAvailable,
    required this.imageUrl,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: _readInt(json['id']),
      name: _readString(json['name']),
      category: _readString(json['category']),
      description: _readString(json['description']),
      price: _readDouble(json['price']),
      isAvailable: _readAvailability(json),
      imageUrl: _readImageUrl(json),
    );
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse('$value') ?? 0;
  }

  static double _readDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? 0.0;
  }

  static String _readString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  static String _readImageUrl(Map<String, dynamic> json) {
    final value = json['image_url'] ??
        json['imageUrl'] ??
        json['image'] ??
        json['image_path'] ??
        json['photo_url'] ??
        json['product_image'];

    if (value == null) return '';
    return value.toString().trim();
  }

  static bool _readAvailability(Map<String, dynamic> json) {
    final value = json['is_available'] ??
        json['isAvailable'] ??
        json['available'] ??
        json['availability'] ??
        json['is_active'] ??
        json['active'] ??
        json['status'];

    if (value == null) {
      return true;
    }

    if (value is bool) return value;
    if (value is num) return value != 0;

    final text = value.toString().trim().toLowerCase();

    if (text.isEmpty) {
      return true;
    }

    const visibleValues = {
      '1',
      'true',
      'yes',
      'y',
      'available',
      'visible',
      'active',
      'enabled',
      'in_stock',
      'instock',
      'published',
    };

    const hiddenValues = {
      '0',
      'false',
      'no',
      'n',
      'unavailable',
      'hidden',
      'inactive',
      'disabled',
      'out_of_stock',
      'out of stock',
      'draft',
    };

    if (visibleValues.contains(text)) return true;
    if (hiddenValues.contains(text)) return false;

    return true;
  }
}
