import 'dart:developer' as dev;

import 'package:google_sign_in/google_sign_in.dart';

import 'package:productivity/core/error/exceptions.dart';
import 'package:productivity/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:productivity/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:productivity/features/auth/data/models/login_request.dart';
import 'package:productivity/features/auth/data/models/register_request.dart';
import 'package:productivity/features/auth/domain/entities/user_entity.dart';
import 'package:productivity/features/auth/domain/repositories/auth_repository.dart';

/// Implementation of [AuthRepository].
///
/// Coordinates between remote and local data sources to
/// handle authentication flow.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final GoogleSignIn _googleSignIn;

  const AuthRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._googleSignIn,
  );

  @override
  Future<({UserEntity user, String token})> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final result = await _remoteDataSource.register(
      RegisterRequest(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      ),
    );
    await _localDataSource.saveToken(result.token);
    await _localDataSource.cacheUser(result.user);
    return (user: result.user.toEntity(), token: result.token);
  }

  @override
  Future<({UserEntity user, String token})> login({
    required String email,
    required String password,
  }) async {
    final result = await _remoteDataSource.login(
      LoginRequest(email: email, password: password),
    );
    await _localDataSource.saveToken(result.token);
    await _localDataSource.cacheUser(result.user);
    return (user: result.user.toEntity(), token: result.token);
  }

  @override
  Future<({UserEntity user, String token, bool isNewUser})>
      loginWithGoogle() async {
    // 1. Trigger Google Sign-In (shows account picker).
    //    In v7+, authenticate() throws GoogleSignInException on cancel.
    dev.log('[GoogleAuth] Step 1: Starting authenticate()...', name: 'auth');
    final GoogleSignInAccount googleUser;
    try {
      googleUser = await _googleSignIn.authenticate();
      dev.log(
        '[GoogleAuth] Step 1 ✅: Got user ${googleUser.email} (id: ${googleUser.id})',
        name: 'auth',
      );
    } on GoogleSignInException catch (e) {
      dev.log(
        '[GoogleAuth] Step 1 ❌: GoogleSignInException code=${e.code}, desc=${e.description}',
        name: 'auth',
      );
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthCancelledException();
      }
      rethrow;
    }

    // 2. Get ID token (sync getter in v7+; requires serverClientId).
    final idToken = googleUser.authentication.idToken;
    dev.log(
      '[GoogleAuth] Step 2: idToken ${idToken != null ? "present (${idToken.length} chars)" : "NULL ⚠️"}',
      name: 'auth',
    );
    if (idToken == null) {
      throw const ServerException(
        'No se pudo obtener el token de Google. '
        'Verifica que serverClientId esté configurado.',
      );
    }

    // 3. Send to backend for verification + user creation/lookup
    dev.log('[GoogleAuth] Step 3: Sending idToken to backend...', name: 'auth');
    final result = await _remoteDataSource.loginWithGoogle(idToken);
    dev.log(
      '[GoogleAuth] Step 3 ✅: Backend returned user ${result.user.email}, isNew=${result.isNewUser}',
      name: 'auth',
    );

    // 4. Persist locally (same flow as email/password login)
    await _localDataSource.saveToken(result.token);
    await _localDataSource.cacheUser(result.user);
    dev.log('[GoogleAuth] Step 4 ✅: Token and user cached locally', name: 'auth');

    return (
      user: result.user.toEntity(),
      token: result.token,
      isNewUser: result.isNewUser,
    );
  }

  @override
  Future<void> logout() async {
    // Sign out from Google first (ensures account picker shows on next login)
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Non-critical — continue with logout even if Google signOut fails
    }

    try {
      await _remoteDataSource.logout();
    } finally {
      await _localDataSource.clearAll();
    }
  }

  @override
  Future<UserEntity> getMe() async {
    final userModel = await _remoteDataSource.getMe();
    await _localDataSource.cacheUser(userModel);
    return userModel.toEntity();
  }

  @override
  Future<bool> hasToken() async {
    final token = await _localDataSource.getToken();
    return token != null && token.isNotEmpty;
  }
}
