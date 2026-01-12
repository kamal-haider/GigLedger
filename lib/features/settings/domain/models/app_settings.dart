import 'package:flutter/foundation.dart';

/// App settings and user preferences
@immutable
class AppSettings {
  final bool notificationsEnabled;
  final bool weeklyReportEnabled;
  final bool overdueRemindersEnabled;
  final String dateFormat;
  final String currencyFormat;
  final bool darkMode;

  const AppSettings({
    this.notificationsEnabled = true,
    this.weeklyReportEnabled = false,
    this.overdueRemindersEnabled = true,
    this.dateFormat = 'MM/dd/yyyy',
    this.currencyFormat = '#,##0.00',
    this.darkMode = false,
  });

  static const defaults = AppSettings();

  AppSettings copyWith({
    bool? notificationsEnabled,
    bool? weeklyReportEnabled,
    bool? overdueRemindersEnabled,
    String? dateFormat,
    String? currencyFormat,
    bool? darkMode,
  }) {
    return AppSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      weeklyReportEnabled: weeklyReportEnabled ?? this.weeklyReportEnabled,
      overdueRemindersEnabled:
          overdueRemindersEnabled ?? this.overdueRemindersEnabled,
      dateFormat: dateFormat ?? this.dateFormat,
      currencyFormat: currencyFormat ?? this.currencyFormat,
      darkMode: darkMode ?? this.darkMode,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettings &&
          runtimeType == other.runtimeType &&
          notificationsEnabled == other.notificationsEnabled &&
          weeklyReportEnabled == other.weeklyReportEnabled &&
          darkMode == other.darkMode;

  @override
  int get hashCode =>
      notificationsEnabled.hashCode ^
      weeklyReportEnabled.hashCode ^
      darkMode.hashCode;
}
