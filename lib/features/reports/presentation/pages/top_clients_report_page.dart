import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../application/providers/reports_providers.dart';
import '../../domain/models/income_report.dart';

/// Top Clients Report Page
class TopClientsReportPage extends ConsumerWidget {
  const TopClientsReportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportState = ref.watch(topClientsReportProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Clients'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(topClientsReportProvider.notifier).refresh();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Date range selector
          _DateRangeSelector(
            selectedPreset: reportState.preset,
            dateRange: reportState.dateRange,
            onPresetChanged: (preset) {
              ref.read(topClientsReportProvider.notifier).setPreset(preset);
            },
            onCustomDateRange: () async {
              final now = DateTime.now();
              final clampedStart = reportState.dateRange.start.isAfter(now)
                  ? now
                  : reportState.dateRange.start;
              final clampedEnd = reportState.dateRange.end.isAfter(now)
                  ? now
                  : reportState.dateRange.end;
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: now,
                initialDateRange: DateTimeRange(
                  start: clampedStart,
                  end: clampedEnd,
                ),
              );
              if (picked != null) {
                ref
                    .read(topClientsReportProvider.notifier)
                    .setCustomDateRange(picked);
              }
            },
          ),
          const Divider(height: 1),
          // Report content
          Expanded(
            child: reportState.clients.when(
              data: (clients) => _ReportContent(
                clients: clients,
                totalRevenue: reportState.totalRevenue,
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 48, color: theme.colorScheme.error),
                    const SizedBox(height: 16),
                    Text('Failed to load report',
                        style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        ref.read(topClientsReportProvider.notifier).refresh();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateRangeSelector extends StatelessWidget {
  final DateRangePreset selectedPreset;
  final DateTimeRange dateRange;
  final ValueChanged<DateRangePreset> onPresetChanged;
  final VoidCallback onCustomDateRange;

  const _DateRangeSelector({
    required this.selectedPreset,
    required this.dateRange,
    required this.onPresetChanged,
    required this.onCustomDateRange,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMMMd();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: DateRangePreset.values.map((preset) {
                final isSelected = preset == selectedPreset;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(preset.displayName),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (preset == DateRangePreset.custom) {
                        onCustomDateRange();
                      } else {
                        onPresetChanged(preset);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${dateFormat.format(dateRange.start)} - ${dateFormat.format(dateRange.end)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportContent extends StatelessWidget {
  final List<ClientRevenue> clients;
  final double totalRevenue;

  const _ReportContent({
    required this.clients,
    required this.totalRevenue,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: r'$');

    if (clients.isEmpty) {
      return _EmptyState();
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary card
        _SummaryCard(
          totalRevenue: totalRevenue,
          clientCount: clients.length,
          currencyFormat: currencyFormat,
        ),
        const SizedBox(height: 24),
        // Pie chart
        _PieChartSection(
          clients: clients,
          totalRevenue: totalRevenue,
          currencyFormat: currencyFormat,
        ),
        const SizedBox(height: 24),
        // Client table
        _ClientTable(
          clients: clients,
          totalRevenue: totalRevenue,
          currencyFormat: currencyFormat,
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No client data for this period',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Create and mark invoices as paid to see your top clients',
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final double totalRevenue;
  final int clientCount;
  final NumberFormat currencyFormat;

  const _SummaryCard({
    required this.totalRevenue,
    required this.clientCount,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Revenue',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currencyFormat.format(totalRevenue),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              height: 50,
              color: theme.dividerColor,
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    'Active Clients',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$clientCount',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PieChartSection extends StatelessWidget {
  final List<ClientRevenue> clients;
  final double totalRevenue;
  final NumberFormat currencyFormat;

  const _PieChartSection({
    required this.clients,
    required this.totalRevenue,
    required this.currencyFormat,
  });

  static const List<Color> _chartColors = [
    Color(0xFF2196F3), // Blue
    Color(0xFF4CAF50), // Green
    Color(0xFFFFC107), // Amber
    Color(0xFFE91E63), // Pink
    Color(0xFF9C27B0), // Purple
    Color(0xFF00BCD4), // Cyan
    Color(0xFFFF5722), // Deep Orange
    Color(0xFF795548), // Brown
    Color(0xFF607D8B), // Blue Grey
    Color(0xFF3F51B5), // Indigo
  ];

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
              'Revenue Distribution',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: _getSections(),
                        pieTouchData: PieTouchData(
                          touchCallback: (event, response) {},
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Legend
                  SizedBox(
                    width: 120,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: clients.take(5).toList().asMap().entries.map(
                        (entry) {
                          final index = entry.key;
                          final client = entry.value;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: _chartColors[
                                        index % _chartColors.length],
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    client.clientName,
                                    style: theme.textTheme.bodySmall,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _getSections() {
    // Show top 5 individually, group rest as "Others"
    final topClients = clients.take(5).toList();
    final otherRevenue =
        clients.skip(5).fold(0.0, (sum, c) => sum + c.totalRevenue);

    final sections = <PieChartSectionData>[];

    for (var i = 0; i < topClients.length; i++) {
      final client = topClients[i];
      final percentage =
          totalRevenue > 0 ? (client.totalRevenue / totalRevenue) * 100 : 0;
      sections.add(
        PieChartSectionData(
          color: _chartColors[i % _chartColors.length],
          value: client.totalRevenue,
          title: '${percentage.toStringAsFixed(0)}%',
          radius: 50,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    // Add "Others" section if there are more than 5 clients
    if (otherRevenue > 0) {
      final percentage =
          totalRevenue > 0 ? (otherRevenue / totalRevenue) * 100 : 0;
      sections.add(
        PieChartSectionData(
          color: Colors.grey,
          value: otherRevenue,
          title: '${percentage.toStringAsFixed(0)}%',
          radius: 50,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    return sections;
  }
}

class _ClientTable extends StatelessWidget {
  final List<ClientRevenue> clients;
  final double totalRevenue;
  final NumberFormat currencyFormat;

  const _ClientTable({
    required this.clients,
    required this.totalRevenue,
    required this.currencyFormat,
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
              'Client Rankings',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Header
            Row(
              children: [
                const SizedBox(width: 32), // Rank column
                const Expanded(flex: 3, child: Text('Client')),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Revenue',
                    textAlign: TextAlign.right,
                    style: TextStyle(color: Colors.green.shade700),
                  ),
                ),
                const Expanded(
                  flex: 1,
                  child: Text(
                    '%',
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const Divider(),
            // Data rows
            ...clients.asMap().entries.map((entry) {
              final rank = entry.key + 1;
              final client = entry.value;
              final percentage = totalRevenue > 0
                  ? (client.totalRevenue / totalRevenue) * 100
                  : 0;

              return InkWell(
                onTap: () {
                  context.push('/clients/${client.clientId}');
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 32,
                        child: Text(
                          '#$rank',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: rank <= 3
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              client.clientName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Text(
                              '${client.invoiceCount} invoice${client.invoiceCount == 1 ? '' : 's'}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          currencyFormat.format(client.totalRevenue),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          '${percentage.toStringAsFixed(0)}%',
                          textAlign: TextAlign.right,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
