import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../settings/application/providers/settings_providers.dart';
import '../../application/providers/dashboard_providers.dart';
import '../../domain/models/financial_summary.dart';
import '../widgets/financial_summary_card.dart';

/// Main dashboard page showing financial overview
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(financialSummaryStreamProvider);
    final profile = ref.watch(businessProfileProvider);

    // Get currency symbol from profile
    final currency = profile?.currency ?? 'USD';
    final currencySymbol = _getCurrencySymbol(currency);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(financialSummaryStreamProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Greeting section
            _buildGreeting(context, profile?.businessName),
            const SizedBox(height: 24),

            // Financial Summary
            summaryAsync.when(
              data: (summary) => FinancialSummaryCard(
                summary: summary,
                currencySymbol: currencySymbol,
              ),
              loading: () => const _LoadingCard(),
              error: (error, _) => _ErrorCard(
                message: 'Failed to load financial summary',
                onRetry: () => ref.invalidate(financialSummaryStreamProvider),
              ),
            ),
            const SizedBox(height: 16),

            // YTD Summary
            summaryAsync.when(
              data: (summary) => _YTDSummaryCard(
                summary: summary,
                currencySymbol: currencySymbol,
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),

            // Quick Actions placeholder (for #5)
            _buildQuickActionsPlaceholder(context),
            const SizedBox(height: 24),

            // Recent Activity placeholder (for #6)
            _buildRecentActivityPlaceholder(context),
          ],
        ),
      ),
    );
  }

  Widget _buildGreeting(BuildContext context, String? businessName) {
    final theme = Theme.of(context);
    final hour = DateTime.now().hour;
    String greeting;

    if (hour < 12) {
      greeting = 'Good morning';
    } else if (hour < 17) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (businessName != null && businessName.isNotEmpty)
          Text(
            businessName,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }

  Widget _buildQuickActionsPlaceholder(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Quick actions coming soon',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityPlaceholder(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Recent activity coming soon',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCurrencySymbol(String currencyCode) {
    const symbols = {
      'USD': '\$',
      'EUR': '\u20AC',
      'GBP': '\u00A3',
      'CAD': 'C\$',
      'AUD': 'A\$',
      'JPY': '\u00A5',
      'CHF': 'CHF',
      'INR': '\u20B9',
    };
    return symbols[currencyCode] ?? '\$';
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorCard({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
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
            Text(
              message,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
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

class _YTDSummaryCard extends StatelessWidget {
  final FinancialSummary summary;
  final String currencySymbol;

  const _YTDSummaryCard({
    required this.summary,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Year to Date',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _YTDMetric(
                  label: 'Income',
                  value: summary.incomeYTD,
                  currencySymbol: currencySymbol,
                  color: Colors.green,
                ),
                _YTDMetric(
                  label: 'Expenses',
                  value: summary.expensesYTD,
                  currencySymbol: currencySymbol,
                  color: Colors.red,
                ),
                _YTDMetric(
                  label: 'Profit',
                  value: summary.profitYTD,
                  currencySymbol: currencySymbol,
                  color: summary.profitYTD >= 0 ? Colors.green : Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _YTDMetric extends StatelessWidget {
  final String label;
  final double value;
  final String currencySymbol;
  final Color color;

  const _YTDMetric({
    required this.label,
    required this.value,
    required this.currencySymbol,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$currencySymbol${value.toStringAsFixed(0)}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
