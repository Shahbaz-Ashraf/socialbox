import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/platform_utils.dart';
import '../entities/connected_account.dart';
import '../repositories/auth_repository.dart';

class GetConnectedAccounts
    extends UseCase<List<ConnectedAccount>, NoParams> {
  GetConnectedAccounts(this._repo);
  final AuthRepository _repo;

  @override
  Future<Either<Failure, List<ConnectedAccount>>> call(NoParams params) =>
      _repo.getConnectedAccounts();
}

class DisconnectPlatform extends UseCase<Unit, SocialPlatform> {
  DisconnectPlatform(this._repo);
  final AuthRepository _repo;

  @override
  Future<Either<Failure, Unit>> call(SocialPlatform params) =>
      _repo.disconnect(params);
}

class RefreshAccessToken extends UseCase<ConnectedAccount, SocialPlatform> {
  RefreshAccessToken(this._repo);
  final AuthRepository _repo;

  @override
  Future<Either<Failure, ConnectedAccount>> call(SocialPlatform params) =>
      _repo.refresh(params);
}
