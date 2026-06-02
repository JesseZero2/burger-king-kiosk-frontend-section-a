import 'package:flutter/material.dart';

import '../../services/api_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const Color _bkRed = Color(0xFFD62300);
  static const Color _bkOrange = Color(0xFFFF6A1A);
  static const Color _bkBrown = Color(0xFF3D1608);
  static const Color _bkCream = Color(0xFFFFF1CC);
  static const Color _bkSoftCream = Color(0xFFFFF8EA);
  static const Color _bkYellow = Color(0xFFFFC72C);
  static const Color _bkBorder = Color(0xFFFFD89A);
  static const Color _bkMuted = Color(0xFF765A49);

  final _formKey = GlobalKey<FormState>();
  final _storeNameController = TextEditingController();
  final _operatingHoursController = TextEditingController();
  final _taxRateController = TextEditingController();
  final Set<String> _paymentMethods = <String>{};

  late Future<void> _settingsFuture;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _settingsFuture = _loadSettings();
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _operatingHoursController.dispose();
    _taxRateController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final data = await ApiService.getSettings();

    _storeNameController.text = data['store_name']?.toString() ?? '';
    _operatingHoursController.text = data['operating_hours']?.toString() ?? '';
    _taxRateController.text = data['tax_rate']?.toString() ?? '';

    final methods = (data['payment_methods'] as List<dynamic>?)
            ?.map((item) => item.toString().toLowerCase())
            .toSet() ??
        <String>{};

    _paymentMethods
      ..clear()
      ..addAll(methods);
  }

  void _reloadSettings() {
    setState(() {
      _settingsFuture = _loadSettings();
    });
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isSaving = true;
    });

    final messenger = ScaffoldMessenger.of(context);

    try {
      await ApiService.updateSettings({
        'store_name': _storeNameController.text.trim(),
        'operating_hours': _operatingHoursController.text.trim(),
        'tax_rate': double.tryParse(_taxRateController.text.trim()) ?? 0.0,
        'payment_methods': _paymentMethods.toList(),
      });

      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Settings saved successfully')),
      );
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to save settings: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _settingsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _buildLoadingState();
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(36, 36, 36, 46),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildSettingsForm(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: _bkRed),
    );
  }

  Widget _buildErrorState(Object? error) {
    return Center(
      child: Container(
        width: 560,
        padding: const EdgeInsets.all(30),
        decoration: _cardDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: _bkRed, size: 54),
            const SizedBox(height: 16),
            const Text(
              'Settings could not load',
              style: TextStyle(
                color: _bkBrown,
                fontSize: 30,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _bkMuted,
                fontSize: 16,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _reloadSettings,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: FilledButton.styleFrom(
                backgroundColor: _bkRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(34),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_bkRed, _bkOrange],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(214, 35, 0, 0.20),
            blurRadius: 28,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
            ),
            child: const Icon(Icons.settings_rounded, color: _bkRed, size: 46),
          ),
          const SizedBox(width: 24),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings Center',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.8,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Control store setup, payment options, tax rate, and checkout preferences.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          OutlinedButton.icon(
            onPressed: _reloadSettings,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reload'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _bkBrown,
              backgroundColor: Colors.white,
              side: const BorderSide(color: Colors.white),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsForm() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: _cardDecoration(),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(
              icon: Icons.storefront_rounded,
              title: 'Store Setup',
              subtitle: 'Update the store details used by the admin dashboard.',
            ),
            const SizedBox(height: 26),
            TextFormField(
              controller: _storeNameController,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              decoration: _inputDecoration(
                label: 'Store Name',
                hint: 'Burger King Kiosk',
                icon: Icons.store_mall_directory_rounded,
              ),
              validator: (value) {
                return (value ?? '').trim().isEmpty ? 'Store name is required' : null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _operatingHoursController,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              decoration: _inputDecoration(
                label: 'Operating Hours',
                hint: 'Example: 9:00 AM - 10:00 PM',
                icon: Icons.schedule_rounded,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _taxRateController,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              decoration: _inputDecoration(
                label: 'Tax Rate',
                hint: 'Example: 12',
                icon: Icons.percent_rounded,
                suffixText: '%',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                final text = (value ?? '').trim();
                if (text.isEmpty) return null;
                final number = double.tryParse(text);
                if (number == null) return 'Enter a valid number';
                if (number < 0) return 'Tax rate cannot be negative';
                return null;
              },
            ),
            const SizedBox(height: 30),
            _sectionTitle(
              icon: Icons.payments_rounded,
              title: 'Payment Methods',
              subtitle: 'Select the payment types available on checkout.',
              compact: true,
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: ['cash', 'card', 'gcash', 'maya'].map(_paymentMethodCard).toList(),
            ),
            const SizedBox(height: 34),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _saveSettings,
                icon: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.6,
                        ),
                      )
                    : const Icon(Icons.save_rounded),
                label: Text(_isSaving ? 'Saving Settings...' : 'Save Settings'),
                style: FilledButton.styleFrom(
                  backgroundColor: _bkRed,
                  disabledBackgroundColor: const Color.fromRGBO(214, 35, 0, 0.45),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                  textStyle: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle({
    required IconData icon,
    required String title,
    required String subtitle,
    bool compact = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: compact ? 58 : 66,
          height: compact ? 58 : 66,
          decoration: BoxDecoration(
            color: const Color.fromRGBO(214, 35, 0, 0.10),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: _bkRed, size: compact ? 30 : 34),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: _bkBrown,
                  fontSize: compact ? 25 : 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(
                  color: _bkMuted,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    String? suffixText,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixText: suffixText,
      prefixIcon: Icon(icon, color: _bkRed, size: 28),
      filled: true,
      fillColor: _bkSoftCream,
      labelStyle: const TextStyle(
        color: _bkBrown,
        fontSize: 18,
        fontWeight: FontWeight.w900,
      ),
      hintStyle: const TextStyle(
        color: _bkMuted,
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
      suffixStyle: const TextStyle(
        color: _bkBrown,
        fontSize: 20,
        fontWeight: FontWeight.w900,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: _bkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: _bkRed, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: _bkRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: _bkRed, width: 1.8),
      ),
    );
  }

  Widget _paymentMethodCard(String method) {
    final isSelected = _paymentMethods.contains(method);

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        setState(() {
          if (isSelected) {
            _paymentMethods.remove(method);
          } else {
            _paymentMethods.add(method);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? _bkCream : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? _bkYellow : _bkBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color.fromRGBO(214, 35, 0, 0.10),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_methodIcon(method), color: isSelected ? _bkRed : _bkMuted, size: 28),
            const SizedBox(width: 12),
            Text(
              _methodLabel(method),
              style: TextStyle(
                color: isSelected ? _bkRed : _bkBrown,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 12),
              const Icon(Icons.check_circle_rounded, color: _bkRed, size: 22),
            ],
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration({Color backgroundColor = Colors.white}) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: _bkBorder),
      boxShadow: const [
        BoxShadow(
          color: Color.fromRGBO(61, 22, 8, 0.07),
          blurRadius: 24,
          offset: Offset(0, 12),
        ),
      ],
    );
  }

  IconData _methodIcon(String method) {
    switch (method) {
      case 'cash':
        return Icons.payments_rounded;
      case 'card':
        return Icons.credit_card_rounded;
      case 'gcash':
        return Icons.account_balance_wallet_rounded;
      case 'maya':
        return Icons.phone_android_rounded;
      default:
        return Icons.payment_rounded;
    }
  }

  String _methodLabel(String method) {
    switch (method) {
      case 'cash':
        return 'Cash';
      case 'card':
        return 'Card';
      case 'gcash':
        return 'GCash';
      case 'maya':
        return 'Maya';
      default:
        return method.toUpperCase();
    }
  }
}
