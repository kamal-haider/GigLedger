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
