import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/providers/client_form_provider.dart';

/// Client add/edit form page
class ClientFormPage extends ConsumerStatefulWidget {
  /// Optional client ID for edit mode. If null, creates a new client.
  final String? clientId;

  const ClientFormPage({
    super.key,
    this.clientId,
  });

  @override
  ConsumerState<ClientFormPage> createState() => _ClientFormPageState();
}

class _ClientFormPageState extends ConsumerState<ClientFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _notesController;

  bool _isInitialized = false;

  bool get isEditMode => widget.clientId != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      final notifier = ref.read(clientFormNotifierProvider.notifier);
      if (isEditMode) {
        // Schedule after frame to ensure provider is ready
        Future.microtask(() => notifier.initForEdit(widget.clientId!));
      } else {
        notifier.initForCreate();
      }
    }
  }

  bool _controllersInitialized = false;

  void _syncControllersWithState(ClientFormState formState) {
    // Sync controllers once when data is loaded (for edit mode)
    if (!_controllersInitialized && !formState.isLoading && formState.name.isNotEmpty) {
      _nameController.text = formState.name;
      _emailController.text = formState.email;
      _phoneController.text = formState.phone;
      _addressController.text = formState.address;
      _notesController.text = formState.notes;
      _controllersInitialized = true;
    }
  }

  Future<void> _handleSave() async {
    final notifier = ref.read(clientFormNotifierProvider.notifier);

    // Update state from controllers before validation
    notifier.updateName(_nameController.text);
    notifier.updateEmail(_emailController.text);
    notifier.updatePhone(_phoneController.text);
    notifier.updateAddress(_addressController.text);
    notifier.updateNotes(_notesController.text);

    if (!_formKey.currentState!.validate()) return;

    final savedClient = await notifier.saveClient();

    if (savedClient != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditMode
                ? 'Client updated successfully'
                : 'Client created successfully',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop(true); // Return true to indicate success
    }
  }

  Future<bool> _handleBackNavigation() async {
    final notifier = ref.read(clientFormNotifierProvider.notifier);

    // Update state from controllers to check for changes
    notifier.updateName(_nameController.text);
    notifier.updateEmail(_emailController.text);
    notifier.updatePhone(_phoneController.text);
    notifier.updateAddress(_addressController.text);
    notifier.updateNotes(_notesController.text);

    if (!notifier.hasChanges) {
      return true;
    }

    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text(
          'You have unsaved changes. Are you sure you want to discard them?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep Editing'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    return shouldDiscard ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formState = ref.watch(clientFormNotifierProvider);
    final notifier = ref.read(clientFormNotifierProvider.notifier);

    // Sync controllers with form state once loaded (for edit mode)
    _syncControllersWithState(formState);

    // Show error snackbar if there's an error
    if (formState.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(formState.errorMessage!),
            behavior: SnackBarBehavior.floating,
            backgroundColor: theme.colorScheme.error,
          ),
        );
        notifier.clearError();
      });
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _handleBackNavigation();
        if (shouldPop && mounted) {
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditMode ? 'Edit Client' : 'New Client'),
          actions: [
            if (formState.isSaving)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            else
              TextButton(
                onPressed: _handleSave,
                child: const Text('Save'),
              ),
          ],
        ),
        body: formState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Name field (required)
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Name *',
                        hintText: 'Client or company name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.person),
                      ),
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      validator: notifier.validateName,
                      enabled: !formState.isSaving,
                    ),
                    const SizedBox(height: 16),

                    // Email field (required)
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email *',
                        hintText: 'client@example.com',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: notifier.validateEmail,
                      enabled: !formState.isSaving,
                    ),
                    const SizedBox(height: 16),

                    // Phone field (optional)
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Phone',
                        hintText: '+1 (555) 123-4567',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      enabled: !formState.isSaving,
                    ),
                    const SizedBox(height: 16),

                    // Address field (optional)
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Address',
                        hintText: 'Street address, City, State, ZIP',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.location_on),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 3,
                      textInputAction: TextInputAction.next,
                      enabled: !formState.isSaving,
                    ),
                    const SizedBox(height: 16),

                    // Notes field (optional)
                    TextFormField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        labelText: 'Notes',
                        hintText: 'Add any notes about this client...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.notes),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 4,
                      textInputAction: TextInputAction.done,
                      enabled: !formState.isSaving,
                    ),
                    const SizedBox(height: 24),

                    // Helper text
                    Text(
                      '* Required fields',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Save button at bottom
                    FilledButton(
                      onPressed: formState.isSaving ? null : _handleSave,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: formState.isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(isEditMode
                                ? 'Update Client'
                                : 'Create Client'),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
      ),
    );
  }
}
