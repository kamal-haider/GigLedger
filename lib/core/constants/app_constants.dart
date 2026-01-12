/// Application-wide constants
class AppConstants {
  AppConstants._();

  /// App name
  static const appName = 'GigLedger';

  /// App version
  static const appVersion = '1.0.0';

  /// Free tier limits
  static const freeClientLimit = 5;
  static const freeInvoicesPerMonth = 10;
  static const freeExpensesPerMonth = 20;

  /// Pro tier limits (unlimited)
  static const proClientLimit = -1; // -1 means unlimited
  static const proInvoicesPerMonth = -1;
  static const proExpensesPerMonth = -1;

  /// Default values
  static const defaultCurrency = 'USD';
  static const defaultTaxRate = 0.0;
  static const defaultDueDays = 30;

  /// Invoice number format
  static const invoiceNumberPrefix = 'INV-';

  /// Supported currencies
  static const supportedCurrencies = [
    'USD',
    'EUR',
    'GBP',
    'CAD',
    'AUD',
    'JPY',
    'INR',
  ];

  /// Date formats
  static const dateFormats = [
    'MM/dd/yyyy',
    'dd/MM/yyyy',
    'yyyy-MM-dd',
  ];

  /// Animation durations
  static const shortAnimationDuration = Duration(milliseconds: 200);
  static const mediumAnimationDuration = Duration(milliseconds: 300);
  static const longAnimationDuration = Duration(milliseconds: 500);

  /// Page sizes
  static const defaultPageSize = 20;
  static const recentActivityLimit = 5;

  /// Cache durations
  static const cacheValidDuration = Duration(minutes: 5);
}

/// Currency symbols
class CurrencySymbols {
  CurrencySymbols._();

  static const Map<String, String> symbols = {
    'USD': '\$',
    'EUR': '\u20AC',
    'GBP': '\u00A3',
    'CAD': 'C\$',
    'AUD': 'A\$',
    'JPY': '\u00A5',
    'INR': '\u20B9',
  };

  static String getSymbol(String currencyCode) {
    return symbols[currencyCode] ?? currencyCode;
  }
}
