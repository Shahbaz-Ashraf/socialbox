import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/app_constants.dart';

class OAuthTokenModel {
  OAuthTokenModel({
    required this.accessToken,
    this.refreshToken,
    this.expiresAt,
    this.userId,
    this.username,
    this.displayName,
    this.avatarUrl,
    this.pageId,
    this.pageToken,
  });

  final String accessToken;
  final String? refreshToken;
  final DateTime? expiresAt;
  final String? userId;
  final String? username;
  final String? displayName;
  final String? avatarUrl;
  final String? pageId;
  final String? pageToken;

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'expiresAt': expiresAt?.toIso8601String(),
        'userId': userId,
        'username': username,
        'displayName': displayName,
        'avatarUrl': avatarUrl,
        'pageId': pageId,
        'pageToken': pageToken,
      };

  factory OAuthTokenModel.fromJson(Map<String, dynamic> json) =>
      OAuthTokenModel(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String?,
        expiresAt: json['expiresAt'] != null
            ? DateTime.tryParse(json['expiresAt'] as String)
            : null,
        userId: json['userId'] as String?,
        username: json['username'] as String?,
        displayName: json['displayName'] as String?,
        avatarUrl: json['avatarUrl'] as String?,
        pageId: json['pageId'] as String?,
        pageToken: json['pageToken'] as String?,
      );

  bool get isExpired =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now());

  bool get isConnected => accessToken.isNotEmpty;
}

class SecureStorageService {
  SecureStorageService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String _key(String platform) => '${AppConstants.oauthTokenPrefix}$platform';

  Future<void> saveToken(String platform, OAuthTokenModel token) async {
    await _storage.write(key: _key(platform), value: jsonEncode(token.toJson()));
  }

  Future<OAuthTokenModel?> getToken(String platform) async {
    final raw = await _storage.read(key: _key(platform));
    if (raw == null) return null;
    try {
      return OAuthTokenModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteToken(String platform) async {
    await _storage.delete(key: _key(platform));
  }

  Future<void> save(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  Future<Map<String, OAuthTokenModel>> getAllTokens() async {
    final all = await _storage.readAll();
    final result = <String, OAuthTokenModel>{};
    for (final entry in all.entries) {
      if (!entry.key.startsWith(AppConstants.oauthTokenPrefix)) continue;
      try {
        final model = OAuthTokenModel.fromJson(
            jsonDecode(entry.value) as Map<String, dynamic>);
        result[entry.key.substring(AppConstants.oauthTokenPrefix.length)] =
            model;
      } catch (_) {}
    }
    return result;
  }
}
