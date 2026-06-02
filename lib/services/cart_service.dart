import '../data/mock_products.dart';

class CartItem {
  final Product product;
  int quantity;
  final List<String> addons;
  final double addonsPrice;

  CartItem({
    required this.product,
    required this.quantity,
    this.addons = const [],
    this.addonsPrice = 0,
  });

  double get unitPrice => product.price + addonsPrice;

  double get totalPrice => unitPrice * quantity;
}

class CartService {
  static final List<CartItem> items = [];

  static void addToCart(
    Product product,
    int quantity, {
    List<String> addons = const [],
    double addonsPrice = 0,
  }) {
    items.add(
      CartItem(
        product: product,
        quantity: quantity,
        addons: addons,
        addonsPrice: addonsPrice,
      ),
    );
  }

  static void removeFromCart(Product product) {
    items.removeWhere((item) => item.product.id == product.id);
  }

  static void increaseQuantity(Product product) {
    final index = items.indexWhere((item) => item.product.id == product.id);

    if (index >= 0) {
      items[index].quantity++;
    }
  }

  static void decreaseQuantity(Product product) {
    final index = items.indexWhere((item) => item.product.id == product.id);

    if (index >= 0) {
      if (items[index].quantity > 1) {
        items[index].quantity--;
      } else {
        removeFromCart(product);
      }
    }
  }

  static double get subtotal {
    double total = 0;

    for (final item in items) {
      total += item.totalPrice;
    }

    return total;
  }

  static double get tax {
    return subtotal * 0.12;
  }

  static double get total {
    return subtotal + tax;
  }

  static int get itemCount {
    int count = 0;

    for (final item in items) {
      count += item.quantity;
    }

    return count;
  }

  static void clearCart() {
    items.clear();
  }
}