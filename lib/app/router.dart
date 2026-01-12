import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Router provider for the app
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const _PlaceholderScreen(
          title: 'GigLedger',
          message: 'Welcome to GigLedger!\nYour freelance business manager.',
        ),
      ),
      // Auth routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const _PlaceholderScreen(
          title: 'Login',
          message: 'Login screen coming soon',
        ),
      ),
      // Dashboard routes
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const _PlaceholderScreen(
          title: 'Dashboard',
          message: 'Dashboard screen coming soon',
        ),
      ),
      // Invoice routes
      GoRoute(
        path: '/invoices',
        name: 'invoices',
        builder: (context, state) => const _PlaceholderScreen(
          title: 'Invoices',
          message: 'Invoices list coming soon',
        ),
      ),
      GoRoute(
        path: '/invoices/new',
        name: 'new-invoice',
        builder: (context, state) => const _PlaceholderScreen(
          title: 'New Invoice',
          message: 'Create invoice screen coming soon',
        ),
      ),
      // Expense routes
      GoRoute(
        path: '/expenses',
        name: 'expenses',
        builder: (context, state) => const _PlaceholderScreen(
          title: 'Expenses',
          message: 'Expenses list coming soon',
        ),
      ),
      GoRoute(
        path: '/expenses/new',
        name: 'new-expense',
        builder: (context, state) => const _PlaceholderScreen(
          title: 'New Expense',
          message: 'Add expense screen coming soon',
        ),
      ),
      // Client routes
      GoRoute(
        path: '/clients',
        name: 'clients',
        builder: (context, state) => const _PlaceholderScreen(
          title: 'Clients',
          message: 'Clients list coming soon',
        ),
      ),
      GoRoute(
        path: '/clients/new',
        name: 'new-client',
        builder: (context, state) => const _PlaceholderScreen(
          title: 'New Client',
          message: 'Add client screen coming soon',
        ),
      ),
      // Reports routes
      GoRoute(
        path: '/reports',
        name: 'reports',
        builder: (context, state) => const _PlaceholderScreen(
          title: 'Reports',
          message: 'Reports screen coming soon',
        ),
      ),
      // Settings routes
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const _PlaceholderScreen(
          title: 'Settings',
          message: 'Settings screen coming soon',
        ),
      ),
    ],
    errorBuilder: (context, state) => _PlaceholderScreen(
      title: 'Error',
      message: 'Page not found: ${state.uri}',
    ),
  );
});

/// Placeholder screen for routes that haven't been implemented yet
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.construction,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
