import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Quick action item data
class QuickAction {
  final String label;
  final IconData icon;
  final String route;
  final Color Function(ColorScheme) colorBuilder;

  const QuickAction({
    required this.label,
    required this.icon,
    required this.route,
    required this.colorBuilder,
  });
}

/// Grid of quick action buttons for common tasks
class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  static final _actions = [
    QuickAction(
      label: 'New Invoice',
      icon: Icons.receipt_long,
      route: '/invoices/new',
      colorBuilder: (scheme) => scheme.primary,
    ),
    QuickAction(
      label: 'Add Expense',
      icon: Icons.money_off,
      route: '/expenses/new',
      colorBuilder: (scheme) => scheme.error,
    ),
    QuickAction(
      label: 'Add Client',
      icon: Icons.person_add,
      route: '/clients/new',
      colorBuilder: (scheme) => scheme.tertiary,
    ),
    QuickAction(
      label: 'View Reports',
      icon: Icons.bar_chart,
      route: '/reports',
      colorBuilder: (scheme) => scheme.secondary,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                // Use 2 columns on narrow screens, 4 on wider screens
                final crossAxisCount = constraints.maxWidth < 300 ? 2 : 4;
                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: crossAxisCount == 2 ? 1.2 : 0.85,
                  children: _actions
                      .map((action) => _QuickActionButton(action: action))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final QuickAction action;

  const _QuickActionButton({required this.action});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = action.colorBuilder(theme.colorScheme);

    return Semantics(
      button: true,
      label: action.label,
      child: InkWell(
        onTap: () => context.push(action.route),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                action.icon,
                color: color,
                size: 28,
              ),
              const SizedBox(height: 4),
              Text(
                action.label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
