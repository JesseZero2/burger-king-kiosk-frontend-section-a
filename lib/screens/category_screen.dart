import 'package:flutter/material.dart';
import '../data/mock_products.dart';
import '../services/api_service.dart';
import '../services/cart_service.dart';
import '../widgets/bk_app_bar.dart';
import 'cart_screen.dart';
import 'product_detail_screen.dart';

String categoryLabel(String category) {
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
      return category
          .replaceAll('_', ' ')
          .split(' ')
          .map((word) {
            if (word.isEmpty) return word;
            return word[0].toUpperCase() + word.substring(1);
          })
          .join(' ');
  }
}

const List<String> _backendCategoryOrder = [
  'all_day_breakfast',
  'bk_cafe',
  'chicken_king',
  'chicken_rice_meals',
  'dessert',
  'drinks',
  'featured',
  'flame_grilled_cheeseburger',
  'group_meals',
  'king_savers_bundles',
  'king_specials',
  'plant_based_whopper',
  'ultimate_sidekings',
  'whopper',
  'xtra_long_chicken',
];

String _normalizeCategory(String value) {
  final normalized = value.trim().toLowerCase();

  // Exact match first
  if (_backendCategoryOrder.contains(normalized)) return normalized;

  // Keyword-based fallback mapping (mirror admin logic)
  if (normalized.contains('breakfast')) return 'all_day_breakfast';
  if (normalized.contains('cafe') || normalized.contains('café') || normalized.contains('coffee')) return 'bk_cafe';
  if (normalized.contains('rice')) return 'chicken_rice_meals';
  if (normalized.contains('chicken')) return 'chicken_king';
  if (normalized.contains('dessert')) return 'dessert';
  if (normalized.contains('drink') || normalized.contains('beverage')) return 'drinks';
  if (normalized.contains('featured') || normalized.contains('special') || normalized.contains('promo')) return 'featured';
  if (normalized.contains('flame') || normalized.contains('grilled') || normalized.contains('cheeseburger')) return 'flame_grilled_cheeseburger';
  if (normalized.contains('group') || normalized.contains('bundle') || normalized.contains('family')) return 'group_meals';
  if (normalized.contains('saver') || normalized.contains('value')) return 'king_savers_bundles';
  if (normalized.contains('king_special') || normalized.contains('king special')) return 'king_specials';
  if (normalized.contains('plant') || normalized.contains('vegan') || normalized.contains('veggie')) return 'plant_based_whopper';
  if (normalized.contains('sidek') || normalized.contains('side')) return 'ultimate_sidekings';
  if (normalized.contains('xtra') || normalized.contains('long') || normalized.contains('extra')) return 'xtra_long_chicken';
  if (normalized.contains('burger') || normalized.contains('whopper')) return 'whopper';
  if (normalized.contains('meal')) return 'group_meals';

  return normalized;
}

class CategoryScreen extends StatefulWidget {
  final String orderType;

  const CategoryScreen({
    super.key,
    required this.orderType,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  String selectedCategory = '';
  bool isLoading = true;
  String? errorMessage;
  List<Product> products = [];

  // backend category order is defined at top-level

  List<String> get categories {
    // Use backend category order (asset folders) as the primary list so
    // the kiosk shows all configured categories regardless of loaded items.
    final categorySet = products.map((product) => product.category).toSet();
    final extraCategories = categorySet.difference(_backendCategoryOrder.toSet()).toList()..sort();

    return [..._backendCategoryOrder, ...extraCategories];
  }

  List<Product> get selectedProducts {
    return products
        .where((product) => product.category == selectedCategory)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    loadMenuItems();
  }

  Future<void> loadMenuItems() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final menuItems = await ApiService.getMenuItems();
      final loadedProducts = menuItems.map(_productFromApi).toList();
      final loadedCategorySet = loadedProducts.map((product) => product.category).toSet();

      if (!mounted) return;

      setState(() {
        products = loadedProducts;
        selectedCategory = _selectInitialCategory(loadedCategorySet);
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = error.toString();
        isLoading = false;
      });
    }
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

  double _parsePrice(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _selectInitialCategory(Set<String> loadedCategorySet) {
    if (loadedCategorySet.contains('featured')) return 'featured';

    for (final category in _backendCategoryOrder) {
      if (loadedCategorySet.contains(category)) {
        return category;
      }
    }

    // Fall back to the first backend category (asset folder) so the UI
    // always has a sensible selected category even if no products loaded.
    if (_backendCategoryOrder.isNotEmpty) return _backendCategoryOrder.first;

    return loadedCategorySet.isNotEmpty ? loadedCategorySet.first : '';
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
        builder: (_) => CartScreen(orderType: widget.orderType),
      ),
    );

    setState(() {});
  }

  String getCategoryImage(String category) {
    final categoryProducts = products.where((product) => product.category == category).toList();

    if (categoryProducts.isNotEmpty) {
      return categoryProducts.first.image;
    }

    return 'assets/products/placeholder.webp';
  }

