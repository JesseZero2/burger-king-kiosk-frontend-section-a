import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/menu/menu_item_model.dart';
import '../../features/menu/menu_item_service.dart';

class AddEditMenuItemScreen extends StatefulWidget {
  final MenuItemModel? menuItem;

  const AddEditMenuItemScreen({super.key, this.menuItem});

  @override
  State<AddEditMenuItemScreen> createState() => _AddEditMenuItemScreenState();
}

class _AddEditMenuItemScreenState extends State<AddEditMenuItemScreen> {
  static const Color _bkRed = Color(0xFFD62300);
  static const Color _bkOrange = Color(0xFFFF5A1F);
  static const Color _bkYellow = Color(0xFFFFC72C);
  static const Color _bkCream = Color(0xFFFFF3D6);
  static const Color _bkBrown = Color(0xFF3A1608);
  static const Color _bkSoftBrown = Color(0xFF6B2B12);
  static const String _fallbackLogo = 'assets/logo/app_icon.png';

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _service = MenuItemService();

  // ── 1. Updated category IDs to match Supabase normalized slugs ──────────────
  final List<String> _categories = const [
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

  String _category = 'whopper';
  bool _isAvailable = true;
  bool _isSaving = false;

  bool get _isEditing => widget.menuItem != null;

  @override
  void initState() {
    super.initState();

    final item = widget.menuItem;
    if (item == null) return;

    _nameController.text = item.name;
    _descriptionController.text = item.description;
    _priceController.text = item.price.toStringAsFixed(2);
    _imageUrlController.text = item.imageUrl;
    _category = _safeCategory(item.category);
    _isAvailable = item.isAvailable;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  // ── 2. Updated _safeCategory to map to new normalized IDs ───────────────────
  String _safeCategory(String value) {
    final normalized = value.trim().toLowerCase();

    // Exact match first
    if (_categories.contains(normalized)) return normalized;

    // Keyword-based fallback mapping
    if (normalized.contains('breakfast'))        return 'all_day_breakfast';
    if (normalized.contains('cafe') ||
        normalized.contains('café') ||
        normalized.contains('coffee'))           return 'bk_cafe';
    if (normalized.contains('rice'))             return 'chicken_rice_meals';
    if (normalized.contains('chicken'))          return 'chicken_king';
    if (normalized.contains('dessert'))          return 'dessert';
    if (normalized.contains('drink') ||
        normalized.contains('beverage'))         return 'drinks';
    if (normalized.contains('featured') ||
        normalized.contains('special') ||
        normalized.contains('promo'))            return 'featured';
    if (normalized.contains('flame') ||
        normalized.contains('grilled') ||
        normalized.contains('cheeseburger'))     return 'flame_grilled_cheeseburger';
    if (normalized.contains('group') ||
        normalized.contains('bundle') ||
        normalized.contains('family'))           return 'group_meals';
    if (normalized.contains('saver') ||
        normalized.contains('value'))            return 'king_savers_bundles';
    if (normalized.contains('king_special') ||
        normalized.contains('king special'))     return 'king_specials';
    if (normalized.contains('plant') ||
        normalized.contains('vegan') ||
        normalized.contains('veggie'))           return 'plant_based_whopper';
    if (normalized.contains('sidek') ||
        normalized.contains('side'))             return 'ultimate_sidekings';
    if (normalized.contains('xtra') ||
        normalized.contains('long') ||
        normalized.contains('extra'))            return 'xtra_long_chicken';
    if (normalized.contains('burger') ||
        normalized.contains('whopper'))          return 'whopper';
    if (normalized.contains('meal'))             return 'group_meals';

    // Final fallback
    return 'whopper';
  }

  // ── 3. Updated _categoryLabel with human-readable display names ─────────────
  String _categoryLabel(String value) {
    switch (value) {
      case 'all_day_breakfast':         return 'All Day Breakfast';
      case 'bk_cafe':                   return 'BK Café';
      case 'chicken_king':              return 'Chicken King';
      case 'chicken_rice_meals':        return 'Chicken Rice Meals';
      case 'dessert':                   return 'Dessert';
      case 'drinks':                    return 'Drinks';
      case 'featured':                  return 'Featured';
      case 'flame_grilled_cheeseburger':return 'Flame Grilled Cheeseburger';
      case 'group_meals':               return 'Group Meals';
      case 'king_savers_bundles':       return 'King Savers Bundles';
      case 'king_specials':             return 'King Specials';
      case 'plant_based_whopper':       return 'Plant Based Whopper';
      case 'ultimate_sidekings':        return 'Ultimate Sidekings';
      case 'whopper':                   return 'Whopper';
      case 'xtra_long_chicken':         return 'Xtra Long Chicken';
      default:
        return value.isEmpty ? 'Category' : value;
    }
  }

  // ── 4. Updated _categoryIcon with sensible icons for new categories ──────────
  IconData _categoryIcon(String value) {
    switch (value) {
      case 'all_day_breakfast':         return Icons.free_breakfast_rounded;
      case 'bk_cafe':                   return Icons.local_cafe_rounded;
      case 'chicken_king':              return Icons.set_meal_rounded;
      case 'chicken_rice_meals':        return Icons.rice_bowl_rounded;
      case 'dessert':                   return Icons.icecream_rounded;
      case 'drinks':                    return Icons.local_drink_rounded;
      case 'featured':                  return Icons.star_rounded;
      case 'flame_grilled_cheeseburger':return Icons.outdoor_grill_rounded;
      case 'group_meals':               return Icons.groups_rounded;
      case 'king_savers_bundles':       return Icons.savings_rounded;
      case 'king_specials':             return Icons.workspace_premium_rounded;
      case 'plant_based_whopper':       return Icons.eco_rounded;
      case 'ultimate_sidekings':        return Icons.fastfood_rounded;
      case 'whopper':                   return Icons.lunch_dining_rounded;
      case 'xtra_long_chicken':         return Icons.kebab_dining_rounded;
      default:                          return Icons.restaurant_menu_rounded;
    }
  }

  void _goBack({bool saved = false}) {
    if (context.canPop()) {
      context.pop(saved);
      return;
    }

    context.go('/admin/menu');
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isSaving = true;
    });

    try {
      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim();
      final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
      final imageUrl = _imageUrlController.text.trim();

      if (widget.menuItem == null) {
        await _service.createMenuItem(
          name: name,
          category: _category,
          price: price,
          description: description,
          isAvailable: _isAvailable,
          imageUrl: imageUrl.isEmpty ? null : imageUrl,
        );
      } else {
        await _service.updateMenuItem(
          id: widget.menuItem!.id,
          name: name,
          category: _category,
          price: price,
          description: description,
          isAvailable: _isAvailable,
          imageUrl: imageUrl.isEmpty ? null : imageUrl,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Menu item updated.' : 'Menu item added.'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      _goBack(saved: true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Save failed: $error'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _bkRed,
        ),
      );

      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bkCream,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 28, 28, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeroHeader(),
            const SizedBox(height: 22),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 1050;

                if (!isWide) {
                  return Column(
                    children: [
                      _buildFormCard(),
                      const SizedBox(height: 18),
                      _buildPreviewCard(),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 7,
                      child: _buildFormCard(),
                    ),
                    const SizedBox(width: 22),
                    Expanded(
                      flex: 4,
                      child: _buildPreviewCard(),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_bkRed, _bkOrange],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x333A1608),
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: _isSaving ? null : () => _goBack(),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: _bkRed,
                size: 30,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditing ? 'Edit Menu Item' : 'Add Menu Item',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _isEditing
                      ? 'Update product details, price, category, image, and availability.'
                      : 'Create a new Burger King product for the kiosk menu.',
                  style: TextStyle(
                    color: Colors.white.withAlpha(235),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: _isSaving ? null : () => _goBack(),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white, width: 1.4),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            icon: const Icon(Icons.restaurant_menu_rounded),
            label: const Text(
              'Back to Menu',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _bkYellow.withAlpha(120)),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A3A1608),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionTitle(
              icon: Icons.edit_note_rounded,
              title: 'Product Information',
              subtitle: 'Keep the name, price, and description clean for customers.',
            ),
            const SizedBox(height: 22),
            _buildTextField(
              controller: _nameController,
              label: 'Product Name',
              hint: 'Example: Whopper with Cheese',
              icon: Icons.lunch_dining_rounded,
              validator: (value) {
                if ((value ?? '').trim().isEmpty) {
                  return 'Product name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            _buildCategorySelector(),
            const SizedBox(height: 18),
            _buildTextField(
              controller: _priceController,
              label: 'Price',
              hint: 'Example: 199.00',
              icon: Icons.payments_rounded,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                final price = double.tryParse((value ?? '').trim());
                if (price == null || price <= 0) {
                  return 'Enter a valid price';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            _buildTextField(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Short product description',
              icon: Icons.notes_rounded,
              maxLines: 4,
              validator: (value) {
                if ((value ?? '').trim().isEmpty) {
                  return 'Description is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            _buildTextField(
              controller: _imageUrlController,
              label: 'Image URL',
              hint: 'Paste image URL from backend/storage',
              icon: Icons.image_rounded,
            ),
            const SizedBox(height: 22),
            _buildAvailabilitySwitch(),
            const SizedBox(height: 26),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isSaving ? null : () => _goBack(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _bkBrown,
                      side: const BorderSide(color: _bkYellow, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _bkRed,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: _bkRed.withAlpha(120),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    icon: _isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save_rounded),
                    label: Text(
                      _isSaving
                          ? 'Saving...'
                          : _isEditing
                              ? 'Update Item'
                              : 'Create Item',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _bkBrown,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _bkSoftBrown),
        boxShadow: const [
          BoxShadow(
            color: Color(0x263A1608),
            blurRadius: 20,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionTitle(
            icon: Icons.visibility_rounded,
            title: 'Live Preview',
            subtitle: 'This is how the item will feel in admin view.',
            dark: true,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _imageUrlController,
                  builder: (context, value, _) {
                    return _buildImagePreview(value.text.trim());
                  },
                ),
                const SizedBox(height: 18),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _nameController,
                  builder: (context, value, _) {
                    return Text(
                      value.text.trim().isEmpty
                          ? 'Product Name'
                          : value.text.trim(),
                      style: const TextStyle(
                        color: _bkBrown,
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    StatefulBuilder(
                      builder: (context, setInnerState) {
                        return _buildMiniPill(
                          icon: _categoryIcon(_category),
                          text: _categoryLabel(_category),
                          color: _bkRed,
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildMiniPill(
                      icon: _isAvailable
                          ? Icons.check_circle_rounded
                          : Icons.visibility_off_rounded,
                      text: _isAvailable ? 'Visible' : 'Hidden',
                      color: _isAvailable ? const Color(0xFF00897B) : Colors.grey,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _priceController,
                  builder: (context, value, _) {
                    final price = double.tryParse(value.text.trim()) ?? 0;
                    return Text(
                      price <= 0
                          ? '₱0.00'
                          : '₱${price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: _bkRed,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _descriptionController,
                  builder: (context, value, _) {
                    return Text(
                      value.text.trim().isEmpty
                          ? 'Product description will appear here.'
                          : value.text.trim(),
                      style: const TextStyle(
                        color: Color(0xFF7A6258),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0x33FFFFFF),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0x33FFFFFF)),
            ),
            child: const Text(
              'Note: Hidden items are saved in admin, but customers should not see them in the kiosk menu.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
    required String subtitle,
    bool dark = false,
  }) {
    final iconBackground = dark ? const Color(0x22FFFFFF) : _bkCream;
    final iconColor = dark ? _bkYellow : _bkRed;
    final titleColor = dark ? Colors.white : _bkBrown;
    final subtitleColor = dark ? Colors.white.withAlpha(210) : const Color(0xFF7A6258);

    return Row(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: iconBackground,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(icon, color: iconColor, size: 28),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: titleColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: subtitleColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
        color: _bkBrown,
        fontSize: 17,
        fontWeight: FontWeight.w800,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: _bkRed),
        filled: true,
        fillColor: const Color(0xFFFFFBF2),
        labelStyle: const TextStyle(
          color: Color(0xFF7A6258),
          fontWeight: FontWeight.w800,
        ),
        hintStyle: const TextStyle(
          color: Color(0xFFB8A79C),
          fontWeight: FontWeight.w600,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _bkYellow.withAlpha(140)),
          borderRadius: BorderRadius.circular(18),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: _bkRed, width: 2),
          borderRadius: BorderRadius.circular(18),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: _bkRed, width: 1.5),
          borderRadius: BorderRadius.circular(18),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: _bkRed, width: 2),
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(
            color: _bkBrown,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _categories.map((category) {
            final selected = _category == category;

            return ChoiceChip(
              selected: selected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _categoryIcon(category),
                    size: 20,
                    color: selected ? Colors.white : _bkRed,
                  ),
                  const SizedBox(width: 8),
                  Text(_categoryLabel(category)),
                ],
              ),
              labelStyle: TextStyle(
                color: selected ? Colors.white : _bkBrown,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
              selectedColor: _bkRed,
              backgroundColor: _bkCream,
              side: BorderSide(
                color: selected ? _bkRed : _bkYellow.withAlpha(180),
                width: 1.4,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              onSelected: _isSaving
                  ? null
                  : (_) {
                      setState(() {
                        _category = category;
                      });
                    },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAvailabilitySwitch() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _isAvailable
            ? const Color(0xFFE0F2F1)
            : const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isAvailable ? const Color(0xFF80CBC4) : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isAvailable
                ? Icons.visibility_rounded
                : Icons.visibility_off_rounded,
            color: _isAvailable ? const Color(0xFF00897B) : Colors.grey,
            size: 30,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isAvailable ? 'Visible to Customers' : 'Hidden from Customers',
                  style: TextStyle(
                    color: _isAvailable ? const Color(0xFF00695C) : Colors.grey,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isAvailable
                      ? 'This item can appear in the kiosk menu.'
                      : 'This item stays in admin only until enabled.',
                  style: TextStyle(
                    color: _isAvailable ? const Color(0xFF00796B) : Colors.grey,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isAvailable,
            activeThumbColor: _bkRed,
            activeTrackColor: _bkYellow,
            onChanged: _isSaving
                ? null
                : (value) {
                    setState(() {
                      _isAvailable = value;
                    });
                  },
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(String imageUrl) {
    return AspectRatio(
      aspectRatio: 16 / 10,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Container(
          color: _bkCream,
          child: imageUrl.isEmpty
              ? _buildFallbackImage()
              : Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildFallbackImage();
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;

                    return Center(
                      child: CircularProgressIndicator(
                        color: _bkRed,
                        value: loadingProgress.expectedTotalBytes == null
                            ? null
                            : loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!,
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildFallbackImage() {
    return Center(
      child: Image.asset(
        _fallbackLogo,
        width: 110,
        height: 110,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(
            Icons.lunch_dining_rounded,
            color: _bkRed,
            size: 88,
          );
        },
      ),
    );
  }

  Widget _buildMiniPill({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}