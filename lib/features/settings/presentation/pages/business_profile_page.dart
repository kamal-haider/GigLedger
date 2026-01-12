import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/settings_providers.dart';
import '../widgets/currency_selector.dart';
import '../widgets/logo_upload_widget.dart';

/// Business profile settings page
class BusinessProfilePage extends ConsumerStatefulWidget {
  const BusinessProfilePage({super.key});

  @override
  ConsumerState<BusinessProfilePage> createState() => _BusinessProfilePageState();
}

class _BusinessProfilePageState extends ConsumerState<BusinessProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _businessNameController;
  late TextEditingController _businessAddressController;
  late TextEditingController _taxRateController;
  late TextEditingController _paymentInstructionsController;
  String _selectedCurrency = 'USD';
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _businessNameController = TextEditingController();
    _businessAddressController = TextEditingController();
    _taxRateController = TextEditingController();
    _paymentInstructionsController = TextEditingController();
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _businessAddressController.dispose();
    _taxRateController.dispose();
    _paymentInstructionsController.dispose();
    super.dispose();
  }

  void _initializeFromProfile() {
    final profile = ref.read(businessProfileProvider);
    if (profile != null) {
      _businessNameController.text = profile.businessName ?? '';
      _businessAddressController.text = profile.businessAddress ?? '';
      _taxRateController.text = profile.taxRate.toString();
      _paymentInstructionsController.text = profile.paymentInstructions ?? '';
      _selectedCurrency = profile.currency;
    }
  }

  void _markChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(businessProfileNotifierProvider.notifier);
    final taxRate = double.tryParse(_taxRateController.text) ?? 0.0;

    await notifier.updateFullProfile(
      businessName: _businessNameController.text.trim(),
      businessAddress: _businessAddressController.text.trim(),
      currency: _selectedCurrency,
      taxRate: taxRate,
      paymentInstructions: _paymentInstructionsController.text.trim(),
    );

    setState(() => _hasChanges = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleLogoUpload() async {
    // TODO: Implement image picker and Firebase Storage upload
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logo upload coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleLogoRemove() async {
    final notifier = ref.read(businessProfileNotifierProvider.notifier);
    await notifier.updateBusinessLogo('');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = ref.watch(businessProfileProvider);
    final updateState = ref.watch(businessProfileNotifierProvider);

    // Initialize form fields on first build
    if (profile != null && _businessNameController.text.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeFromProfile();
        setState(() {});
      });
    }

    final isLoading = updateState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Profile'),
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: isLoading ? null : _saveChanges,
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
        ],
      ),
      body: profile == null
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              onChanged: _markChanged,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Logo upload section
                  LogoUploadWidget(
                    logoUrl: profile.businessLogo,
                    isLoading: isLoading,
                    onUploadPressed: _handleLogoUpload,
                    onRemovePressed: _handleLogoRemove,
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),

                  // Business Name
                  TextFormField(
                    controller: _businessNameController,
                    decoration: InputDecoration(
                      labelText: 'Business Name',
                      hintText: 'Enter your business name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.business),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your business name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Business Address
                  TextFormField(
                    controller: _businessAddressController,
                    decoration: InputDecoration(
                      labelText: 'Business Address',
                      hintText: 'Enter your business address',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.location_on),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),

                  // Currency selector
                  CurrencySelector(
                    selectedCurrency: _selectedCurrency,
                    currencies: supportedCurrencies,
                    onChanged: (currency) {
                      setState(() {
                        _selectedCurrency = currency;
                        _hasChanges = true;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Tax Rate
                  TextFormField(
                    controller: _taxRateController,
                    decoration: InputDecoration(
                      labelText: 'Default Tax Rate (%)',
                      hintText: '0.0',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.percent),
                      suffixText: '%',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) return null;
                      final rate = double.tryParse(value);
                      if (rate == null || rate < 0 || rate > 100) {
                        return 'Enter a valid percentage (0-100)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),

                  // Payment Instructions
                  Text(
                    'Payment Instructions',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _paymentInstructionsController,
                    decoration: InputDecoration(
                      hintText:
                          'Enter payment instructions to display on invoices\n'
                          'e.g., Bank details, PayPal email, etc.',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLines: 5,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'These instructions will appear on all your invoices',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Save button at bottom
                  if (_hasChanges)
                    FilledButton(
                      onPressed: isLoading ? null : _saveChanges,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Save Changes'),
                      ),
                    ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}
