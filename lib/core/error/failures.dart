/// Base failure class for domain layer errors
abstract class Failure {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  String toString() => 'Failure: $message${code != null ? ' ($code)' : ''}';
}

/// Server/network related failures
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});
}

/// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code});

  static const invalidCredentials = AuthFailure(
    'Invalid email or password',
    code: 'invalid-credentials',
  );

  static const userNotFound = AuthFailure(
    'No account found with this email',
    code: 'user-not-found',
  );

  static const emailInUse = AuthFailure(
    'An account already exists with this email',
    code: 'email-already-in-use',
  );

  static const weakPassword = AuthFailure(
    'Password is too weak',
    code: 'weak-password',
  );

  static const notAuthenticated = AuthFailure(
    'You must be signed in to perform this action',
    code: 'not-authenticated',
  );
}

/// Cache/local storage failures
class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code});
}

/// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code});
}

/// Permission/quota failures
class QuotaFailure extends Failure {
  final int currentCount;
  final int maxCount;

  const QuotaFailure(
    super.message, {
    required this.currentCount,
    required this.maxCount,
    super.code,
  });

  static QuotaFailure clientLimit(int current, int max) => QuotaFailure(
        'You have reached your client limit ($current/$max)',
        currentCount: current,
        maxCount: max,
        code: 'client-limit',
      );

  static QuotaFailure invoiceLimit(int current, int max) => QuotaFailure(
        'You have reached your monthly invoice limit ($current/$max)',
        currentCount: current,
        maxCount: max,
        code: 'invoice-limit',
      );

  static QuotaFailure expenseLimit(int current, int max) => QuotaFailure(
        'You have reached your monthly expense limit ($current/$max)',
        currentCount: current,
        maxCount: max,
        code: 'expense-limit',
      );
}

/// Not found failures
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, {super.code});
}
