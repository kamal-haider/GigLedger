import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/expense.dart';

/// DTO for Expense matching Firestore document structure
class ExpenseDTO {
  final String? id;
  final String? userId;
  final double? amount;
  final String? category;
  final String? description;
  final String? vendor;
  final String? receiptUrl;
  final Timestamp? date;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  const ExpenseDTO({
    this.id,
    this.userId,
    this.amount,
    this.category,
    this.description,
    this.vendor,
    this.receiptUrl,
    this.date,
    this.createdAt,
    this.updatedAt,
  });

  factory ExpenseDTO.fromJson(Map<String, dynamic> json, String documentId) {
    return ExpenseDTO(
      id: documentId,
      userId: json['userId'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      category: json['category'] as String?,
      description: json['description'] as String?,
      vendor: json['vendor'] as String?,
      receiptUrl: json['receiptUrl'] as String?,
      date: json['date'] as Timestamp?,
      createdAt: json['createdAt'] as Timestamp?,
      updatedAt: json['updatedAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'amount': amount,
      'category': category,
      'description': description,
      'vendor': vendor,
      'receiptUrl': receiptUrl,
      'date': date,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Expense toDomain() {
    final now = DateTime.now();
    return Expense(
      id: id ?? '',
      userId: userId ?? '',
      amount: amount ?? 0,
      category: _parseCategory(category),
      description: description ?? '',
      vendor: vendor,
      receiptUrl: receiptUrl,
      date: date?.toDate() ?? now,
      createdAt: createdAt?.toDate() ?? now,
      updatedAt: updatedAt?.toDate() ?? now,
    );
  }

  ExpenseCategory _parseCategory(String? value) {
    if (value == null) return ExpenseCategory.other;
    return ExpenseCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ExpenseCategory.other,
    );
  }

  factory ExpenseDTO.fromDomain(Expense expense) {
    return ExpenseDTO(
      id: expense.id,
      userId: expense.userId,
      amount: expense.amount,
      category: expense.category.name,
      description: expense.description,
      vendor: expense.vendor,
      receiptUrl: expense.receiptUrl,
      date: Timestamp.fromDate(expense.date),
      createdAt: Timestamp.fromDate(expense.createdAt),
      updatedAt: Timestamp.fromDate(expense.updatedAt),
    );
  }
}
