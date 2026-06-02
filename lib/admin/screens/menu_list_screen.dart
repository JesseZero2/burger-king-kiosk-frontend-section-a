import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/menu/menu_item_model.dart';
import '../../features/menu/menu_item_service.dart';

class MenuListScreen extends StatefulWidget {
  const MenuListScreen({super.key});

  @override
  State<MenuListScreen> createState() => _MenuListScreenState();
}

class _MenuListScreenState extends State<MenuListScreen> {
  final MenuItemService _service = MenuItemService();
  late Future<List<MenuItemModel>> _menuFuture;

  String _selectedCategory = 'All';

  static const Color _bkRed = Color(0xFFD62300);
  static const Color _bkBrown = Color(0xFF351409);
  static const Color _bkCream = Color(0xFFFFF4DF);
  static const Color _bkCard = Color(0xFFFFFBF4);
  static const Color _bkBorder = Color(0xFFFFC86B);
  static const Color _bkGreen = Color(0xFF078C7A);

  @override
  void initState() {
    super.initState();
    _menuFuture = _loadMenuItems();
  }

  Future<List<MenuItemModel>> _loadMenuItems() {
    // Load all items, then filter locally. This avoids the DropdownButton crash
    // and also avoids backend category casing problems like Burgers vs burgers.
    return _service.getMenuItems();
  }

  void _refresh() {
    setState(() {
      _menuFuture = _loadMenuItems();
    });
  }

  Future<void> _openAddItem() async {
    await context.push('/admin/menu/add');
    if (!mounted) return;
    _refresh();
  }

  Future<void> _openEditItem(MenuItemModel item) async {
    await context.push('/admin/menu/edit/${item.id}', extra: item);
    if (!mounted) return;
    _refresh();
  }

  Future<void> _toggleAvailability(MenuItemModel item) async {
    try {
      await _service.toggleAvailability(item.id, !item.isAvailable);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            item.isAvailable
                ? '${item.name} is now hidden from customers.'
                : '${item.name} is now visible to customers.',
          ),
        ),
      );
      _refresh();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update item: $error')),
      );
    }
  }

  Future<void> _delete(MenuItemModel item) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Menu Item'),
        content: Text('Delete ${item.name}? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Delete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _bkRed,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _service.deleteMenuItem(item.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${item.name} was deleted.')),
      );
      _refresh();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete item: $error')),
      );
    }
  }

  List<String> _categoriesFromItems(List<MenuItemModel> items) {
    final Map<String, String> categories = {};

    for (final item in items) {
      final String rawCategory = item.category.trim();
      if (rawCategory.isEmpty) continue;

      final String key = rawCategory.toLowerCase();
      categories[key] = rawCategory.toTitleCase();
    }

    final List<String> sorted = categories.values.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    return ['All', ...sorted];
  }

  List<MenuItemModel> _filteredItems(List<MenuItemModel> items) {
    if (_selectedCategory == 'All') return items;

    return items
        .where(
          (item) =>
              item.category.trim().toLowerCase() ==
              _selectedCategory.trim().toLowerCase(),
        )
        .toList();
  }

  int _availableCount(List<MenuItemModel> items) {
    return items.where((item) => item.isAvailable).length;
  }

  int _hiddenCount(List<MenuItemModel> items) {
    return items.where((item) => !item.isAvailable).length;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFF6E8),
      child: FutureBuilder<List<MenuItemModel>>(
        future: _menuFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: _bkRed),
            );
          }

          if (snapshot.hasError) {
            return _ErrorState(
              message: snapshot.error.toString(),
              onRetry: _refresh,
            );
          }

          final List<MenuItemModel> allItems = snapshot.data ?? [];
          final List<String> categories = _categoriesFromItems(allItems);

          if (!categories.contains(_selectedCategory)) {
            _selectedCategory = 'All';
          }

          final List<MenuItemModel> items = _filteredItems(allItems);

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(28, 28, 28, 12),
                sliver: SliverToBoxAdapter(
                  child: _HeroHeader(onAddPressed: _openAddItem),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 16),
                sliver: SliverToBoxAdapter(
                  child: _SummaryRow(
                    total: allItems.length,
                    available: _availableCount(allItems),
                    hidden: _hiddenCount(allItems),
                    categories: categories.length - 1,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 18),
                sliver: SliverToBoxAdapter(
                  child: _CategoryChips(
                    categories: categories,
                    selectedCategory: _selectedCategory,
                    onSelected: (category) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  ),
                ),
              ),
              if (items.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(
                    selectedCategory: _selectedCategory,
                    onAddPressed: _openAddItem,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index.isOdd) return const SizedBox(height: 16);

                        final int itemIndex = index ~/ 2;
                        final MenuItemModel item = items[itemIndex];

                        return _MenuItemCard(
                          item: item,
                          onEdit: () => _openEditItem(item),
                          onToggleAvailability: () => _toggleAvailability(item),
                          onDelete: () => _delete(item),
                        );
                      },
                      childCount: items.length * 2 - 1,
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

