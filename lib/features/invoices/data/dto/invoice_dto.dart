import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/invoice.dart';
import '../../domain/models/line_item.dart';
import 'line_item_dto.dart';

/// DTO for Invoice matching Firestore document structure
class InvoiceDTO {
  final String? id;
  final String? userId;
  final String? invoiceNumber;
  final String? clientId;
  final String? clientName;
  final String? clientEmail;
  final List<Map<String, dynamic>>? lineItems;
  final double? subtotal;
  final double? taxRate;
  final double? taxAmount;
  final double? total;
  final String? status;
  final Timestamp? issueDate;
  final Timestamp? dueDate;
  final Timestamp? paidDate;
  final String? notes;
  final String? terms;
  final String? templateId;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  const InvoiceDTO({
    this.id,
    this.userId,
    this.invoiceNumber,
    this.clientId,
    this.clientName,
    this.clientEmail,
    this.lineItems,
    this.subtotal,
    this.taxRate,
    this.taxAmount,
    this.total,
    this.status,
    this.issueDate,
    this.dueDate,
    this.paidDate,
    this.notes,
    this.terms,
    this.templateId,
    this.createdAt,
    this.updatedAt,
  });

  factory InvoiceDTO.fromJson(Map<String, dynamic> json, String documentId) {
    return InvoiceDTO(
      id: documentId,
      userId: json['userId'] as String?,
      invoiceNumber: json['invoiceNumber'] as String?,
      clientId: json['clientId'] as String?,
      clientName: json['clientName'] as String?,
      clientEmail: json['clientEmail'] as String?,
      lineItems: (json['lineItems'] as List<dynamic>?)
          ?.map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      subtotal: (json['subtotal'] as num?)?.toDouble(),
      taxRate: (json['taxRate'] as num?)?.toDouble(),
      taxAmount: (json['taxAmount'] as num?)?.toDouble(),
      total: (json['total'] as num?)?.toDouble(),
      status: json['status'] as String?,
      issueDate: json['issueDate'] as Timestamp?,
      dueDate: json['dueDate'] as Timestamp?,
      paidDate: json['paidDate'] as Timestamp?,
      notes: json['notes'] as String?,
      terms: json['terms'] as String?,
      templateId: json['templateId'] as String?,
      createdAt: json['createdAt'] as Timestamp?,
      updatedAt: json['updatedAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'invoiceNumber': invoiceNumber,
      'clientId': clientId,
      'clientName': clientName,
      'clientEmail': clientEmail,
      'lineItems': lineItems,
      'subtotal': subtotal,
      'taxRate': taxRate,
      'taxAmount': taxAmount,
      'total': total,
      'status': status,
      'issueDate': issueDate,
      'dueDate': dueDate,
      'paidDate': paidDate,
      'notes': notes,
      'terms': terms,
      'templateId': templateId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Invoice toDomain() {
    final now = DateTime.now();
    return Invoice(
      id: id ?? '',
      userId: userId ?? '',
      invoiceNumber: invoiceNumber ?? '',
      clientId: clientId ?? '',
      clientName: clientName ?? '',
      clientEmail: clientEmail ?? '',
      lineItems: _parseLineItems(),
      subtotal: subtotal ?? 0,
      taxRate: taxRate ?? 0,
      taxAmount: taxAmount ?? 0,
      total: total ?? 0,
      status: _parseStatus(status),
      issueDate: issueDate?.toDate() ?? now,
      dueDate: dueDate?.toDate() ?? now,
      paidDate: paidDate?.toDate(),
      notes: notes,
      terms: terms,
      templateId: templateId ?? 'default',
      createdAt: createdAt?.toDate() ?? now,
      updatedAt: updatedAt?.toDate() ?? now,
    );
  }

  List<LineItem> _parseLineItems() {
    if (lineItems == null) return [];
    return lineItems!.map((json) => LineItemDTO.fromJson(json).toDomain()).toList();
  }

  InvoiceStatus _parseStatus(String? value) {
    if (value == null) return InvoiceStatus.draft;
    return InvoiceStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => InvoiceStatus.draft,
    );
  }

  factory InvoiceDTO.fromDomain(Invoice invoice) {
    return InvoiceDTO(
      id: invoice.id,
      userId: invoice.userId,
      invoiceNumber: invoice.invoiceNumber,
      clientId: invoice.clientId,
      clientName: invoice.clientName,
      clientEmail: invoice.clientEmail,
      lineItems: invoice.lineItems
          .map((item) => LineItemDTO.fromDomain(item).toJson())
          .toList(),
      subtotal: invoice.subtotal,
      taxRate: invoice.taxRate,
      taxAmount: invoice.taxAmount,
      total: invoice.total,
      status: invoice.status.name,
      issueDate: Timestamp.fromDate(invoice.issueDate),
      dueDate: Timestamp.fromDate(invoice.dueDate),
      paidDate: invoice.paidDate != null
          ? Timestamp.fromDate(invoice.paidDate!)
          : null,
      notes: invoice.notes,
      terms: invoice.terms,
      templateId: invoice.templateId,
      createdAt: Timestamp.fromDate(invoice.createdAt),
      updatedAt: Timestamp.fromDate(invoice.updatedAt),
    );
  }
}
