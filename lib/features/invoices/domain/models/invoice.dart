import 'package:flutter/foundation.dart';

import 'line_item.dart';

/// Invoice status enum
enum InvoiceStatus {
  draft,
  sent,
  viewed,
  paid,
  overdue;

  String get displayName {
    switch (this) {
      case InvoiceStatus.draft:
        return 'Draft';
      case InvoiceStatus.sent:
        return 'Sent';
      case InvoiceStatus.viewed:
        return 'Viewed';
      case InvoiceStatus.paid:
        return 'Paid';
      case InvoiceStatus.overdue:
        return 'Overdue';
    }
  }

  bool get isPending => this == sent || this == viewed || this == overdue;
  bool get isEditable => this == draft;
}

/// Invoice entity
@immutable
class Invoice {
  final String id;
  final String userId;
  final String invoiceNumber;
  final String clientId;
  final String clientName;
  final String clientEmail;
  final List<LineItem> lineItems;
  final double subtotal;
  final double taxRate;
  final double taxAmount;
  final double total;
  final InvoiceStatus status;
  final DateTime issueDate;
  final DateTime dueDate;
  final DateTime? paidDate;
  final String? notes;
  final String? terms;
  final String templateId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Invoice({
    required this.id,
    required this.userId,
    required this.invoiceNumber,
    required this.clientId,
    required this.clientName,
    required this.clientEmail,
    required this.lineItems,
    required this.subtotal,
    required this.taxRate,
    required this.taxAmount,
    required this.total,
    required this.status,
    required this.issueDate,
    required this.dueDate,
    this.paidDate,
    this.notes,
    this.terms,
    this.templateId = 'default',
    required this.createdAt,
    required this.updatedAt,
  });

  /// Whether the invoice is past due
  bool get isOverdue =>
      status != InvoiceStatus.paid &&
      status != InvoiceStatus.draft &&
      DateTime.now().isAfter(dueDate);

  /// Days until due (negative if overdue)
  int get daysUntilDue => dueDate.difference(DateTime.now()).inDays;

  /// Days overdue (0 if not overdue)
  int get daysOverdue => isOverdue ? -daysUntilDue : 0;

  /// Create a new invoice with calculated totals
  factory Invoice.create({
    required String id,
    required String userId,
    required String invoiceNumber,
    required String clientId,
    required String clientName,
    required String clientEmail,
    required List<LineItem> lineItems,
    required double taxRate,
    required DateTime issueDate,
    required DateTime dueDate,
    String? notes,
    String? terms,
    String templateId = 'default',
  }) {
    final subtotal = lineItems.fold(0.0, (sum, item) => sum + item.amount);
    final taxAmount = subtotal * (taxRate / 100);
    final total = subtotal + taxAmount;

    return Invoice(
      id: id,
      userId: userId,
      invoiceNumber: invoiceNumber,
      clientId: clientId,
      clientName: clientName,
      clientEmail: clientEmail,
      lineItems: lineItems,
      subtotal: subtotal,
      taxRate: taxRate,
      taxAmount: taxAmount,
      total: total,
      status: InvoiceStatus.draft,
      issueDate: issueDate,
      dueDate: dueDate,
      notes: notes,
      terms: terms,
      templateId: templateId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Invoice copyWith({
    String? id,
    String? userId,
    String? invoiceNumber,
    String? clientId,
    String? clientName,
    String? clientEmail,
    List<LineItem>? lineItems,
    double? subtotal,
    double? taxRate,
    double? taxAmount,
    double? total,
    InvoiceStatus? status,
    DateTime? issueDate,
    DateTime? dueDate,
    DateTime? paidDate,
    String? notes,
    String? terms,
    String? templateId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Invoice(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      clientEmail: clientEmail ?? this.clientEmail,
      lineItems: lineItems ?? this.lineItems,
      subtotal: subtotal ?? this.subtotal,
      taxRate: taxRate ?? this.taxRate,
      taxAmount: taxAmount ?? this.taxAmount,
      total: total ?? this.total,
      status: status ?? this.status,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      paidDate: paidDate ?? this.paidDate,
      notes: notes ?? this.notes,
      terms: terms ?? this.terms,
      templateId: templateId ?? this.templateId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Invoice && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
