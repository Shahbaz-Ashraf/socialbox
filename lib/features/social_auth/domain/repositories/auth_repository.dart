import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/platform_utils.dart';
import '../entities/connected_account.dart';

abstract class AuthRepository {
  Future<Either<Failure, List<ConnectedAccount>>> getConnectedAccounts();
  Future<Either<Failure, ConnectedAccount>> connect(
    SocialPlatform platform, {
    required String clientId,
    String? clientSecret,
  });
  Future<Either<Failure, Unit>> disconnect(SocialPlatform platform);
  Future<Either<Failure, ConnectedAccount>> refresh(SocialPlatform platform);
}
