import 'package:flutter/foundation.dart';

/// Expense category enum
enum ExpenseCategory {
  travel,
  office,
  software,
  marketing,
  meals,
  equipment,
  other;

  String get displayName {
    switch (this) {
      case ExpenseCategory.travel:
        return 'Travel';
      case ExpenseCategory.office:
        return 'Office Supplies';
      case ExpenseCategory.software:
        return 'Software & Subscriptions';
      case ExpenseCategory.marketing:
        return 'Marketing & Advertising';
      case ExpenseCategory.meals:
        return 'Meals & Entertainment';
      case ExpenseCategory.equipment:
        return 'Equipment';
      case ExpenseCategory.other:
        return 'Other';
    }
  }

  /// Icon name for the category (Material Icons)
  String get iconName {
    switch (this) {
      case ExpenseCategory.travel:
        return 'flight';
      case ExpenseCategory.office:
        return 'business_center';
      case ExpenseCategory.software:
        return 'computer';
      case ExpenseCategory.marketing:
        return 'campaign';
      case ExpenseCategory.meals:
        return 'restaurant';
      case ExpenseCategory.equipment:
        return 'build';
      case ExpenseCategory.other:
        return 'more_horiz';
    }
  }
}

/// Expense entity
@immutable
class Expense {
  final String id;
  final String userId;
  final double amount;
  final ExpenseCategory category;
  final String description;
  final String? vendor;
  final String? receiptUrl;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Expense({
    required this.id,
    required this.userId,
    required this.amount,
    required this.category,
    required this.description,
    this.vendor,
    this.receiptUrl,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Whether this expense has a receipt attached
  bool get hasReceipt => receiptUrl != null && receiptUrl!.isNotEmpty;

  /// Month and year of the expense (for grouping)
  String get monthYear {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  Expense copyWith({
    String? id,
    String? userId,
    double? amount,
    ExpenseCategory? category,
    String? description,
    String? vendor,
    String? receiptUrl,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      description: description ?? this.description,
      vendor: vendor ?? this.vendor,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Expense && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
