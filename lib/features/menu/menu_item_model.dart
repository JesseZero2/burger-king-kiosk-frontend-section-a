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
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] is num ? (json['price'] as num).toDouble() : double.tryParse('${json['price']}') ?? 0.0,
      isAvailable: json['is_available'] == true || json['is_available'] == 1,
      imageUrl: json['image_url'] ?? '',
    );
  }
}
