import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../../settings/domain/repositories/settings_repository.dart';
import '../../domain/entities/connected_account.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/social_auth_datasource.dart';
import '../services/oauth_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._ds, this._oauth, this._settings);
  final SocialAuthDataSource _ds;
  final OAuthService _oauth;
  final SettingsRepository _settings;

  bool get _autoRefresh => _settings.getSettings().autoRefreshTokens;

  @override
  Future<Either<Failure, List<ConnectedAccount>>>
      getConnectedAccounts() async {
    try {
      final tokens = await _ds.getAllStored();
      final list = <ConnectedAccount>[];
      for (final p in SocialPlatform.values) {
        final t = tokens[p.name];
        if (t == null || !t.isConnected) continue;

        if (_autoRefresh && t.isExpired && t.refreshToken != null) {
          final refreshed = await refresh(p);
          refreshed.fold(
            (_) => list.add(ConnectedAccount.fromToken(p, t)),
            list.add,
          );
        } else {
          list.add(ConnectedAccount.fromToken(p, t));
        }
      }
      return Right(list);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ConnectedAccount>> connect(
    SocialPlatform platform, {
    required String clientId,
    String? clientSecret,
  }) async {
    try {
      if (_autoRefresh) {
        final existing = await _ds.getToken(platform);
        if (existing != null &&
            existing.isConnected &&
            existing.isExpired &&
            existing.refreshToken != null) {
          final refreshed = await refresh(platform);
          if (refreshed.isRight()) return refreshed;
        }
      }

      final token = await _oauth.authorizeAndExchange(
        platform: platform,
        clientId: clientId,
        clientSecret: clientSecret,
      );
      if (token == null) {
        return const Left(AuthFailure(message: 'OAuth flow did not complete.'));
      }
      await _ds.save(platform, token);
      return Right(ConnectedAccount.fromToken(platform, token));
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> disconnect(SocialPlatform platform) async {
    try {
      await _ds.delete(platform);
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<String?> getClientId(SocialPlatform platform) =>
      _ds.clientIdFor(platform);

  @override
  Future<String?> getClientSecret(SocialPlatform platform) =>
      _ds.clientSecretFor(platform);

  @override
  Future<Either<Failure, Unit>> saveCredentials(
    SocialPlatform platform, {
    required String clientId,
    String? clientSecret,
  }) async {
    try {
      await _ds.saveCredentials(
        platform,
        clientId: clientId,
        clientSecret: clientSecret,
      );
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ConnectedAccount>> ensureFreshToken(
      SocialPlatform platform) async {
    try {
      final stored = await _ds.getToken(platform);
      if (stored == null || !stored.isConnected) {
        return const Left(NotFoundFailure(message: 'Not connected.'));
      }
      final account = ConnectedAccount.fromToken(platform, stored);
      if (!_autoRefresh || !account.isExpired) {
        return Right(account);
      }
      if (stored.refreshToken == null) {
        return const Left(
          AuthFailure(message: 'Token expired — please reconnect.'),
        );
      }
      return refresh(platform);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ConnectedAccount>> refresh(
      SocialPlatform platform) async {
    try {
      final stored = await _ds.getToken(platform);
      if (stored == null || stored.refreshToken == null) {
        return const Left(NotFoundFailure(message: 'Not connected.'));
      }
      final clientId = await _ds.clientIdFor(platform);
      if (clientId == null || clientId.isEmpty) {
        return const Left(AuthFailure(
            message: 'Missing client id — please reconnect.'));
      }
      final refreshed = await _oauth.refresh(
        platform: platform,
        refreshToken: stored.refreshToken!,
        clientId: clientId,
        clientSecret: await _ds.clientSecretFor(platform),
      );
      if (refreshed == null) {
        return const Left(AuthFailure(message: 'Refresh failed.'));
      }
      await _ds.save(platform, refreshed);
      return Right(ConnectedAccount.fromToken(platform, refreshed));
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }
}