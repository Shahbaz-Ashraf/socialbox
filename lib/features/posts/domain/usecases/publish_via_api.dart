import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../../settings/domain/repositories/settings_repository.dart';
import '../../../social_auth/domain/repositories/auth_repository.dart';

class PublishViaApiParams {
  const PublishViaApiParams({
    required this.postId,
    required this.platform,
  });

  final String postId;
  final SocialPlatform platform;
}

/// Stub for future API publishing. Gates on [AppSettings.enableApiPosting]
/// and ensures OAuth tokens are fresh when auto-refresh is enabled.
class PublishViaApi extends UseCase<Unit, PublishViaApiParams> {
  PublishViaApi(this._settings, this._auth);

  final SettingsRepository _settings;
  final AuthRepository _auth;

  static const disabledMessage =
      'API posting is disabled. Turn on "Enable API posting" in Settings.';

  @override
  Future<Either<Failure, Unit>> call(PublishViaApiParams params) async {
    if (!_settings.getSettings().enableApiPosting) {
      return const Left(ValidationFailure(message: disabledMessage));
    }

    final tokenResult = await _auth.ensureFreshToken(params.platform);
    return tokenResult.fold(
      (f) => Left(f),
      (_) => Left(
        ValidationFailure(
          message:
              'API posting for ${params.platform.displayName} is not implemented yet.',
        ),
      ),
    );
  }
}