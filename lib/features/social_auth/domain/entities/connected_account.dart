import 'package:equatable/equatable.dart';

import '../../../../core/services/secure_storage_service.dart';
import '../../../../core/utils/platform_utils.dart';

class ConnectedAccount extends Equatable {
  const ConnectedAccount({
    required this.platform,
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

  final SocialPlatform platform;
  final String accessToken;
  final String? refreshToken;
  final DateTime? expiresAt;
  final String? userId;
  final String? username;
  final String? displayName;
  final String? avatarUrl;
  final String? pageId;
  final String? pageToken;

  bool get isExpired =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now());

  bool get isConnected => accessToken.isNotEmpty;

  factory ConnectedAccount.fromToken(
      SocialPlatform platform, OAuthTokenModel token) {
    return ConnectedAccount(
      platform: platform,
      accessToken: token.accessToken,
      refreshToken: token.refreshToken,
      expiresAt: token.expiresAt,
      userId: token.userId,
      username: token.username,
      displayName: token.displayName,
      avatarUrl: token.avatarUrl,
      pageId: token.pageId,
      pageToken: token.pageToken,
    );
  }

  @override
  List<Object?> get props => [
        platform,
        accessToken,
        expiresAt,
        username,
        displayName,
        pageId,
      ];
}
