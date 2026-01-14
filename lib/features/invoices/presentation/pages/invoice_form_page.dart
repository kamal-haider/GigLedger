import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../clients/application/providers/client_providers.dart';
import '../../../clients/domain/models/client.dart';
import '../../application/providers/invoice_form_provider.dart';
import '../../application/providers/invoice_providers.dart';
import '../widgets/invoice_totals.dart';
import '../widgets/line_item_editor.dart';

/// Invoice add/edit form page
class InvoiceFormPage extends ConsumerStatefulWidget {
  /// The invoice ID to edit, or null for creating a new invoice
  final String? invoiceId;

  const InvoiceFormPage({
    super.key,
    this.invoiceId,
  });

  @override
  ConsumerState<InvoiceFormPage> createState() => _InvoiceFormPageState();
}

class _InvoiceFormPageState extends ConsumerState<InvoiceFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _invoiceNumberController;
  late TextEditingController _notesController;
  late TextEditingController _termsController;
  late TextEditingController _taxRateController;
  bool _isInitialized = false;
  bool _controllersInitialized = false;

  bool get isEditMode => widget.invoiceId != null;

  @override
  void initState() {
    super.initState();
    _invoiceNumberController = TextEditingController();
    _notesController = TextEditingController();
    _termsController = TextEditingController();
    _taxRateController = TextEditingController(text: '0');
  }

  @override
  void dispose() {
    _invoiceNumberController.dispose();
    _notesController.dispose();
    _termsController.dispose();
    _taxRateController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      Future.microtask(() {
        if (!mounted) return;
        final formNotifier = ref.read(invoiceFormProvider.notifier);
        if (isEditMode) {
          ref.read(invoiceByIdProvider(widget.invoiceId!)).whenData((invoice) {
            if (invoice != null && !_controllersInitialized) {
              // Find the client
              ref.read(clientsProvider.future).then((clients) {
                final client = clients.cast<Client?>().firstWhere(
                      (c) => c?.id == invoice.clientId,
                      orElse: () => null,
                    );
                if (mounted) {
                  formNotifier.initForEdit(invoice, client);
                  _invoiceNumberController.text = invoice.invoiceNumber;
                  _notesController.text = invoice.notes ?? '';
                  _termsController.text = invoice.terms ?? '';
                  _taxRateController.text = invoice.taxRate.toString();
                  _controllersInitialized = true;
                }
              });
            }
          });
        } else {
          formNotifier.initForCreate().then((_) {
            if (mounted) {
              final state = ref.read(invoiceFormProvider);
              _invoiceNumberController.text = state.invoiceNumber;
              _controllersInitialized = true;
            }
          });
        }
      });
    }
  }

  void _syncControllersWithInvoice() {
    if (isEditMode && !_controllersInitialized) {
      ref.read(invoiceByIdProvider(widget.invoiceId!)).whenData((invoice) {
        if (invoice != null && !_controllersInitialized) {
          _controllersInitialized = true;
          _invoiceNumberController.text = invoice.invoiceNumber;
          _notesController.text = invoice.notes ?? '';
          _termsController.text = invoice.terms ?? '';
          _taxRateController.text = invoice.taxRate.toString();
          Future.microtask(() {
            if (mounted) {
              ref.read(clientsProvider.future).then((clients) {
                final client = clients.cast<Client?>().firstWhere(
                      (c) => c?.id == invoice.clientId,
                      orElse: () => null,
                    );
                if (mounted) {
                  ref
                      .read(invoiceFormProvider.notifier)
                      .initForEdit(invoice, client);
                }
              });
            }
          });
        }
      });
    }
  }

  Future<void> _selectIssueDate() async {
    final formState = ref.read(invoiceFormProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: formState.issueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      ref.read(invoiceFormProvider.notifier).setIssueDate(picked);
    }
  }

  Future<void> _selectDueDate() async {
    final formState = ref.read(invoiceFormProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: formState.dueDate,
      firstDate: formState.issueDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      ref.read(invoiceFormProvider.notifier).setDueDate(picked);
    }
  }

  Future<void> _saveAsDraft() async {
    if (!_formKey.currentState!.validate()) return;
    _updateFormState();

    final savedInvoice =
        await ref.read(invoiceFormProvider.notifier).saveAsDraft();

    if (savedInvoice != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditMode ? 'Invoice updated' : 'Draft saved'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    }
  }

  Future<void> _saveAndSend() async {
    if (!_formKey.currentState!.validate()) return;
    _updateFormState();

    final savedInvoice =
        await ref.read(invoiceFormProvider.notifier).saveAndSend();

    if (savedInvoice != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invoice sent to ${savedInvoice.clientEmail}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    }
  }

  void _updateFormState() {
    final formNotifier = ref.read(invoiceFormProvider.notifier);
    formNotifier.setInvoiceNumber(_invoiceNumberController.text);
    formNotifier.setNotes(_notesController.text);
    formNotifier.setTerms(_termsController.text);
    final taxRate = double.tryParse(_taxRateController.text) ?? 0;
    formNotifier.setTaxRate(taxRate);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formState = ref.watch(invoiceFormProvider);
    final clientsAsync = ref.watch(clientsStreamProvider);

    // Handle error messages
    ref.listen<InvoiceFormState>(invoiceFormProvider, (prev, next) {
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            behavior: SnackBarBehavior.floating,
            backgroundColor: theme.colorScheme.error,
          ),
        );
        ref.read(invoiceFormProvider.notifier).clearError();
      }
    });

    _syncControllersWithInvoice();

    // Show loading when editing and invoice is being fetched
    if (isEditMode && !_controllersInitialized) {
      final invoiceAsync = ref.watch(invoiceByIdProvider(widget.invoiceId!));
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Invoice'),
        ),
        body: invoiceAsync.when(
          data: (invoice) {
            if (invoice == null) {
              return const Center(child: Text('Invoice not found'));
            }
            return const Center(child: CircularProgressIndicator());
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline,
                    size: 48, color: theme.colorScheme.error),
                const SizedBox(height: 16),
                const Text('Failed to load invoice'),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () =>
                      ref.refresh(invoiceByIdProvider(widget.invoiceId!)),
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
        title: Text(isEditMode ? 'Edit Invoice' : 'New Invoice'),
        actions: [
          // Save as Draft
          TextButton(
            onPressed: formState.isLoading || !formState.canSaveAsDraft
                ? null
                : _saveAsDraft,
            child: const Text('Save Draft'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Client selection
            _buildClientDropdown(theme, formState, clientsAsync),
            const SizedBox(height: 16),

            // Invoice number
            TextFormField(
              controller: _invoiceNumberController,
              decoration: InputDecoration(
                labelText: 'Invoice Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.tag),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter an invoice number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Date row
            Row(
              children: [
                // Issue date
                Expanded(
                  child: InkWell(
                    onTap: _selectIssueDate,
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Issue Date',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        DateFormat.yMMMd().format(formState.issueDate),
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Due date
                Expanded(
                  child: InkWell(
                    onTap: _selectDueDate,
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Due Date',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.event),
                      ),
                      child: Text(
                        DateFormat.yMMMd().format(formState.dueDate),
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Line items section
            LineItemsSection(
              lineItems: formState.lineItems,
              onAddItem: () {
                ref.read(invoiceFormProvider.notifier).addLineItem();
              },
              onDescriptionChanged: (index, description) {
                ref
                    .read(invoiceFormProvider.notifier)
                    .updateLineItemDescription(index, description);
              },
              onQuantityChanged: (index, quantity) {
                ref
                    .read(invoiceFormProvider.notifier)
                    .updateLineItemQuantity(index, quantity);
              },
              onRateChanged: (index, rate) {
                ref
                    .read(invoiceFormProvider.notifier)
                    .updateLineItemRate(index, rate);
              },
              onRemoveItem: (index) {
                ref.read(invoiceFormProvider.notifier).removeLineItem(index);
              },
            ),
            const SizedBox(height: 16),

            // Tax rate
            TextFormField(
              controller: _taxRateController,
              decoration: InputDecoration(
                labelText: 'Tax Rate (%)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.percent),
                suffixText: '%',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              onChanged: (value) {
                final rate = double.tryParse(value) ?? 0;
                ref.read(invoiceFormProvider.notifier).setTaxRate(rate);
              },
            ),
            const SizedBox(height: 16),

            // Totals
            InvoiceTotals(
              subtotal: formState.subtotal,
              taxRate: formState.taxRate,
              taxAmount: formState.taxAmount,
              total: formState.total,
            ),
            const SizedBox(height: 24),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'Additional notes for the client',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.notes),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            // Terms
            TextFormField(
              controller: _termsController,
              decoration: InputDecoration(
                labelText: 'Terms (optional)',
                hintText: 'Payment terms and conditions',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.gavel),
              ),
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 32),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: formState.isLoading || !formState.canSaveAsDraft
                        ? null
                        : _saveAsDraft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child:
                          Text(isEditMode ? 'Update Draft' : 'Save as Draft'),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: formState.isLoading || !formState.canSend
                        ? null
                        : _saveAndSend,
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
                          : const Text('Send Invoice'),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildClientDropdown(
    ThemeData theme,
    InvoiceFormState formState,
    AsyncValue<List<Client>> clientsAsync,
  ) {
    return clientsAsync.when(
      data: (clients) {
        if (clients.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.person_add_outlined,
                    size: 48,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No clients yet',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      context.push('/clients/new');
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Client'),
                  ),
                ],
              ),
            ),
          );
        }

        return DropdownButtonFormField<Client>(
          value: formState.selectedClient,
          decoration: InputDecoration(
            labelText: 'Client',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.person),
          ),
          hint: const Text('Select a client'),
          items: clients.map((client) {
            return DropdownMenuItem(
              value: client,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    client.name,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    client.email,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (client) {
            ref.read(invoiceFormProvider.notifier).setClient(client);
          },
          validator: (value) {
            if (value == null) {
              return 'Please select a client';
            }
            return null;
          },
          isExpanded: true,
          selectedItemBuilder: (context) {
            return clients.map((client) {
              return Text(
                client.name,
                overflow: TextOverflow.ellipsis,
              );
            }).toList();
          },
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (error, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 8),
              const Text('Failed to load clients'),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => ref.refresh(clientsStreamProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
