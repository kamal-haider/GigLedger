import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../application/providers/dashboard_providers.dart';
import '../../domain/models/recent_activity.dart';

/// List of recent activity items for the dashboard
class RecentActivityList extends ConsumerWidget {
  final String currencySymbol;

  const RecentActivityList({
    super.key,
    this.currencySymbol = '\$',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityAsync = ref.watch(recentActivityStreamProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (activityAsync.isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            activityAsync.when(
              data: (activities) => activities.isEmpty
                  ? _EmptyState()
                  : _ActivityList(
                      activities: activities,
                      currencySymbol: currencySymbol,
                    ),
              loading: () => const _LoadingState(),
              error: (error, _) => _ErrorState(
                onRetry: () => ref.invalidate(recentActivityStreamProvider),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityList extends StatelessWidget {
  final List<RecentActivity> activities;
  final String currencySymbol;

  const _ActivityList({
    required this.activities,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: activities
          .map((activity) => _ActivityTile(
                activity: activity,
                currencySymbol: currencySymbol,
              ))
          .toList(),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final RecentActivity activity;
  final String currencySymbol;

  const _ActivityTile({
    required this.activity,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, color) = _getIconAndColor(activity.type, theme.colorScheme);

    return InkWell(
      onTap: () => _navigateToActivity(context, activity),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (activity.subtitle != null)
                    Text(
                      activity.subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (activity.amount != null)
                  Text(
                    _formatAmount(activity.amount!),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _getAmountColor(activity.type, theme.colorScheme),
                    ),
                  ),
                Text(
                  activity.timeAgo,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    final formatter = NumberFormat.currency(
      symbol: currencySymbol,
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  (IconData, Color) _getIconAndColor(ActivityType type, ColorScheme scheme) {
    return switch (type) {
      ActivityType.invoiceCreated => (Icons.description, scheme.primary),
      ActivityType.invoiceSent => (Icons.send, scheme.secondary),
      ActivityType.invoicePaid => (Icons.paid, scheme.tertiary),
      ActivityType.invoiceOverdue => (Icons.warning, scheme.error),
      ActivityType.expenseAdded => (Icons.receipt_long, scheme.error),
      ActivityType.clientAdded => (Icons.person_add, scheme.primary),
    };
  }

  Color _getAmountColor(ActivityType type, ColorScheme scheme) {
    return switch (type) {
      ActivityType.invoicePaid => scheme.tertiary,
      ActivityType.expenseAdded => scheme.error,
      _ => scheme.onSurface,
    };
  }

  void _navigateToActivity(BuildContext context, RecentActivity activity) {
    if (activity.relatedId == null) return;

    final route = switch (activity.type) {
      ActivityType.invoiceCreated ||
      ActivityType.invoiceSent ||
      ActivityType.invoicePaid ||
      ActivityType.invoiceOverdue =>
        '/invoices/${activity.relatedId}',
      ActivityType.expenseAdded => '/expenses/${activity.relatedId}',
      ActivityType.clientAdded => '/clients/${activity.relatedId}',
    };

    context.push(route);
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.history,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'No recent activity',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Create an invoice or add an expense to get started',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 32,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 8),
            Text(
              'Failed to load activity',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
