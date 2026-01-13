import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Quick action item data
class QuickAction {
  final String label;
  final IconData icon;
  final String route;
  final Color? color;

  const QuickAction({
    required this.label,
    required this.icon,
    required this.route,
    this.color,
  });
}

/// Grid of quick action buttons for common tasks
class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  static const _actions = [
    QuickAction(
      label: 'New Invoice',
      icon: Icons.receipt_long,
      route: '/invoices/new',
      color: Colors.blue,
    ),
    QuickAction(
      label: 'Add Expense',
      icon: Icons.money_off,
      route: '/expenses/new',
      color: Colors.red,
    ),
    QuickAction(
      label: 'Add Client',
      icon: Icons.person_add,
      route: '/clients/new',
      color: Colors.green,
    ),
    QuickAction(
      label: 'View Reports',
      icon: Icons.bar_chart,
      route: '/reports',
      color: Colors.orange,
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
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: _actions
                  .map((action) => _QuickActionButton(action: action))
                  .toList(),
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
    final color = action.color ?? theme.colorScheme.primary;

    return InkWell(
      onTap: () => context.push(action.route),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
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
    );
  }
}
