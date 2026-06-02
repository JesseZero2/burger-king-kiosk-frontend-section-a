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
  final _categories = const ['burgers', 'chicken', 'sides', 'drinks', 'desserts'];

  @override
  void initState() {
    super.initState();
    _menuFuture = _loadMenuItems();
  }

  Future<List<MenuItemModel>> _loadMenuItems() {
    return _service.getMenuItems(category: _selectedCategory.isEmpty ? null : _selectedCategory);
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
        title: const Text('Delete menu item'),
        content: Text('Delete ${item.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) {
      await _service.deleteMenuItem(item.id);
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Menu Management', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _selectedCategory.isEmpty ? null : _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category filter', border: OutlineInputBorder()),
                items: [
                  const DropdownMenuItem(value: '', child: Text('All')),
                  ..._categories.map((category) => DropdownMenuItem(value: category, child: Text(category.capitalize()))),
                ],
                onChanged: (value) {
                  _selectedCategory = value ?? '';
                  _refresh();
                },
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () => context.go('/admin/menu/add'),
              icon: const Icon(Icons.add),
              label: const Text('Add Item'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD62300)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: FutureBuilder<List<MenuItemModel>>(
            future: _menuFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final items = snapshot.data ?? [];
              if (items.isEmpty) {
                return const Center(child: Text('No menu items found.'));
              }
              return ListView.separated(
                itemCount: items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    child: ListTile(
                      leading: item.imageUrl.isNotEmpty ? Image.network(item.imageUrl, width: 60, height: 60, fit: BoxFit.cover) : const SizedBox(width: 60, child: Icon(Icons.fastfood)),
                      title: Text(item.name),
                      subtitle: Text('${item.category} · ₱${item.price.toStringAsFixed(2)}'),
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Color(0xFFD62300)),
                            onPressed: () => context.go('/admin/menu/edit/${item.id}', extra: item),
                          ),
                          IconButton(
                            icon: Icon(item.isAvailable ? Icons.visibility : Icons.visibility_off, color: item.isAvailable ? Colors.green : Colors.grey),
                            onPressed: () => _toggleAvailability(item),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
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
    );
  }
}

extension on String {
  String capitalize() => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
