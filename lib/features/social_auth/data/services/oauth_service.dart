import 'dart:async';
import 'dart:convert';

import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:http/http.dart' as http;

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../../../core/utils/platform_utils.dart';
import '../deep_link_handler.dart';

/// Performs the full OAuth 2.0 Authorization Code flow using
/// `flutter_appauth` (handles browser launch + PKCE + deep link callback)
/// and exchanges the code for an access token via platform-specific
/// token endpoints.
class OAuthService {
  OAuthService({
    FlutterAppAuth? appAuth,
    DeepLinkHandler? deepLinkHandler,
  })  : _appAuth = appAuth ?? const FlutterAppAuth(),
        _deepLinkHandler = deepLinkHandler ?? DeepLinkHandler();

  final FlutterAppAuth _appAuth;
  final DeepLinkHandler _deepLinkHandler;

  static const _scopes = {
    SocialPlatform.twitter: ApiEndpoints.twitterScopes,
    SocialPlatform.linkedin: ApiEndpoints.linkedinScopes,
    SocialPlatform.facebook: ApiEndpoints.facebookScopes,
  };

  String _redirectFor(SocialPlatform p) => switch (p) {
        SocialPlatform.twitter => AppConstants.twitterRedirect,
        SocialPlatform.linkedin => AppConstants.linkedinRedirect,
        SocialPlatform.facebook => AppConstants.facebookRedirect,
      };

  String _tokenUrlFor(SocialPlatform p) => switch (p) {
        SocialPlatform.twitter => ApiEndpoints.twitterTokenUrl,
        SocialPlatform.linkedin => ApiEndpoints.linkedinTokenUrl,
        SocialPlatform.facebook => ApiEndpoints.facebookTokenUrl,
      };

  String _authUrlFor(SocialPlatform p) => switch (p) {
        SocialPlatform.twitter => ApiEndpoints.twitterAuthUrl,
        SocialPlatform.linkedin => ApiEndpoints.linkedinAuthUrl,
        SocialPlatform.facebook => ApiEndpoints.facebookAuthUrl,
      };

  /// Launches the in-app auth flow. Returns null if the user cancels.
  Future<OAuthTokenModel?> authorizeAndExchange({
    required SocialPlatform platform,
    required String clientId,
    String? clientSecret,
  }) async {
    final redirect = _redirectFor(platform);
    final scopes = _scopes[platform] ?? const [];

    // Use flutter_appauth for Twitter (PKCE-only). For LinkedIn/Facebook
    // fall back to manual code-grant since their endpoints differ.
    if (platform == SocialPlatform.twitter) {
      return _authorizeTwitter(
        clientId: clientId,
        redirect: redirect,
        scopes: scopes,
      );
    }

    return _authorizeWithCodeExchange(
      platform: platform,
      clientId: clientId,
      clientSecret: clientSecret,
      redirect: redirect,
      scopes: scopes,
    );
  }