class _HeroHeader extends StatelessWidget {
  final VoidCallback onAddPressed;

  const _HeroHeader({required this.onAddPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD62300), Color(0xFFFF6B1A)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD62300).withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Image.asset(
              'assets/logo/app_icon.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.restaurant_menu,
                color: Color(0xFFD62300),
                size: 34,
              ),
            ),
          ),
          const SizedBox(width: 22),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Menu Management',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.8,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Manage Burger King products, availability, and pricing.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          ElevatedButton.icon(
            onPressed: onAddPressed,
            icon: const Icon(Icons.add_rounded, size: 24),
            label: const Text('Add Item'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFFD62300),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              textStyle: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final int total;
  final int available;
  final int hidden;
  final int categories;

  const _SummaryRow({
    required this.total,
    required this.available,
    required this.hidden,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool compact = constraints.maxWidth < 900;
        final List<Widget> cards = [
          _SummaryCard(
            icon: Icons.fastfood_rounded,
            label: 'Total Items',
            value: total.toString(),
            iconColor: const Color(0xFFD62300),
          ),
          _SummaryCard(
            icon: Icons.visibility_rounded,
            label: 'Visible',
            value: available.toString(),
            iconColor: const Color(0xFF078C7A),
          ),
          _SummaryCard(
            icon: Icons.visibility_off_rounded,
            label: 'Hidden',
            value: hidden.toString(),
            iconColor: const Color(0xFF6E625E),
          ),
          _SummaryCard(
            icon: Icons.category_rounded,
            label: 'Categories',
            value: categories.toString(),
            iconColor: const Color(0xFFFF8A00),
          ),
        ];

        if (compact) {
          return Wrap(
            spacing: 14,
            runSpacing: 14,
            children: cards
                .map((card) => SizedBox(
                      width: (constraints.maxWidth - 14) / 2,
                      child: card,
                    ))
                .toList(),
          );
        }

        return Row(
          children: cards
              .map((card) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: card,
                    ),
                  ))
              .toList()
            ..last = Expanded(child: cards.last),
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _MenuListScreenState._bkCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFD89A)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF6E5145),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF351409),
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onSelected;

  const _CategoryChips({
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFD89A)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((category) {
            final bool isSelected = category == selectedCategory;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: ChoiceChip(
                selected: isSelected,
                label: Text(category),
                avatar: isSelected
                    ? const Icon(Icons.check_rounded, size: 18)
                    : null,
                onSelected: (_) => onSelected(category),
                selectedColor: _MenuListScreenState._bkRed,
                backgroundColor: _MenuListScreenState._bkCream,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : _MenuListScreenState._bkBrown,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: isSelected
                        ? _MenuListScreenState._bkRed
                        : _MenuListScreenState._bkBorder,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  final MenuItemModel item;
  final VoidCallback onEdit;
  final VoidCallback onToggleAvailability;
  final VoidCallback onDelete;

  const _MenuItemCard({
    required this.item,
    required this.onEdit,
    required this.onToggleAvailability,
    required this.onDelete,
  });

  bool get isAvailable => item.isAvailable;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isAvailable ? 1 : 0.72,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: isAvailable
                ? const Color(0xFFFFCD7A)
                : const Color(0xFFE3D8CE),
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 18,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Row(
          children: [
            _MenuImage(item: item),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF351409),
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _StatusPill(isAvailable: isAvailable),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      _MiniBadge(
                        icon: Icons.category_outlined,
                        label: item.category.toTitleCase(),
                      ),
                      _MiniBadge(
                        icon: Icons.sell_outlined,
                        label: '₱${item.price.toStringAsFixed(2)}',
                      ),
                    ],
                  ),
                  if (item.description.trim().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF7A6258),
                        fontSize: 15,
                        height: 1.3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 18),
            _ActionButtons(
              isAvailable: isAvailable,
              onEdit: onEdit,
              onToggleAvailability: onToggleAvailability,
              onDelete: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuImage extends StatelessWidget {
  final MenuItemModel item;

  const _MenuImage({required this.item});

  String get _imageUrl => item.imageUrl.trim();

  bool get _hasNetworkImage {
    return _imageUrl.startsWith('http://') || _imageUrl.startsWith('https://');
  }

  bool get _hasAssetImage {
    return _imageUrl.startsWith('assets/');
  }

  String get _fallbackAsset {
    final String text = '${item.name} ${item.category}'.toLowerCase();

    if (text.contains('whopper')) {
      return 'assets/products/whopper/whopper.webp';
    }
    if (text.contains('cheese') || text.contains('burger')) {
      return 'assets/products/flame_grilled_cheeseburger/flamed_grilled_cheese_burger.webp';
    }
    if (text.contains('chicken')) {
      return 'assets/products/chicken_king/chicken_king.webp';
    }
    if (text.contains('nugget')) {
      return 'assets/products/ultimate_sidekings/6pc_chicken_nuggets.webp';
    }
    if (text.contains('fries') || text.contains('side')) {
      return 'assets/products/ultimate_sidekings/thick_cut_fries.webp';
    }
    if (text.contains('drink') ||
        text.contains('coke') ||
        text.contains('tea') ||
        text.contains('float')) {
      return 'assets/products/drinks/coke_original_taste.webp';
    }
    if (text.contains('dessert') || text.contains('sundae')) {
      return 'assets/products/dessert/chocolate_sundae.webp';
    }

    return 'assets/products/placeholder.webp';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 118,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0D0),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFD89A)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: _buildImage(),
      ),
    );
  }

  Widget _buildImage() {
    if (_hasNetworkImage) {
      return Image.network(
        _imageUrl,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _fallbackImage(),
      );
    }

    if (_hasAssetImage) {
      return Image.asset(
        _imageUrl,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _fallbackImage(),
      );
    }

    return _fallbackImage();
  }

  Widget _fallbackImage() {
    return Image.asset(
      _fallbackAsset,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const Center(
        child: Icon(
          Icons.fastfood_rounded,
          color: Color(0xFFD62300),
          size: 46,
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool isAvailable;

  const _StatusPill({required this.isAvailable});

  @override
  Widget build(BuildContext context) {
    final Color color = isAvailable
        ? _MenuListScreenState._bkGreen
        : const Color(0xFF7A706C);
    final String label = isAvailable ? 'Visible' : 'Hidden';
    final IconData icon = isAvailable
        ? Icons.visibility_rounded
        : Icons.visibility_off_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MiniBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4DF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFFD62300)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF5A382D),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final bool isAvailable;
  final VoidCallback onEdit;
  final VoidCallback onToggleAvailability;
  final VoidCallback onDelete;

  const _ActionButtons({
    required this.isAvailable,
    required this.onEdit,
    required this.onToggleAvailability,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        _CircleActionButton(
          tooltip: 'Edit item',
          icon: Icons.edit_rounded,
          color: const Color(0xFFD62300),
          onPressed: onEdit,
        ),
        _CircleActionButton(
          tooltip: isAvailable ? 'Hide from customer menu' : 'Show on customer menu',
          icon: isAvailable
              ? Icons.visibility_off_rounded
              : Icons.visibility_rounded,
          color: isAvailable
              ? const Color(0xFF7A706C)
              : _MenuListScreenState._bkGreen,
          onPressed: onToggleAvailability,
        ),
        _CircleActionButton(
          tooltip: 'Delete item',
          icon: Icons.delete_rounded,
          color: const Color(0xFFFF5757),
          onPressed: onDelete,
        ),
      ],
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _CircleActionButton({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: SizedBox(
            width: 46,
            height: 46,
            child: Icon(icon, color: color, size: 23),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String selectedCategory;
  final VoidCallback onAddPressed;

  const _EmptyState({required this.selectedCategory, required this.onAddPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFFFD89A)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.no_food_rounded,
              color: Color(0xFFD62300),
              size: 54,
            ),
            const SizedBox(height: 16),
            Text(
              selectedCategory == 'All'
                  ? 'No menu items yet.'
                  : 'No items found under $selectedCategory.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF351409),
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add a product to start building your Burger King menu.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF7A6258),
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onAddPressed,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Item'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD62300),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 720,
        margin: const EdgeInsets.all(28),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFFFC86B)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFD62300),
              size: 56,
            ),
            const SizedBox(height: 16),
            const Text(
              'Menu could not load',
              style: TextStyle(
                color: Color(0xFF351409),
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF7A6258)),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD62300),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension _TitleCaseString on String {
  String toTitleCase() {
    final String clean = trim();
    if (clean.isEmpty) return clean;

    return clean
        .split(RegExp(r'\s+'))
        .map((word) {
          if (word.isEmpty) return word;
          if (word.length == 1) return word.toUpperCase();
          return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
        })
        .join(' ');
  }
}
