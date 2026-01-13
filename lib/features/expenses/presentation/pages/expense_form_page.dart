import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../application/providers/expense_form_provider.dart';
import '../../application/providers/expense_providers.dart';
import '../../domain/models/expense.dart';

/// Expense add/edit form page
class ExpenseFormPage extends ConsumerStatefulWidget {
  /// The expense ID to edit, or null for creating a new expense
  final String? expenseId;

  const ExpenseFormPage({
    super.key,
    this.expenseId,
  });

  @override
  ConsumerState<ExpenseFormPage> createState() => _ExpenseFormPageState();
}

class _ExpenseFormPageState extends ConsumerState<ExpenseFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late TextEditingController _vendorController;
  bool _isInitialized = false;
  bool _controllersInitialized = false;

  bool get isEditMode => widget.expenseId != null;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _descriptionController = TextEditingController();
    _vendorController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _vendorController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      // Defer ALL provider modifications to avoid "modify during build" errors
      Future.microtask(() {
        if (!mounted) return;
        final formNotifier = ref.read(expenseFormProvider.notifier);
        if (isEditMode) {
          ref.read(expenseByIdProvider(widget.expenseId!)).whenData((expense) {
            if (expense != null && !_controllersInitialized) {
              formNotifier.initForEdit(expense);
              _amountController.text = expense.amount.toStringAsFixed(2);
              _descriptionController.text = expense.description;
              _vendorController.text = expense.vendor ?? '';
              _controllersInitialized = true;
            }
          });
        } else {
          formNotifier.initForCreate();
        }
      });
    }
  }

  void _syncControllersWithExpense() {
    // For edit mode: sync controllers and form state when expense data is loaded
    if (isEditMode && !_controllersInitialized) {
      ref.read(expenseByIdProvider(widget.expenseId!)).whenData((expense) {
        if (expense != null && !_controllersInitialized) {
          // Initialize form state for edit mode
          ref.read(expenseFormProvider.notifier).initForEdit(expense);
          // Sync text controllers
          _amountController.text = expense.amount.toStringAsFixed(2);
          _descriptionController.text = expense.description;
          _vendorController.text = expense.vendor ?? '';
          _controllersInitialized = true;
        }
      });
    }
  }

  Future<void> _selectDate() async {
    final formState = ref.read(expenseFormProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: formState.date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (picked != null) {
      ref.read(expenseFormProvider.notifier).setDate(picked);
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    final formNotifier = ref.read(expenseFormProvider.notifier);

    // Update form state from controllers
    final amount = double.tryParse(_amountController.text.replaceAll(',', ''));
    formNotifier.setAmount(amount);
    formNotifier.setDescription(_descriptionController.text);
    formNotifier.setVendor(_vendorController.text.isEmpty ? null : _vendorController.text);

    final savedExpense = await formNotifier.saveExpense();

    if (savedExpense != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditMode ? 'Expense updated' : 'Expense added'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formState = ref.watch(expenseFormProvider);

    // Handle error messages
    ref.listen<ExpenseFormState>(expenseFormProvider, (prev, next) {
      if (next.errorMessage != null && next.errorMessage != prev?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            behavior: SnackBarBehavior.floating,
            backgroundColor: theme.colorScheme.error,
          ),
        );
        ref.read(expenseFormProvider.notifier).clearError();
      }
    });

    // Sync controllers with expense data (for edit mode)
    _syncControllersWithExpense();

    // Show loading when editing and expense is being fetched
    if (isEditMode && !_controllersInitialized) {
      final expenseAsync = ref.watch(expenseByIdProvider(widget.expenseId!));
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Expense'),
        ),
        body: expenseAsync.when(
          data: (expense) {
            if (expense == null) {
              return const Center(child: Text('Expense not found'));
            }
            // Will be initialized on next build
            return const Center(child: CircularProgressIndicator());
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                const SizedBox(height: 16),
                Text('Failed to load expense'),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => ref.refresh(expenseByIdProvider(widget.expenseId!)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Expense' : 'Add Expense'),
        actions: [
          TextButton(
            onPressed: formState.isLoading ? null : _saveExpense,
            child: formState.isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Amount field
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Amount',
                hintText: '0.00',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.attach_money),
                prefixText: '\$ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                final amount = double.tryParse(value.replaceAll(',', ''));
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                if (amount > 999999999.99) {
                  return 'Amount is too large';
                }
                return null;
              },
              autofocus: !isEditMode,
            ),
            const SizedBox(height: 16),

            // Category dropdown
            DropdownButtonFormField<ExpenseCategory>(
              value: formState.category,
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(_getCategoryIcon(formState.category)),
              ),
              items: ExpenseCategory.values.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Row(
                    children: [
                      Icon(
                        _getCategoryIcon(category),
                        size: 20,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 12),
                      Text(category.displayName),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (category) {
                if (category != null) {
                  ref.read(expenseFormProvider.notifier).setCategory(category);
                }
              },
            ),
            const SizedBox(height: 16),

            // Date picker
            InkWell(
              onTap: _selectDate,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.calendar_today),
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                ),
                child: Text(
                  DateFormat.yMMMd().format(formState.date),
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Description field
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'What was this expense for?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.description),
              ),
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Vendor field (optional)
            TextFormField(
              controller: _vendorController,
              decoration: InputDecoration(
                labelText: 'Vendor (optional)',
                hintText: 'e.g., Amazon, Starbucks',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.store),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 24),

            // Receipt placeholder (coming soon)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant,
                  style: BorderStyle.solid,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.receipt_long,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Receipt Photo',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          'Coming soon',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Save button at bottom
            FilledButton(
              onPressed: formState.isLoading ? null : _saveExpense,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: formState.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(isEditMode ? 'Update Expense' : 'Add Expense'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.travel:
        return Icons.flight;
      case ExpenseCategory.office:
        return Icons.business_center;
      case ExpenseCategory.software:
        return Icons.computer;
      case ExpenseCategory.marketing:
        return Icons.campaign;
      case ExpenseCategory.meals:
        return Icons.restaurant;
      case ExpenseCategory.equipment:
        return Icons.build;
      case ExpenseCategory.other:
        return Icons.more_horiz;
    }
  }
}
