import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:productivity/core/constants/storage_keys.dart';
import 'package:productivity/core/error/exceptions.dart';
import 'package:productivity/core/utils/json_converters.dart';
import 'package:productivity/features/auth/data/models/user_model.dart';

/// Local data source for auth token and cached user management.
abstract class AuthLocalDataSource {
  /// Stores the auth token securely.
  Future<void> saveToken(String token);

  /// Retrieves the stored auth token.
  Future<String?> getToken();

  /// Removes the stored auth token.
  Future<void> deleteToken();

  /// Caches the user data locally.
  Future<void> cacheUser(UserModel user);

  /// Retrieves the cached user.
  Future<UserModel?> getCachedUser();

  /// Clears all local auth data.
  Future<void> clearAll();
}

/// Implementation using [FlutterSecureStorage] and [SharedPreferences].
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _prefs;

  const AuthLocalDataSourceImpl(this._secureStorage, this._prefs);

  @override
  Future<void> saveToken(String token) async {
    try {
      await _secureStorage.write(key: StorageKeys.authToken, value: token);
    } catch (_) {
      throw const CacheException('No se pudo guardar el token.');
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: StorageKeys.authToken);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> deleteToken() async {
    try {
      await _secureStorage.delete(key: StorageKeys.authToken);
    } catch (_) {
      throw const CacheException('No se pudo eliminar el token.');
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      final jsonString = safeJsonEncode(user.toJson());
      await _prefs.setString(StorageKeys.cachedUser, jsonString);
    } catch (_) {
      throw const CacheException('No se pudo guardar los datos del usuario.');
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final jsonString = _prefs.getString(StorageKeys.cachedUser);
      if (jsonString == null) return null;
      final json = safeJsonDecode(jsonString);
      if (json == null) return null;
      return UserModel.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearAll() async {
    await deleteToken();
    await _prefs.remove(StorageKeys.cachedUser);
  }
}