  Future<OAuthTokenModel?> _authorizeTwitter({
    required String clientId,
    required String redirect,
    required List<String> scopes,
  }) async {
    try {
      final result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          clientId,
          redirect,
          serviceConfiguration: AuthorizationServiceConfiguration(
            authorizationEndpoint: _authUrlFor(SocialPlatform.twitter),
            tokenEndpoint: _tokenUrlFor(SocialPlatform.twitter),
          ),
          scopes: scopes,
          preferEphemeralSession: true,
        ),
      );
      return _tokenFromAppAuth(result);
    } catch (_) {
      return null;
    }
  }

  Future<OAuthTokenModel?> _authorizeWithCodeExchange({
    required SocialPlatform platform,
    required String clientId,
    String? clientSecret,
    required String redirect,
    required List<String> scopes,
  }) async {
    final completer = Completer<Uri?>();
    final sub = _deepLinkHandler.listenForRedirect(redirect, (uri) {
      if (!completer.isCompleted) completer.complete(uri);
    });

    try {
      final result = await _appAuth.authorize(
        AuthorizationRequest(
          clientId,
          redirect,
          serviceConfiguration: AuthorizationServiceConfiguration(
            authorizationEndpoint: _authUrlFor(platform),
            tokenEndpoint: _tokenUrlFor(platform),
          ),
          scopes: scopes,
          preferEphemeralSession: true,
        ),
      );
      if (result.authorizationCode == null) {
        return null;
      }
      return await _exchangeCodeForToken(
        platform: platform,
        code: result.authorizationCode!,
        clientId: clientId,
        clientSecret: clientSecret,
        redirect: redirect,
        tokenEndpoint: _tokenUrlFor(platform),
      );
    } catch (_) {
      return null;
    } finally {
      await sub.cancel();
    }
  }

  Future<OAuthTokenModel?> _exchangeCodeForToken({
    required SocialPlatform platform,
    required String code,
    required String clientId,
    String? clientSecret,
    required String redirect,
    required String tokenEndpoint,
  }) async {
    final body = <String, String>{
      'grant_type': 'authorization_code',
      'code': code,
      'redirect_uri': redirect,
      'client_id': clientId,
      if (clientSecret != null && clientSecret.isNotEmpty)
        'client_secret': clientSecret,
    };
    try {
      final resp = await http.post(
        Uri.parse(tokenEndpoint),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: body,
      );
      if (resp.statusCode != 200) return null;
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final access = data['access_token'] as String?;
      if (access == null) return null;
      final expiresIn = (data['expires_in'] as num?)?.toInt() ?? 3600;
      return OAuthTokenModel(
        accessToken: access,
        refreshToken: data['refresh_token'] as String?,
        expiresAt: DateTime.now().add(Duration(seconds: expiresIn)),
        userId: data['user_id'] as String?,
      );
    } catch (_) {
      return null;
    }
  }

  OAuthTokenModel _tokenFromAppAuth(AuthorizationTokenResponse r) {
    return OAuthTokenModel(
      accessToken: r.accessToken ?? '',
      refreshToken: r.refreshToken,
      expiresAt: r.accessTokenExpirationDateTime,
    );
  }

  /// Fetches profile details and merges them into [token] when possible.
  Future<OAuthTokenModel> enrichWithProfile(
    SocialPlatform platform,
    OAuthTokenModel token,
  ) async {
    if (platform == SocialPlatform.twitter) {
      return _fetchTwitterProfile(token);
    }
    if (platform == SocialPlatform.linkedin) {
      return _fetchLinkedInProfile(token);
    }
    return token;
  }

  Future<OAuthTokenModel> _fetchTwitterProfile(OAuthTokenModel token) async {
    try {
      final resp = await http.get(
        Uri.parse(
          '${ApiEndpoints.twitterUserMe}?user.fields=profile_image_url',
        ),
        headers: {
          'Authorization': 'Bearer ${token.accessToken}',
          'Accept': 'application/json',
        },
      );
      if (resp.statusCode != 200) return token;
      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>?;
      if (data == null) return token;
      return OAuthTokenModel(
        accessToken: token.accessToken,
        refreshToken: token.refreshToken,
        expiresAt: token.expiresAt,
        userId: data['id'] as String? ?? token.userId,
        username: data['username'] as String? ?? token.username,
        displayName: data['name'] as String? ?? token.displayName,
        avatarUrl: data['profile_image_url'] as String? ?? token.avatarUrl,
        pageId: token.pageId,
        pageToken: token.pageToken,
      );
    } catch (_) {
      return token;
    }
  }

  Future<OAuthTokenModel> _fetchLinkedInProfile(OAuthTokenModel token) async {
    try {
      final resp = await http.get(
        Uri.parse(
          '${ApiEndpoints.linkedinMe}?projection=(id,localizedFirstName,localizedLastName,vanityName)',
        ),
        headers: {
          'Authorization': 'Bearer ${token.accessToken}',
          'Accept': 'application/json',
        },
      );
      if (resp.statusCode != 200) return token;
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final first = data['localizedFirstName'] as String? ?? '';
      final last = data['localizedLastName'] as String? ?? '';
      final displayName = [first, last].where((s) => s.isNotEmpty).join(' ');
      return OAuthTokenModel(
        accessToken: token.accessToken,
        refreshToken: token.refreshToken,
        expiresAt: token.expiresAt,
        userId: data['id'] as String? ?? token.userId,
        username: data['vanityName'] as String? ?? token.username,
        displayName: displayName.isEmpty ? token.displayName : displayName,
        avatarUrl: token.avatarUrl,
        pageId: token.pageId,
        pageToken: token.pageToken,
      );
    } catch (_) {
      return token;
    }
  }

  /// Refresh an existing token using its refresh token.
  Future<OAuthTokenModel?> refresh({
    required SocialPlatform platform,
    required String refreshToken,
    required String clientId,
    String? clientSecret,
  }) async {
    final tokenEndpoint = _tokenUrlFor(platform);
    try {
      final resp = await http.post(
        Uri.parse(tokenEndpoint),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
          'client_id': clientId,
          if (clientSecret != null && clientSecret.isNotEmpty)
            'client_secret': clientSecret,
        },
      );
      if (resp.statusCode != 200) return null;
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final access = data['access_token'] as String?;
      if (access == null) return null;
      final expiresIn = (data['expires_in'] as num?)?.toInt() ?? 3600;
      return OAuthTokenModel(
        accessToken: access,
        refreshToken: data['refresh_token'] as String? ?? refreshToken,
        expiresAt: DateTime.now().add(Duration(seconds: expiresIn)),
      );
    } catch (_) {
      return null;
    }
  }
}