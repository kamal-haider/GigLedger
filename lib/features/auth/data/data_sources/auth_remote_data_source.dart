import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/error/exceptions.dart';
import '../dto/user_profile_dto.dart';

/// Remote data source for authentication operations
abstract class AuthRemoteDataSource {
  /// Get the current Firebase user
  User? get currentUser;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges;

  /// Sign in with Google
  Future<UserProfileDTO> signInWithGoogle();

  /// Sign in with email and password
  Future<UserProfileDTO> signInWithEmail(String email, String password);

  /// Create account with email and password
  Future<UserProfileDTO> createAccountWithEmail(String email, String password);

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email);

  /// Sign out
  Future<void> signOut();

  /// Get user profile from Firestore
  Future<UserProfileDTO?> getUserProfile(String uid);

  /// Create or update user profile in Firestore
  Future<UserProfileDTO> saveUserProfile(UserProfileDTO profile);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthRemoteDataSourceImpl({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  Future<UserProfileDTO> signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In flow
      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw const AuthException(
          'Google sign-in was cancelled',
          code: 'sign-in-cancelled',
        );
      }

      // Obtain the auth details from the request
      final googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      final user = userCredential.user;
      if (user == null) {
        throw const AuthException(
          'Failed to sign in with Google',
          code: 'sign-in-failed',
        );
      }

      // Check if user profile exists, create if not
      final existingProfile = await getUserProfile(user.uid);
      if (existingProfile != null) {
        // Update the profile with latest info from Google
        return saveUserProfile(
          UserProfileDTO(
            id: user.uid,
            email: user.email,
            displayName: existingProfile.displayName ?? user.displayName,
            businessName: existingProfile.businessName,
            businessLogo: existingProfile.businessLogo,
            businessAddress: existingProfile.businessAddress,
            currency: existingProfile.currency,
            taxRate: existingProfile.taxRate,
            paymentInstructions: existingProfile.paymentInstructions,
            createdAt: existingProfile.createdAt,
            updatedAt: Timestamp.now(),
          ),
        );
      }

      // Create new profile for first-time users
      final now = Timestamp.now();
      return saveUserProfile(
        UserProfileDTO(
          id: user.uid,
          email: user.email,
          displayName: user.displayName,
          currency: 'USD',
          taxRate: 0,
          createdAt: now,
          updatedAt: now,
        ),
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        e.message ?? 'Authentication failed',
        code: e.code,
      );
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(
        'Failed to sign in with Google: $e',
        code: 'unknown',
      );
    }
  }

  @override
  Future<UserProfileDTO> signInWithEmail(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw const AuthException(
          'Failed to sign in',
          code: 'sign-in-failed',
        );
      }

      // Get existing profile
      final existingProfile = await getUserProfile(user.uid);
      if (existingProfile != null) {
        return existingProfile;
      }

      // Create profile if it doesn't exist (shouldn't happen normally)
      final now = Timestamp.now();
      return saveUserProfile(
        UserProfileDTO(
          id: user.uid,
          email: user.email,
          currency: 'USD',
          taxRate: 0,
          createdAt: now,
          updatedAt: now,
        ),
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        _getEmailAuthErrorMessage(e.code),
        code: e.code,
      );
    } catch (e) {
      throw AuthException(
        'Failed to sign in: $e',
        code: 'unknown',
      );
    }
  }

  @override
  Future<UserProfileDTO> createAccountWithEmail(
      String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw const AuthException(
          'Failed to create account',
          code: 'account-creation-failed',
        );
      }

      // Create new profile
      final now = Timestamp.now();
      return saveUserProfile(
        UserProfileDTO(
          id: user.uid,
          email: user.email,
          currency: 'USD',
          taxRate: 0,
          createdAt: now,
          updatedAt: now,
        ),
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        _getEmailAuthErrorMessage(e.code),
        code: e.code,
      );
    } catch (e) {
      throw AuthException(
        'Failed to create account: $e',
        code: 'unknown',
      );
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        _getEmailAuthErrorMessage(e.code),
        code: e.code,
      );
    } catch (e) {
      throw AuthException(
        'Failed to send password reset email: $e',
        code: 'unknown',
      );
    }
  }

  /// Convert Firebase error codes to user-friendly messages
  String _getEmailAuthErrorMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Use at least 8 characters.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw AuthException(
        'Failed to sign out: $e',
        code: 'sign-out-failed',
      );
    }
  }

  @override
  Future<UserProfileDTO?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return UserProfileDTO.fromJson(doc.data()!, doc.id);
    } catch (e) {
      throw ServerException(
        'Failed to get user profile: $e',
        code: 'firestore-read-error',
      );
    }
  }

  @override
  Future<UserProfileDTO> saveUserProfile(UserProfileDTO profile) async {
    try {
      final docRef = _firestore.collection('users').doc(profile.id);

      await docRef.set(
        profile.toJson(),
        SetOptions(merge: true),
      );

      // Return the saved profile
      final doc = await docRef.get();
      return UserProfileDTO.fromJson(doc.data()!, doc.id);
    } catch (e) {
      throw ServerException(
        'Failed to save user profile: $e',
        code: 'firestore-write-error',
      );
    }
  }
}
