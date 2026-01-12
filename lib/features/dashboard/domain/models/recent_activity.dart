import 'package:flutter/foundation.dart';

/// Type of activity item
enum ActivityType {
  invoiceCreated,
  invoiceSent,
  invoicePaid,
  invoiceOverdue,
  expenseAdded,
  clientAdded;

  String get displayName {
    switch (this) {
      case ActivityType.invoiceCreated:
        return 'Invoice Created';
      case ActivityType.invoiceSent:
        return 'Invoice Sent';
      case ActivityType.invoicePaid:
        return 'Payment Received';
      case ActivityType.invoiceOverdue:
        return 'Invoice Overdue';
      case ActivityType.expenseAdded:
        return 'Expense Added';
      case ActivityType.clientAdded:
        return 'Client Added';
    }
  }

  String get iconName {
    switch (this) {
      case ActivityType.invoiceCreated:
        return 'description';
      case ActivityType.invoiceSent:
        return 'send';
      case ActivityType.invoicePaid:
        return 'paid';
      case ActivityType.invoiceOverdue:
        return 'warning';
      case ActivityType.expenseAdded:
        return 'receipt_long';
      case ActivityType.clientAdded:
        return 'person_add';
    }
  }
}

/// Recent activity item for dashboard display
@immutable
class RecentActivity {
  final String id;
  final ActivityType type;
  final String title;
  final String? subtitle;
  final double? amount;
  final DateTime timestamp;
  final String? relatedId;

  const RecentActivity({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    this.amount,
    required this.timestamp,
    this.relatedId,
  });

  /// Human-readable time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecentActivity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
