import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../data_sources/auth_remote_data_source.dart';
import '../dto/user_profile_dto.dart';

/// Implementation of IAuthRepository using Firebase
class AuthRepositoryImpl implements IAuthRepository {
  final AuthRemoteDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  Future<UserProfile?> getCurrentUser() async {
    final user = _dataSource.currentUser;
    if (user == null) {
      return null;
    }

    try {
      final dto = await _dataSource.getUserProfile(user.uid);
      return dto?.toDomain();
    } on ServerException {
      return null;
    }
  }

  @override
  Stream<UserProfile?> watchAuthState() {
    return _dataSource.authStateChanges.asyncMap((user) async {
      if (user == null) {
        return null;
      }

      try {
        final dto = await _dataSource.getUserProfile(user.uid);
        return dto?.toDomain();
      } catch (e) {
        return null;
      }
    });
  }

  @override
  Future<UserProfile> signInWithGoogle() async {
    try {
      final dto = await _dataSource.signInWithGoogle();
      return dto.toDomain();
    } on AuthException catch (e) {
      throw AuthFailure(e.message, code: e.code);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, code: e.code);
    }
  }

  @override
  Future<UserProfile> signInWithApple() async {
    // TODO: Implement in Apple Sign-In issue #2
    throw const AuthFailure(
      'Apple Sign-In not implemented yet',
      code: 'not-implemented',
    );
  }

  @override
  Future<UserProfile> signInWithEmail(String email, String password) async {
    try {
      final dto = await _dataSource.signInWithEmail(email, password);
      return dto.toDomain();
    } on AuthException catch (e) {
      throw AuthFailure(e.message, code: e.code);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, code: e.code);
    }
  }

  @override
  Future<UserProfile> createAccount(String email, String password) async {
    try {
      final dto = await _dataSource.createAccountWithEmail(email, password);
      return dto.toDomain();
    } on AuthException catch (e) {
      throw AuthFailure(e.message, code: e.code);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, code: e.code);
    }
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _dataSource.sendPasswordResetEmail(email);
    } on AuthException catch (e) {
      throw AuthFailure(e.message, code: e.code);
    }
  }

  @override
  Future<UserProfile> updateProfile(UserProfile profile) async {
    try {
      final dto = UserProfileDTO.fromDomain(profile);
      final savedDto = await _dataSource.saveUserProfile(dto);
      return savedDto.toDomain();
    } on ServerException catch (e) {
      throw ServerFailure(e.message, code: e.code);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _dataSource.signOut();
    } on AuthException catch (e) {
      throw AuthFailure(e.message, code: e.code);
    }
  }

  @override
  Future<void> deleteAccount() async {
    // TODO: Implement account deletion
    throw const AuthFailure(
      'Account deletion not implemented yet',
      code: 'not-implemented',
    );
  }
}
