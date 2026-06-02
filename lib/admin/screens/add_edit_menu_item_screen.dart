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
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  String _category = 'burgers';
  bool _isAvailable = true;
  final _categories = const ['burgers', 'chicken', 'sides', 'drinks', 'desserts'];
  final _service = MenuItemService();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final item = widget.menuItem;
    if (item != null) {
      _nameController.text = item.name;
      _descriptionController.text = item.description;
      _priceController.text = item.price.toStringAsFixed(2);
      _imageUrlController.text = item.imageUrl;
      _category = item.category;
      _isAvailable = item.isAvailable;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim();
      final price = double.tryParse(_priceController.text) ?? 0.0;
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
      if (mounted) {
        context.go('/admin/menu');
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $error')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.menuItem != null;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(isEditing ? 'Edit Menu Item' : 'Add Menu Item', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                  validator: (value) => (value ?? '').trim().isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                  items: _categories.map((category) => DropdownMenuItem(value: category, child: Text(category.capitalize()))).toList(),
                  onChanged: (value) => setState(() => _category = value ?? _category),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Price', border: OutlineInputBorder()),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    final price = double.tryParse(value ?? '');
                    return price == null || price <= 0 ? 'Enter a valid price' : null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(labelText: 'Image URL', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Available'),
                  value: _isAvailable,
                  activeThumbColor: const Color(0xFFD62300),
                  onChanged: (value) => setState(() => _isAvailable = value),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isSaving ? null : _saveItem,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD62300), padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: Text(_isSaving ? 'Saving...' : isEditing ? 'Update Item' : 'Create Item'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension on String {
  String capitalize() => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
