import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../application/providers/invoice_providers.dart';
import '../../domain/models/invoice.dart';

/// Invoice detail page showing full invoice info with actions
class InvoiceDetailPage extends ConsumerWidget {
  final String invoiceId;

  const InvoiceDetailPage({
    super.key,
    required this.invoiceId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoiceAsync = ref.watch(invoiceStreamProvider(invoiceId));
    final theme = Theme.of(context);

    return invoiceAsync.when(
      data: (invoice) {
        if (invoice == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Invoice')),
            body: const Center(child: Text('Invoice not found')),
          );
        }
        return _InvoiceDetailContent(invoice: invoice);
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Invoice')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Invoice')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline,
                  size: 48, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              const Text('Failed to load invoice'),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.refresh(invoiceStreamProvider(invoiceId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InvoiceDetailContent extends ConsumerStatefulWidget {
  final Invoice invoice;

  const _InvoiceDetailContent({required this.invoice});

  @override
  ConsumerState<_InvoiceDetailContent> createState() =>
      _InvoiceDetailContentState();
}

class _InvoiceDetailContentState extends ConsumerState<_InvoiceDetailContent> {
  bool _isLoading = false;

  Invoice get invoice => widget.invoice;

  Color _getStatusColor(InvoiceStatus status) {
    final theme = Theme.of(context);
    switch (status) {
      case InvoiceStatus.draft:
        return theme.colorScheme.outline;
      case InvoiceStatus.sent:
        return Colors.blue;
      case InvoiceStatus.viewed:
        return Colors.orange;
      case InvoiceStatus.paid:
        return Colors.green;
      case InvoiceStatus.overdue:
        return theme.colorScheme.error;
    }
  }

  IconData _getStatusIcon(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return Icons.edit_outlined;
      case InvoiceStatus.sent:
        return Icons.send_outlined;
      case InvoiceStatus.viewed:
        return Icons.visibility_outlined;
      case InvoiceStatus.paid:
        return Icons.check_circle_outlined;
      case InvoiceStatus.overdue:
        return Icons.warning_outlined;
    }
  }

  String _buildEmailBody() {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final dateFormat = DateFormat.yMMMd();

    final buffer = StringBuffer();
    buffer.writeln('Dear ${invoice.clientName},');
    buffer.writeln();
    buffer.writeln(
        'Please find below the details for Invoice ${invoice.invoiceNumber}:');
    buffer.writeln();
    buffer.writeln('Invoice Number: ${invoice.invoiceNumber}');
    buffer.writeln('Issue Date: ${dateFormat.format(invoice.issueDate)}');
    buffer.writeln('Due Date: ${dateFormat.format(invoice.dueDate)}');
    buffer.writeln();
    buffer.writeln('--- Line Items ---');
    for (final item in invoice.lineItems) {
      buffer.writeln(
          '${item.description}: ${item.quantity} x ${currencyFormat.format(item.rate)} = ${currencyFormat.format(item.amount)}');
    }
    buffer.writeln();
    buffer.writeln('Subtotal: ${currencyFormat.format(invoice.subtotal)}');
    buffer.writeln(
        'Tax (${invoice.taxRate.toStringAsFixed(1)}%): ${currencyFormat.format(invoice.taxAmount)}');
    buffer.writeln('Total Due: ${currencyFormat.format(invoice.total)}');
    buffer.writeln();

    if (invoice.notes != null && invoice.notes!.isNotEmpty) {
      buffer.writeln('Notes: ${invoice.notes}');
      buffer.writeln();
    }

    if (invoice.terms != null && invoice.terms!.isNotEmpty) {
      buffer.writeln('Terms: ${invoice.terms}');
      buffer.writeln();
    }

    buffer.writeln('Thank you for your business!');

    return buffer.toString();
  }

  Future<void> _sendInvoice() async {
    final subject = 'Invoice ${invoice.invoiceNumber} from Your Business';
    final body = _buildEmailBody();

    final emailUri = Uri(
      scheme: 'mailto',
      path: invoice.clientEmail,
      queryParameters: {
        'subject': subject,
        'body': body,
      },
    );

    try {
      final launched = await launchUrl(emailUri);
      if (!launched) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open email app'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      // After returning from email app, ask if they sent it
      if (!mounted) return;

      final didSend = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Mark as Sent?'),
          content: const Text(
            'Did you send the invoice? This will update the invoice status to "Sent".',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Not Yet'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes, Mark as Sent'),
            ),
          ],
        ),
      );

      if (didSend == true && mounted) {
        setState(() => _isLoading = true);
        try {
          await ref
              .read(invoiceNotifierProvider.notifier)
              .markAsSent(invoice.id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invoice marked as sent'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to update invoice: $e'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        } finally {
          if (mounted) setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open email: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _markAsPaid() async {
    final paidDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: invoice.issueDate,
      lastDate: DateTime.now(),
      helpText: 'Select payment date',
    );

    if (paidDate == null) return;

    setState(() => _isLoading = true);
    try {
      await ref
          .read(invoiceNotifierProvider.notifier)
          .markAsPaid(invoice.id, paidDate);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invoice marked as paid'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update invoice: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _duplicateInvoice() async {
    setState(() => _isLoading = true);
    try {
      final duplicated = await ref
          .read(invoiceNotifierProvider.notifier)
          .duplicateInvoice(invoice.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invoice duplicated'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.go('/invoices/${duplicated.id}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to duplicate invoice: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteInvoice() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Invoice?'),
        content: Text(
          'Are you sure you want to delete invoice ${invoice.invoiceNumber}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Capture references before any async work - the widget tree will change
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final invoiceId = invoice.id;
    final notifier = ref.read(invoiceNotifierProvider.notifier);

    // Navigate away FIRST to avoid the stream update showing "Invoice not found"
    context.go('/invoices');

    // Now delete in the background and show result via snackbar
    try {
      await notifier.deleteInvoice(invoiceId);
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Invoice deleted'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Failed to delete invoice: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final dateFormat = DateFormat.yMMMd();

    final displayStatus =
        invoice.isOverdue && invoice.status != InvoiceStatus.paid
            ? InvoiceStatus.overdue
            : invoice.status;
    final statusColor = _getStatusColor(displayStatus);

    return Scaffold(
      appBar: AppBar(
        title: Text(invoice.invoiceNumber),
        actions: [
          if (invoice.status == InvoiceStatus.draft)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Invoice',
              onPressed: _isLoading
                  ? null
                  : () => context.push('/invoices/${invoice.id}/edit'),
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'duplicate':
                  _duplicateInvoice();
                  break;
                case 'delete':
                  _deleteInvoice();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'duplicate',
                child: ListTile(
                  leading: Icon(Icons.copy),
                  title: Text('Duplicate'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete_outline,
                      color: theme.colorScheme.error),
                  title: Text('Delete',
                      style: TextStyle(color: theme.colorScheme.error)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // Status and Total Header
                _StatusHeader(
                  status: displayStatus,
                  statusColor: statusColor,
                  statusIcon: _getStatusIcon(displayStatus),
                  total: invoice.total,
                  currencyFormat: currencyFormat,
                ),

                // Client Info
                _SectionCard(
                  title: 'Client',
                  icon: Icons.person,
                  child: ListTile(
                    title: Text(
                      invoice.clientName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(invoice.clientEmail),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),

                // Dates
                _SectionCard(
                  title: 'Dates',
                  icon: Icons.calendar_today,
                  child: Column(
                    children: [
                      _DateRow(
                        label: 'Issue Date',
                        date: dateFormat.format(invoice.issueDate),
                      ),
                      _DateRow(
                        label: 'Due Date',
                        date: dateFormat.format(invoice.dueDate),
                        isOverdue: invoice.isOverdue &&
                            invoice.status != InvoiceStatus.paid,
                      ),
                      if (invoice.paidDate != null)
                        _DateRow(
                          label: 'Paid Date',
                          date: dateFormat.format(invoice.paidDate!),
                          isPaid: true,
                        ),
                    ],
                  ),
                ),

                // Line Items
                _SectionCard(
                  title: 'Line Items',
                  icon: Icons.receipt_long,
                  child: Column(
                    children: [
                      ...invoice.lineItems.map((item) => _LineItemRow(
                            description: item.description,
                            quantity: item.quantity,
                            rate: item.rate,
                            amount: item.amount,
                            currencyFormat: currencyFormat,
                          )),
                      const Divider(height: 24),
                      _TotalRow(
                        label: 'Subtotal',
                        value: currencyFormat.format(invoice.subtotal),
                      ),
                      _TotalRow(
                        label: 'Tax (${invoice.taxRate.toStringAsFixed(1)}%)',
                        value: currencyFormat.format(invoice.taxAmount),
                      ),
                      const Divider(height: 16),
                      _TotalRow(
                        label: 'Total',
                        value: currencyFormat.format(invoice.total),
                        isTotal: true,
                        theme: theme,
                      ),
                    ],
                  ),
                ),

                // Notes
                if (invoice.notes != null && invoice.notes!.isNotEmpty)
                  _SectionCard(
                    title: 'Notes',
                    icon: Icons.notes,
                    child: Text(invoice.notes!),
                  ),

                // Terms
                if (invoice.terms != null && invoice.terms!.isNotEmpty)
                  _SectionCard(
                    title: 'Terms',
                    icon: Icons.gavel,
                    child: Text(invoice.terms!),
                  ),

                const SizedBox(height: 100),
              ],
            ),
      bottomNavigationBar: _buildBottomActions(theme),
    );
  }

  Widget? _buildBottomActions(ThemeData theme) {
    if (_isLoading) return null;

    final actions = <Widget>[];

    switch (invoice.status) {
      case InvoiceStatus.draft:
        actions.addAll([
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => context.push('/invoices/${invoice.id}/edit'),
              icon: const Icon(Icons.edit),
              label: const Text('Edit'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              onPressed: _sendInvoice,
              icon: const Icon(Icons.send),
              label: const Text('Send'),
            ),
          ),
        ]);
        break;

      case InvoiceStatus.sent:
      case InvoiceStatus.viewed:
      case InvoiceStatus.overdue:
        actions.add(
          Expanded(
            child: FilledButton.icon(
              onPressed: _markAsPaid,
              icon: const Icon(Icons.check_circle),
              label: const Text('Mark as Paid'),
            ),
          ),
        );
        break;

      case InvoiceStatus.paid:
        actions.add(
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _duplicateInvoice,
              icon: const Icon(Icons.copy),
              label: const Text('Duplicate Invoice'),
            ),
          ),
        );
        break;
    }

    if (actions.isEmpty) return null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(children: actions),
      ),
    );
  }
}

class _StatusHeader extends StatelessWidget {
  final InvoiceStatus status;
  final Color statusColor;
  final IconData statusIcon;
  final double total;
  final NumberFormat currencyFormat;

  const _StatusHeader({
    required this.status,
    required this.statusColor,
    required this.statusIcon,
    required this.total,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(statusIcon, color: statusColor, size: 20),
              const SizedBox(width: 8),
              Text(
                status.displayName.toUpperCase(),
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            currencyFormat.format(total),
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  final String label;
  final String date;
  final bool isOverdue;
  final bool isPaid;

  const _DateRow({
    required this.label,
    required this.date,
    this.isOverdue = false,
    this.isPaid = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color? dateColor;
    if (isOverdue) {
      dateColor = theme.colorScheme.error;
    } else if (isPaid) {
      dateColor = Colors.green;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text(
            date,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: dateColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _LineItemRow extends StatelessWidget {
  final String description;
  final double quantity;
  final double rate;
  final double amount;
  final NumberFormat currencyFormat;

  const _LineItemRow({
    required this.description,
    required this.quantity,
    required this.rate,
    required this.amount,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            description,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${quantity.toStringAsFixed(quantity == quantity.toInt() ? 0 : 2)} × ${currencyFormat.format(rate)}',
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
              Text(
                currencyFormat.format(amount),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;
  final ThemeData? theme;

  const _TotalRow({
    required this.label,
    required this.value,
    this.isTotal = false,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
                : textTheme.bodyMedium,
          ),
          Text(
            value,
            style: isTotal
                ? textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme?.colorScheme.primary,
                  )
                : textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
