import '../models/user_profile.dart';

/// Authentication repository interface
abstract class IAuthRepository {
  /// Get the current authenticated user's profile
  Future<UserProfile?> getCurrentUser();

  /// Stream of auth state changes
  Stream<UserProfile?> watchAuthState();

  /// Sign in with Google
  Future<UserProfile> signInWithGoogle();

  /// Sign in with Apple
  Future<UserProfile> signInWithApple();

  /// Sign in with email and password
  Future<UserProfile> signInWithEmail(String email, String password);

  /// Create account with email and password
  Future<UserProfile> createAccount(String email, String password);

  /// Send password reset email
  Future<void> sendPasswordReset(String email);

  /// Update user profile
  Future<UserProfile> updateProfile(UserProfile profile);

  /// Sign out
  Future<void> signOut();

  /// Delete account and all user data
  Future<void> deleteAccount();
}
