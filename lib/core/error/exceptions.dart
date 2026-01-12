/// Base exception class for data layer errors
abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, {this.code});

  @override
  String toString() => 'AppException: $message${code != null ? ' ($code)' : ''}';
}

/// Server/network exceptions
class ServerException extends AppException {
  final int? statusCode;

  const ServerException(super.message, {super.code, this.statusCode});
}

/// Authentication exceptions
class AuthException extends AppException {
  const AuthException(super.message, {super.code});
}

/// Cache exceptions
class CacheException extends AppException {
  const CacheException(super.message, {super.code});
}

/// Validation exceptions
class ValidationException extends AppException {
  const ValidationException(super.message, {super.code});
}

/// Not found exceptions
class NotFoundException extends AppException {
  const NotFoundException(super.message, {super.code});
}

/// Permission exceptions
class PermissionException extends AppException {
  const PermissionException(super.message, {super.code});
}

/// Format exceptions (parsing errors)
class FormatException extends AppException {
  const FormatException(super.message, {super.code});
}
