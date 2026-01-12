import '../models/app_settings.dart';

/// Settings repository interface
abstract class ISettingsRepository {
  /// Get current app settings
  Future<AppSettings> getSettings();

  /// Watch settings changes
  Stream<AppSettings> watchSettings();

  /// Update app settings
  Future<AppSettings> updateSettings(AppSettings settings);

  /// Reset settings to defaults
  Future<AppSettings> resetToDefaults();

  /// Clear all local cache
  Future<void> clearCache();

  /// Get cache size in bytes
  Future<int> getCacheSize();

  /// Export all user data
  Future<String> exportUserData();
}
