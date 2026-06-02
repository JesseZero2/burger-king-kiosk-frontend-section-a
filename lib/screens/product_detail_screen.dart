import 'package:flutter/material.dart';
import '../data/mock_products.dart';
import '../services/cart_service.dart';
import '../widgets/bk_app_bar.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final String orderType;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.orderType,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;

  bool extraCheese = false;
  bool bacon = false;
  bool extraPatty = false;

  double get addonsPrice {
    double total = 0;
    if (extraCheese) total += 20;
    if (bacon) total += 30;
    if (extraPatty) total += 60;
    return total;
  }

  List<String> get selectedAddons {
    final addons = <String>[];
    if (extraCheese) addons.add('Extra Cheese');
    if (bacon) addons.add('Bacon');
    if (extraPatty) addons.add('Extra Patty');
    return addons;
  }

  double get totalPrice => (widget.product.price + addonsPrice) * quantity;

  String getProductDescription() {
    final name = widget.product.name.toLowerCase();
    final category = widget.product.category.toLowerCase();

    if (name.contains('whopper')) {
      return 'A flame-grilled Burger King favorite served with fresh vegetables and classic sauces.';
    }
    if (name.contains('angriest')) {
      return 'A spicy Burger King favorite made for customers who want extra heat and bold flavor.';
    }
    if (name.contains('chicken king')) {
      return 'A crispy chicken sandwich served in a soft bun with rich and savory flavor.';
    }
    if (name.contains('x-tra long chicken')) {
      return 'A long crispy chicken sandwich made for a bigger and more satisfying bite.';
    }
    if (category.contains('cheeseburger')) {
      return 'A classic flame-grilled burger with cheese and Burger King flavor.';
    }
    if (category.contains('king specials')) {
      return 'A premium Burger King burger made with bigger flavor and satisfying toppings.';
    }
    if (category.contains('chicken rice')) {
      return 'A filling rice meal served with flavorful chicken and sauce.';
    }
    if (category.contains('breakfast')) {
      return 'A breakfast favorite made to start your day with a satisfying meal.';
    }
    if (category.contains('side')) {
      return 'A tasty side item that pairs well with burgers, drinks, and meals.';
    }
    if (category.contains('cafe')) {
      return 'A refreshing Burger King cafe drink made for coffee and dessert lovers.';
    }
    if (category.contains('drinks')) {
      return 'A cold and refreshing drink to complete your meal.';
    }
    if (category.contains('dessert')) {
      return 'A sweet treat to enjoy after your meal.';
    }
    if (category.contains('group')) {
      return 'A meal bundle made for sharing with family or friends.';
    }
    if (category.contains('savers')) {
      return 'A budget-friendly Burger King meal option.';
    }

    return 'A Burger King menu item made fresh and ready to order.';
  }

  bool get showAddons {
    final category = widget.product.category.toLowerCase();
    return category.contains('whopper');
  }

  void addToOrder() {
    CartService.addToCart(
      widget.product,
      quantity,
      addons: selectedAddons,
      addonsPrice: addonsPrice,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isPhone = width < 700;

    return Scaffold(
      appBar: const BKAppBar(),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: isPhone ? _buildPhoneLayout() : _buildWideLayout(),
      ),
    );
  }

  Widget _buildWideLayout() {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: _productImageCard(isPhone: false),
          ),
          const SizedBox(width: 18),
          Expanded(
            flex: 5,
            child: _detailsCard(isPhone: false),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          SizedBox(
            height: 260,
            child: _productImageCard(isPhone: true),
          ),
          const SizedBox(height: 14),
          _detailsCard(isPhone: true),
        ],
      ),
    );
  }

  Widget _productImageCard({required bool isPhone}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isPhone ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isPhone ? 22 : 26),
        border: Border.all(
          color: const Color(0xFFFFC72C),
          width: 4,
        ),
      ),
      child: Image.asset(
        widget.product.image,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(
            Icons.fastfood,
            size: 120,
            color: Color(0xFFD62300),
          );
        },
      ),
    );
  }

  Widget _detailsCard({required bool isPhone}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isPhone ? 18 : 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isPhone ? 22 : 26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: isPhone
            ? Border.all(
                color: const Color(0xFFFFC72C),
                width: 3,
              )
            : null,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.product.name,
              maxLines: isPhone ? 3 : 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isPhone ? 25 : 30,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4A1600),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              getProductDescription(),
              style: TextStyle(
                fontSize: isPhone ? 14 : 16,
                height: 1.35,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3D6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                widget.orderType,
                style: TextStyle(
                  fontSize: isPhone ? 13 : 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4A1600),
                ),
              ),
            ),
            if (showAddons) ...[
              const SizedBox(height: 18),
              Text(
                'Customize Your Order',
                style: TextStyle(
                  fontSize: isPhone ? 20 : 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4A1600),
                ),
              ),
              const SizedBox(height: 10),
              isPhone ? _buildPhoneAddons() : _buildWideAddons(),
            ],
            const SizedBox(height: 18),
            Text(
              'Quantity',
              style: TextStyle(
                fontSize: isPhone ? 20 : 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4A1600),
              ),
            ),
            const SizedBox(height: 10),
            _buildQuantitySelector(isPhone),
            const SizedBox(height: 18),
            _buildSummaryBox(isPhone),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: isPhone ? 58 : 62,
              child: ElevatedButton(
                onPressed: addToOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD62300),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'ADD TO ORDER',
                  style: TextStyle(
                    fontSize: isPhone ? 20 : 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWideAddons() {
    return SizedBox(
      height: 170,
      child: Row(
        children: [
          Expanded(
            child: _AddonCard(
              image: 'assets/addons/cheese.png',
              title: 'Cheese',
              price: 20,
              isSelected: extraCheese,
              isPhone: false,
              onTap: () {
                setState(() {
                  extraCheese = !extraCheese;
                });
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _AddonCard(
              image: 'assets/addons/bacon.png',
              title: 'Bacon',
              price: 30,
              isSelected: bacon,
              isPhone: false,
              onTap: () {
                setState(() {
                  bacon = !bacon;
                });
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _AddonCard(
              image: 'assets/addons/patty.png',
              title: 'Patty',
              price: 60,
              isSelected: extraPatty,
              isPhone: false,
              onTap: () {
                setState(() {
                  extraPatty = !extraPatty;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneAddons() {
    return Column(
      children: [
        _AddonCard(
          image: 'assets/addons/cheese.png',
          title: 'Cheese',
          price: 20,
          isSelected: extraCheese,
          isPhone: true,
          onTap: () {
            setState(() {
              extraCheese = !extraCheese;
            });
          },
        ),
        const SizedBox(height: 10),
        _AddonCard(
          image: 'assets/addons/bacon.png',
          title: 'Bacon',
          price: 30,
          isSelected: bacon,
          isPhone: true,
          onTap: () {
            setState(() {
              bacon = !bacon;
            });
          },
        ),
        const SizedBox(height: 10),
        _AddonCard(
          image: 'assets/addons/patty.png',
          title: 'Patty',
          price: 60,
          isSelected: extraPatty,
          isPhone: true,
          onTap: () {
            setState(() {
              extraPatty = !extraPatty;
            });
          },
        ),
      ],
    );
  }

  Widget _buildQuantitySelector(bool isPhone) {
    return Container(
      height: isPhone ? 62 : 68,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3D6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFC72C),
          width: 3,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _QuantityButton(
            icon: Icons.remove,
            isPhone: isPhone,
            onTap: () {
              if (quantity > 1) {
                setState(() {
                  quantity--;
                });
              }
            },
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isPhone ? 24 : 30),
            child: Text(
              quantity.toString(),
              style: TextStyle(
                fontSize: isPhone ? 30 : 34,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4A1600),
              ),
            ),
          ),
          _QuantityButton(
            icon: Icons.add,
            isPhone: isPhone,
            onTap: () {
              setState(() {
                quantity++;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBox(bool isPhone) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isPhone ? 13 : 15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3D6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _SummaryRow(
            label: 'Item Price',
            value: '₱${widget.product.price.toStringAsFixed(0)}',
            isPhone: isPhone,
          ),
          const SizedBox(height: 6),
          if (showAddons)
            _SummaryRow(
              label: 'Add-ons',
              value: '₱${addonsPrice.toStringAsFixed(0)}',
              isPhone: isPhone,
            ),
          if (showAddons) const SizedBox(height: 6),
          _SummaryRow(
            label: 'Quantity',
            value: quantity.toString(),
            isPhone: isPhone,
          ),
          const Divider(height: 20),
          _SummaryRow(
            label: 'Total',
            value: '₱${totalPrice.toStringAsFixed(0)}',
            isTotal: true,
            isPhone: isPhone,
          ),
        ],
      ),
    );
  }
}

class _AddonCard extends StatelessWidget {
  final String image;
  final String title;
  final double price;
  final bool isSelected;
  final bool isPhone;
  final VoidCallback onTap;

  const _AddonCard({
    required this.image,
    required this.title,
    required this.price,
    required this.isSelected,
    required this.isPhone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: isPhone ? 110 : 150,
        padding: EdgeInsets.all(isPhone ? 10 : 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFC72C) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFD62300)
                : const Color(0xFFFFC72C),
            width: 3,
          ),
        ),
        child: Stack(
          children: [
            isPhone
                ? Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Image.asset(
                          image,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.fastfood,
                              size: 40,
                              color: Color(0xFFD62300),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 3,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4A1600),
                              ),
                            ),
                            Text(
                              '+₱${price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFFD62300),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Image.asset(
                          image,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.fastfood,
                              size: 45,
                              color: Color(0xFFD62300),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A1600),
                        ),
                      ),
                      Text(
                        '+₱${price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFFD62300),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
            if (isSelected)
              const Positioned(
                top: 0,
                right: 0,
                child: Icon(
                  Icons.check_circle,
                  color: Color(0xFFD62300),
                  size: 24,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final bool isPhone;
  final VoidCallback onTap;

  const _QuantityButton({
    required this.icon,
    required this.isPhone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isPhone ? 48 : 54,
      height: isPhone ? 48 : 54,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD62300),
          foregroundColor: Colors.white,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Icon(
          icon,
          size: isPhone ? 28 : 30,
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;
  final bool isPhone;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.isPhone,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal
                ? isPhone
                    ? 19
                    : 21
                : isPhone
                    ? 15
                    : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: const Color(0xFF4A1600),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal
                ? isPhone
                    ? 22
                    : 26
                : isPhone
                    ? 16
                    : 18,
            fontWeight: FontWeight.bold,
            color: isTotal
                ? const Color(0xFFD62300)
                : const Color(0xFF4A1600),
          ),
        ),
      ],
    );
  }
}