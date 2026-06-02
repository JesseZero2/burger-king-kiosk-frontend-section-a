import 'package:flutter/material.dart';

import '../../services/api_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storeNameController = TextEditingController();
  final _operatingHoursController = TextEditingController();
  final _taxRateController = TextEditingController();
  final _paymentMethods = <String>{};
  late Future<void> _settingsFuture;

  @override
  void initState() {
    super.initState();
    _settingsFuture = _loadSettings();
  }

  Future<void> _loadSettings() async {
    final data = await ApiService.getSettings();
    _storeNameController.text = data['store_name'] ?? '';
    _operatingHoursController.text = data['operating_hours'] ?? '';
    _taxRateController.text = data['tax_rate']?.toString() ?? '';
    final methods = (data['payment_methods'] as List<dynamic>?)?.map((e) => e.toString()).toSet() ?? {};
    _paymentMethods.clear();
    _paymentMethods.addAll(methods);
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;
    final messenger = ScaffoldMessenger.of(context);
    await ApiService.updateSettings({
      'store_name': _storeNameController.text.trim(),
      'operating_hours': _operatingHoursController.text.trim(),
      'tax_rate': double.tryParse(_taxRateController.text) ?? 0.0,
      'payment_methods': _paymentMethods.toList(),
    });
    if (mounted) {
      messenger.showSnackBar(const SnackBar(content: Text('Settings saved')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _settingsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Settings', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _storeNameController,
                      decoration: const InputDecoration(labelText: 'Store Name', border: OutlineInputBorder()),
                      validator: (value) => (value ?? '').trim().isEmpty ? 'Store name is required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _operatingHoursController,
                      decoration: const InputDecoration(labelText: 'Operating Hours', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _taxRateController,
                      decoration: const InputDecoration(labelText: 'Tax Rate', border: OutlineInputBorder()),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 16),
                    const Text('Payment Methods', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ['cash', 'gcash', 'maya', 'card'].map((method) {
                        final isSelected = _paymentMethods.contains(method);
                        return FilterChip(
                          label: Text(method.toUpperCase()),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _paymentMethods.add(method);
                              } else {
                                _paymentMethods.remove(method);
                              }
                            });
                          },
                          selectedColor: const Color.fromARGB(61, 245, 166, 35),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveSettings,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD62300), padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: const Text('Save Settings'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
