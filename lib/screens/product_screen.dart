import 'package:flutter/material.dart';
import '../data/mock_products.dart';
import '../services/api_service.dart';
import '../services/cart_service.dart';
import 'cart_screen.dart';
import 'product_detail_screen.dart';

class ProductScreen extends StatefulWidget {
  final String category;
  final String orderType;

  const ProductScreen({
    super.key,
    required this.category,
    required this.orderType,
  });

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _loadProducts();
  }

  Future<List<Product>> _loadProducts() async {
    final menuItems = await ApiService.getMenuItems();

    return menuItems
        .map(_productFromApi)
        .where((product) => product.category == widget.category)
        .toList();
  }

  Product _productFromApi(Map<String, dynamic> item) {
    final name = item['name']?.toString() ?? 'Menu Item';
    final rawCategory = item['category']?.toString() ?? 'Menu';
    final category = _normalizeCategory(rawCategory);
    final id = int.tryParse(item['id']?.toString() ?? '') ?? name.hashCode.abs();
    final price = _parsePrice(item['price']);

    return Product(
      id: id,
      category: category,
      name: name,
      price: price,
      image: _fallbackImage(name, category),
    );
  }

  String _normalizeCategory(String value) {
    final normalized = value.trim().toLowerCase();

    if (normalized.contains('breakfast')) return 'all_day_breakfast';
    if (normalized.contains('cafe') || normalized.contains('café') || normalized.contains('coffee')) return 'bk_cafe';
    if (normalized.contains('rice')) return 'chicken_rice_meals';
    if (normalized.contains('chicken')) return 'chicken_king';
    if (normalized.contains('dessert') || normalized.contains('sundae')) return 'dessert';
    if (normalized.contains('drink') || normalized.contains('beverage') || normalized.contains('float')) return 'drinks';
    if (normalized.contains('featured') || normalized.contains('popular')) return 'featured';
    if (normalized.contains('flame') || normalized.contains('cheese') || normalized.contains('cheeseburger')) return 'flame_grilled_cheeseburger';
    if (normalized.contains('group')) return 'group_meals';
    if (normalized.contains('saver') || normalized.contains('bundle')) return 'king_savers_bundles';
    if (normalized.contains('king') && normalized.contains('special')) return 'king_specials';
    if (normalized.contains('plant') || normalized.contains('vegan')) return 'plant_based_whopper';
    if (normalized.contains('side')) return 'ultimate_sidekings';
    if (normalized.contains('x-tra') || normalized.contains('xtra') || normalized.contains('long')) return 'xtra_long_chicken';
    if (normalized.contains('whopper') || normalized.contains('burger')) return 'whopper';

    return normalized.replaceAll(' ', '_');
  }

  double _parsePrice(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _categoryLabel(String category) {
    switch (category) {
      case 'all_day_breakfast':
        return 'All Day Breakfast';
      case 'bk_cafe':
        return 'BK Café';
      case 'chicken_king':
        return 'Chicken King';
      case 'chicken_rice_meals':
        return 'Chicken Rice Meals';
      case 'dessert':
        return 'Dessert';
      case 'drinks':
        return 'Drinks';
      case 'featured':
        return 'Featured';
      case 'flame_grilled_cheeseburger':
        return 'Flame Grilled Cheeseburger';
      case 'group_meals':
        return 'Group Meals';
      case 'king_savers_bundles':
        return 'King Savers Bundles';
      case 'king_specials':
        return 'King Specials';
      case 'plant_based_whopper':
        return 'Plant Based Whopper';
      case 'ultimate_sidekings':
        return 'Ultimate Sidekings';
      case 'whopper':
        return 'Whopper';
      case 'xtra_long_chicken':
        return 'Xtra Long Chicken';
      default:
        return category.replaceAll('_', ' ').split(' ').map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1);
        }).join(' ');
    }
  }

  String _fallbackImage(String name, String category) {
    final text = '${name.toLowerCase()} ${category.toLowerCase()}';

    if (text.contains('whopper')) return 'assets/products/whopper/whopper.webp';
    if (text.contains('cheese')) {
      return 'assets/products/flame_grilled_cheeseburger/flamed_grilled_cheese_burger.webp';
    }
    if (text.contains('chicken')) return 'assets/products/chicken_king/chicken_king.webp';
    if (text.contains('fries')) return 'assets/products/ultimate_sidekings/thick_cut_fries.webp';
    if (text.contains('nugget')) return 'assets/products/ultimate_sidekings/6pc_chicken_nuggets.webp';
    if (text.contains('coke')) return 'assets/products/drinks/coke_original_taste.webp';
    if (text.contains('drink')) return 'assets/products/drinks/coke_original_taste.webp';
    if (text.contains('dessert') || text.contains('sundae')) {
      return 'assets/products/dessert/chocolate_sundae.webp';
    }

    return 'assets/products/placeholder.webp';
  }

  void openCart() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CartScreen(
          orderType: widget.orderType,
        ),
      ),
    );

    setState(() {});
  }

  void _reloadProducts() {
    setState(() {
      _productsFuture = _loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3D6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD62300),
        foregroundColor: Colors.white,
        title: Text(_categoryLabel(widget.category)),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart, size: 32),
                if (CartService.itemCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: CircleAvatar(
                      radius: 9,
                      backgroundColor: const Color(0xFFFFC72C),
                      child: Text(
                        CartService.itemCount.toString(),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF4A1600),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: openCart,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _ErrorState(
              message: snapshot.error.toString(),
              onRetry: _reloadProducts,
            );
          }

          final products = snapshot.data ?? [];

          if (products.isEmpty) {
            return _ErrorState(
              message: 'No menu items found for ${_categoryLabel(widget.category)}.',
              onRetry: _reloadProducts,
            );
          }

          return Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: GridView.builder(
                    itemCount: products.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 0.9,
                    ),
                    itemBuilder: (context, index) {
                      final product = products[index];

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFFFC72C),
                            width: 3,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Image.asset(
                                  product.image,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.fastfood,
                                      size: 80,
                                      color: Color(0xFFD62300),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                product.name,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4A1600),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '₱${product.price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFD62300),
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ProductDetailScreen(
                                          product: product,
                                          orderType: widget.orderType,
                                        ),
                                      ),
                                    );
                                    setState(() {});
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD62300),
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('ADD'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (CartService.itemCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  color: Colors.white,
                  child: SafeArea(
                    top: false,
                    child: SizedBox(
                      width: double.infinity,
                      height: 70,
                      child: ElevatedButton(
                        onPressed: openCart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD62300),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'VIEW ORDER',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${CartService.itemCount} item(s)',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '₱${CartService.total.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off,
              size: 52,
              color: Color(0xFFD62300),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF4A1600),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD62300),
                foregroundColor: Colors.white,
              ),
              child: const Text('RETRY'),
            ),
          ],
        ),
      ),
    );
  }
}
