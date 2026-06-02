import 'package:flutter/material.dart';
import '../../features/menu/menu_item_model.dart';
import '../../features/menu/menu_item_service.dart';
import 'package:go_router/go_router.dart';

class MenuListScreen extends StatefulWidget {
  const MenuListScreen({super.key});

  @override
  State<MenuListScreen> createState() => _MenuListScreenState();
}

class _MenuListScreenState extends State<MenuListScreen> {
  final _service = MenuItemService();
  late Future<List<MenuItemModel>> _menuFuture;
  String _selectedCategory = '';
  final _categories = const [
    'burgers',
    'chicken',
    'sides',
    'drinks',
    'desserts'
  ];

  @override
  void initState() {
    super.initState();
    _menuFuture = _loadMenuItems();
  }

  Future<List<MenuItemModel>> _loadMenuItems() {
    return _service.getMenuItems(
      category: _selectedCategory.isEmpty ? null : _selectedCategory,
    );
  }

  void _refresh() {
    setState(() {
      _menuFuture = _loadMenuItems();
    });
  }

  Future<void> _toggleAvailability(MenuItemModel item) async {
    await _service.toggleAvailability(item.id, !item.isAvailable);
    _refresh();
  }

  Future<void> _delete(MenuItemModel item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Menu Item'),
        content: Text('Are you sure you want to delete ${item.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _service.deleteMenuItem(item.id);
      _refresh();
    }
  }

  Color _statusColor(bool available) {
    return available ? const Color(0xFF1B8F3A) : Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F5F0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Menu Management',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2B1B16),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => context.go('/admin/menu/add'),
                icon: const Icon(Icons.add),
                label: const Text('Add Item'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD62300),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          DropdownButtonFormField<String>(
            initialValue: _selectedCategory.isEmpty ? null : _selectedCategory,
            decoration: InputDecoration(
              labelText: 'Category Filter',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            items: [
              const DropdownMenuItem(value: '', child: Text('All Categories')),
              ..._categories.map(
                (category) => DropdownMenuItem(
                  value: category,
                  child: Text(category.capitalize()),
                ),
              ),
            ],
            onChanged: (value) {
              _selectedCategory = value ?? '';
              _refresh();
            },
          ),
          const SizedBox(height: 18),
          Expanded(
            child: FutureBuilder<List<MenuItemModel>>(
              future: _menuFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFD62300),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                final items = snapshot.data ?? [];

                if (items.isEmpty) {
                  return const Center(
                    child: Text(
                      'No menu items found.',
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final item = items[index];

                    return Opacity(
                      opacity: item.isAvailable ? 1 : 0.55,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: const Color(0xFFFFE2B8),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            _MenuImage(imageUrl: item.imageUrl),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2B1B16),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${item.category.capitalize()} • ₱${item.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  if (item.description.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      item.description,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black45,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: _statusColor(item.isAvailable)
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Text(
                                item.isAvailable ? 'Available' : 'Hidden',
                                style: TextStyle(
                                  color: _statusColor(item.isAvailable),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            IconButton(
                              tooltip: 'Edit',
                              icon: const Icon(
                                Icons.edit,
                                color: Color(0xFFD62300),
                              ),
                              onPressed: () => context.go(
                                '/admin/menu/edit/${item.id}',
                                extra: item,
                              ),
                            ),
                            IconButton(
                              tooltip: item.isAvailable ? 'Hide' : 'Show',
                              icon: Icon(
                                item.isAvailable
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: item.isAvailable
                                    ? const Color(0xFF1B8F3A)
                                    : Colors.grey,
                              ),
                              onPressed: () => _toggleAvailability(item),
                            ),
                            IconButton(
                              tooltip: 'Delete',
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                              ),
                              onPressed: () => _delete(item),
                            ),
                          ],
                        ),
                      ),
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
}

class _MenuImage extends StatelessWidget {
  final String imageUrl;

  const _MenuImage({required this.imageUrl});

  bool get hasRealImage {
    return imageUrl.isNotEmpty && !imageUrl.contains('example.com');
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 130,
        height: 92,
        color: const Color(0xFFFFF3D6),
        child: hasRealImage
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const _ImagePlaceholder(),
              )
            : const _ImagePlaceholder(),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.fastfood,
        size: 42,
        color: Color(0xFFD62300),
      ),
    );
  }
}

extension on String {
  String capitalize() {
    return isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
  }
}
