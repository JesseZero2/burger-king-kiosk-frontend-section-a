import 'package:flutter/material.dart';
import '../data/mock_products.dart';
import '../services/cart_service.dart';
import '../widgets/bk_app_bar.dart';
import 'cart_screen.dart';
import 'product_detail_screen.dart';

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
  late String selectedCategory;

  List<String> get categories {
    final allCategories =
        mockProducts.map((product) => product.category).toSet().toList();

    allCategories.sort((a, b) {
      if (a == 'Featured') return -1;
      if (b == 'Featured') return 1;
      return a.compareTo(b);
    });

    return allCategories;
  }

  List<Product> get selectedProducts {
    return mockProducts
        .where((product) => product.category == selectedCategory)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    selectedCategory =
        categories.contains('Featured') ? 'Featured' : categories.first;
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
    final products =
        mockProducts.where((product) => product.category == category).toList();

    if (products.isNotEmpty) {
      return products.first.image;
    }

    return 'assets/products/placeholder.webp';
  }

  String getProductDescription(String category) {
    final lower = category.toLowerCase();

    if (lower.contains('featured')) {
      return 'Popular picks and limited-time favorites.';
    }
    if (lower.contains('whopper')) {
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
    if (lower.contains('drinks')) {
      return 'Cold drinks and refreshing beverages.';
    }
    if (lower.contains('dessert')) {
      return 'Sweet treats to complete your meal.';
    }
    if (lower.contains('group')) {
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
      body: Column(
        children: [
          Expanded(
            child: isTabletLayout
                ? _buildTabletLayout()
                : _buildLaptopLayout(width),
          ),
          if (CartService.itemCount > 0) _buildViewOrderBar(),
        ],
      ),
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
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _buildSelectedCategoryHeader(),
          const SizedBox(height: 12),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool compact = constraints.maxWidth < 650;

                return GridView.builder(
                  itemCount: selectedProducts.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: compact ? 0.95 : 1.08,
                  ),
                  itemBuilder: (context, index) {
                    final product = selectedProducts[index];

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
                  selectedCategory,
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
                category,
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