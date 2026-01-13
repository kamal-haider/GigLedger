import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/application/providers/auth_providers.dart';
import '../features/auth/presentation/pages/email_sign_in_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/clients/presentation/pages/client_list_page.dart';
import '../features/expenses/presentation/pages/expense_list_page.dart';
import '../features/settings/presentation/pages/business_profile_page.dart';
import 'main_scaffold.dart';

/// Router provider for the app
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isOnAuthPage = state.matchedLocation == '/login' ||
          state.matchedLocation == '/email-sign-in';

      // If not logged in and not on an auth page, redirect to login
      if (!isLoggedIn && !isOnAuthPage) {
        return '/login';
      }

      // If logged in and on an auth page, redirect to dashboard
      if (isLoggedIn && isOnAuthPage) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      // Auth routes (outside shell)
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/email-sign-in',
        name: 'email-sign-in',
        builder: (context, state) => const EmailSignInPage(),
      ),

      // Main app shell with bottom navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScaffold(
            currentIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) {
              navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              );
            },
            child: navigationShell,
          );
        },
        branches: [
          // Dashboard branch (index 0)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                name: 'dashboard',
                builder: (context, state) => const DashboardPage(),
              ),
            ],
          ),

          // Invoices branch (index 1)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/invoices',
                name: 'invoices',
                builder: (context, state) => const InvoicesPage(),
                routes: [
                  GoRoute(
                    path: 'new',
                    name: 'new-invoice',
                    builder: (context, state) => const PlaceholderScreen(
                      title: 'New Invoice',
                      message: 'Create invoice screen coming soon',
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Expenses branch (index 2)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/expenses',
                name: 'expenses',
                builder: (context, state) => const ExpenseListPage(),
                routes: [
                  GoRoute(
                    path: 'new',
                    name: 'new-expense',
                    builder: (context, state) => const PlaceholderScreen(
                      title: 'New Expense',
                      message: 'Add expense screen coming soon',
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Clients branch (index 3)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/clients',
                name: 'clients',
                builder: (context, state) => const ClientListPage(),
                routes: [
                  GoRoute(
                    path: 'new',
                    name: 'new-client',
                    builder: (context, state) => const PlaceholderScreen(
                      title: 'New Client',
                      message: 'Add client screen coming soon',
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Settings branch (index 4)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                name: 'settings',
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),

      // Root redirect
      GoRoute(
        path: '/',
        name: 'home',
        redirect: (context, state) => '/dashboard',
      ),
    ],
    errorBuilder: (context, state) => PlaceholderScreen(
      title: 'Error',
      message: 'Page not found: ${state.uri}',
    ),
  );
});

/// Dashboard page - placeholder for now
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.dashboard,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Dashboard coming soon',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Financial overview, quick actions, and recent activity',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Invoices page - placeholder for now
class InvoicesPage extends StatelessWidget {
  const InvoicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.goNamed('new-invoice'),
        icon: const Icon(Icons.add),
        label: const Text('New Invoice'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Invoices coming soon',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Create, send, and track invoices',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Settings page - wraps BusinessProfilePage for now
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const BusinessProfilePage();
  }
}

/// Placeholder screen for routes that haven't been implemented yet
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    required this.title,
    required this.message,
    super.key,
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
