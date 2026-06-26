import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../domain/entities/connected_account.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/social_auth_datasource.dart';
import '../services/oauth_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._ds, this._oauth);
  final SocialAuthDataSource _ds;
  final OAuthService _oauth;

  @override
  Future<Either<Failure, List<ConnectedAccount>>>
      getConnectedAccounts() async {
    try {
      final tokens = await _ds.getAllStored();
      final list = <ConnectedAccount>[];
      for (final p in SocialPlatform.values) {
        final t = tokens[p.name];
        if (t != null && t.isConnected) {
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
