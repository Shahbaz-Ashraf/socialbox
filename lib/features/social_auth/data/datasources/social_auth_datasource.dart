import 'package:flutter/foundation.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../../../core/utils/platform_utils.dart';

/// Manages secure storage of OAuth tokens and credentials.
class SocialAuthDataSource {
  SocialAuthDataSource(this._storage);
  final SecureStorageService _storage;

  // We piggyback on SecureStorageService with platform-prefixed keys to keep
  // everything in one encrypted bucket.
  String _clientIdKey(String p) => '${AppConstants.oauthTokenPrefix}${p}_cid';
  String _clientSecretKey(String p) =>
      '${AppConstants.oauthTokenPrefix}${p}_cs';

  Future<Map<String, OAuthTokenModel>> getAllStored() =>
      _storage.getAllTokens();

  Future<OAuthTokenModel?> getToken(SocialPlatform platform) =>
      _storage.getToken(platform.name);

  Future<void> save(SocialPlatform platform, OAuthTokenModel token) =>
      _storage.saveToken(platform.name, token);

  Future<void> delete(SocialPlatform platform) async {
    await _storage.deleteToken(platform.name);
    await _storage.delete(_clientIdKey(platform.name));
    await _storage.delete(_clientSecretKey(platform.name));
  }

  Future<void> saveCredentials(
    SocialPlatform platform, {
    required String clientId,
    String? clientSecret,
  }) async {
    await _storage.save(_clientIdKey(platform.name), clientId);
    if (clientSecret != null && clientSecret.isNotEmpty) {
      await _storage.save(_clientSecretKey(platform.name), clientSecret);
    }
  }

  Future<String?> clientIdFor(SocialPlatform platform) async {
    final v = await _storage.read(_clientIdKey(platform.name));
    if (kDebugMode && v == null) {
      debugPrint('No client id stored for ${platform.name}');
    }
    return v;
  }

  Future<String?> clientSecretFor(SocialPlatform platform) async =>
      _storage.read(_clientSecretKey(platform.name));
}
