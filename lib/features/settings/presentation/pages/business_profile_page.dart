import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../auth/application/providers/auth_providers.dart';
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
  bool _isInitialized = false;
  bool _isUploadingLogo = false;
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _businessNameController = TextEditingController();
    _businessAddressController = TextEditingController();
    _taxRateController = TextEditingController();
    _paymentInstructionsController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize form fields once when profile data is available
    if (!_isInitialized) {
      final profile = ref.read(businessProfileProvider);
      if (profile != null) {
        _initializeFromProfile();
        _isInitialized = true;
      }
    }
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

  /// Convert empty/whitespace-only strings to null for proper storage
  String? _trimOrNull(String text) {
    final trimmed = text.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(businessProfileNotifierProvider.notifier);
    final taxRate = double.tryParse(_taxRateController.text) ?? 0.0;

    try {
      await notifier.updateFullProfile(
        businessName: _trimOrNull(_businessNameController.text),
        businessAddress: _trimOrNull(_businessAddressController.text),
        currency: _selectedCurrency,
        taxRate: taxRate,
        paymentInstructions: _trimOrNull(_paymentInstructionsController.text),
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getErrorMessage(e)),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  /// Returns a user-friendly error message based on error type
  String _getErrorMessage(Object error) {
    final errorStr = error.toString().toLowerCase();
    if (errorStr.contains('network') || errorStr.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    }
    if (errorStr.contains('permission') || errorStr.contains('denied')) {
      return 'Permission denied. Please sign in again.';
    }
    if (errorStr.contains('auth')) {
      return 'Authentication error. Please sign in again.';
    }
    return 'Failed to save profile. Please try again.';
  }

  Future<void> _handleLogoUpload() async {
    // Show image source selection dialog
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      // Check file size (max 2MB)
      final file = File(pickedFile.path);
      final fileSize = await file.length();
      if (fileSize > 2 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image too large. Please choose an image under 2MB.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      setState(() {
        _isUploadingLogo = true;
        _uploadProgress = 0.0;
      });

      // Get current user ID
      final authState = ref.read(authNotifierProvider);
      final userId = authState.valueOrNull?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Upload to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('users')
          .child(userId)
          .child('logo.jpg');

      final uploadTask = storageRef.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Listen to upload progress
      uploadTask.snapshotEvents.listen((event) {
        if (mounted) {
          setState(() {
            _uploadProgress = event.bytesTransferred / event.totalBytes;
          });
        }
      });

      // Wait for upload to complete
      await uploadTask;

      // Get download URL
      final downloadUrl = await storageRef.getDownloadURL();

      // Update profile with logo URL
      final notifier = ref.read(businessProfileNotifierProvider.notifier);
      await notifier.updateBusinessLogo(downloadUrl);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logo uploaded successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload logo: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingLogo = false;
          _uploadProgress = 0.0;
        });
      }
    }
  }

  Future<void> _handleLogoRemove() async {
    final notifier = ref.read(businessProfileNotifierProvider.notifier);
    try {
      // Use null to clear the logo (consistent with _trimOrNull pattern)
      await notifier.updateBusinessLogo(null);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logo removed'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getErrorMessage(e)),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _handleSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await ref.read(authNotifierProvider.notifier).signOut();
        if (mounted) {
          context.go('/login');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to sign out: $e'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = ref.watch(businessProfileProvider);
    final updateState = ref.watch(businessProfileNotifierProvider);
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
                        RegExp(r'^\d*\.?\d{0,2}'),
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
                  const Divider(),
                  const SizedBox(height: 16),

                  // Sign out button
                  OutlinedButton.icon(
                    onPressed: _handleSignOut,
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign Out'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      side: BorderSide(color: theme.colorScheme.error),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}