  String getProductDescription(String category) {
    final lower = category.toLowerCase();

    if (lower.contains('featured')) {
      return 'Popular picks and limited-time favorites.';
    }
    if (lower.contains('burger') || lower.contains('whopper')) {
      return 'Flame-grilled burger with classic BK flavor.';
    }
    if (lower.contains('chicken')) {
      return 'Crispy and flavorful chicken favorites.';
    }
    if (lower.contains('cheeseburger')) {
      return 'Classic cheeseburgers with flame-grilled taste.';
    }
    if (lower.contains('breakfast')) {
      return 'Breakfast meals and morning favorites.';
    }
    if (lower.contains('side') || lower.contains('savers')) {
      return 'Fries, nuggets, dips, and side items.';
    }
    if (lower.contains('cafe')) {
      return 'Coffee, matcha, mocha, and affogato drinks.';
    }
    if (lower.contains('drink')) {
      return 'Cold drinks and refreshing beverages.';
    }
    if (lower.contains('dessert')) {
      return 'Sweet treats to complete your meal.';
    }
    if (lower.contains('group') || lower.contains('meal')) {
      return 'Meal bundles good for sharing.';
    }

    return 'Burger King menu item.';
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isTabletLayout = width < 900;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BKAppBar(
        cartCount: CartService.itemCount,
        onCartPressed: openCart,
      ),
      body: _buildBody(isTabletLayout, width),
    );
  }

  Widget _buildBody(bool isTabletLayout, double width) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return _ErrorState(
        message: errorMessage!,
        onRetry: loadMenuItems,
      );
    }

    if (products.isEmpty || categories.isEmpty) {
      return _ErrorState(
        message: 'No menu items found from backend.',
        onRetry: loadMenuItems,
      );
    }

    return Column(
      children: [
        Expanded(
          child: isTabletLayout ? _buildTabletLayout() : _buildLaptopLayout(width),
        ),
        if (CartService.itemCount > 0) _buildViewOrderBar(),
      ],
    );
  }

  Widget _buildLaptopLayout(double screenWidth) {
    return Row(
      children: [
        _buildLeftCategoryPanel(screenWidth),
        Expanded(
          child: _buildProductArea(),
        ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Column(
      children: [
        _buildTopCategoryList(),
        Expanded(
          child: _buildProductArea(),
        ),
      ],
    );
  }

  Widget _buildLeftCategoryPanel(double screenWidth) {
    return Container(
      width: screenWidth * 0.28,
      padding: const EdgeInsets.all(10),
      color: const Color(0xFF4A1600),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 10, top: 4),
            child: Text(
              'MENU',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFC72C),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = selectedCategory == category;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _CategoryTile(
                    category: category,
                    image: getCategoryImage(category),
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopCategoryList() {
    return Container(
      height: 120,
      color: const Color(0xFF4A1600),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: SizedBox(
              width: 145,
              child: _CategoryTile(
                category: category,
                image: getCategoryImage(category),
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    selectedCategory = category;
                  });
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductArea() {
    final selectedProductsList = selectedProducts;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _buildSelectedCategoryHeader(),
          const SizedBox(height: 12),
          Expanded(
            child: selectedProductsList.isEmpty
                ? _buildEmptyCategoryView()
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final bool compact = constraints.maxWidth < 650;

                      return GridView.builder(
                        itemCount: selectedProductsList.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: compact ? 0.95 : 1.08,
                        ),
                        itemBuilder: (context, index) {
                          final product = selectedProductsList[index];

                          return _ProductCard(
                            product: product,
                            onTap: () async {
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
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCategoryView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.search_off,
            size: 72,
            color: Color(0xFFD62300),
          ),
          const SizedBox(height: 18),
          Text(
            'No items available for "${categoryLabel(selectedCategory)}".',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF4A1600),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Please select another category or check back later.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF4A1600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedCategoryHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFD62300),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Image.asset(
              getCategoryImage(selectedCategory),
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.fastfood,
                  color: Color(0xFFD62300),
                );
              },
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categoryLabel(selectedCategory),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  getProductDescription(selectedCategory),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewOrderBar() {
    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 58,
          child: ElevatedButton(
            onPressed: openCart,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD62300),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'VIEW ORDER',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${CartService.itemCount} item(s)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '₱${CartService.total.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
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

class _CategoryTile extends StatelessWidget {
  final String category;
  final String image;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.category,
    required this.image,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 80,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFC72C) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.white : const Color(0xFFFFC72C),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                image,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.fastfood,
                    color: Color(0xFFD62300),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                categoryLabel(category),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A1600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const _ProductCard({
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFFFC72C),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 78),
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
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: 78,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.96),
                    border: const Border(
                      top: BorderSide(
                        color: Color(0xFFFFC72C),
                        width: 2,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A1600),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '₱${product.price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD62300),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 30,
                            child: ElevatedButton(
                              onPressed: onTap,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD62300),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'ADD',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
