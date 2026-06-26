import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

/// Listens for incoming OAuth redirect URIs on the platform's deep link
/// channel. Designed so the OAuth flow can be initiated via flutter_appauth
/// and the resulting redirect (e.g. `com.linkedif.socialbox://oauth/twitter?code=...`)
/// gets surfaced back to the caller.
class DeepLinkHandler {
  DeepLinkHandler({AppLinks? appLinks}) : _appLinks = appLinks ?? AppLinks();

  final AppLinks _appLinks;
  StreamSubscription<Uri>? _sub;

  /// Fires for any incoming URI whose host matches [expectedHost].
  /// Returns a subscription so callers can cancel it when done.
  StreamSubscription<Uri> listenForRedirect(
    String redirect,
    void Function(Uri uri) onUri,
  ) {
    final expected = Uri.parse(redirect);
    final expectedHost = expected.host;
    final expectedPathPrefix = expected.path;

    _sub?.cancel();
    _sub = _appLinks.uriLinkStream.listen((uri) {
      if (kDebugMode) {
        debugPrint('Deep link received: $uri');
      }
      if (uri.scheme == expected.scheme &&
          uri.host == expectedHost &&
          (expectedPathPrefix.isEmpty || uri.path.startsWith(expectedPathPrefix))) {
        onUri(uri);
      }
    }, onError: (e) {
      if (kDebugMode) debugPrint('Deep link error: $e');
    });
    return _sub!;
  }

  /// Returns the initial URI the app was launched with, if any.
  Future<Uri?> getInitialLink() async {
    try {
      return await _appLinks.getInitialLink();
    } catch (_) {
      return null;
    }
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;
  }
}