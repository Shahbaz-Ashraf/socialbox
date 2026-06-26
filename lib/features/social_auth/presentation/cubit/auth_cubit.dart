import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/platform_utils.dart';
import '../../domain/entities/connected_account.dart';
import '../../domain/repositories/auth_repository.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthLoaded extends AuthState {
  const AuthLoaded(this.accounts);
  final List<ConnectedAccount> accounts;
  @override
  List<Object?> get props => [accounts];
}

class AuthConnecting extends AuthState {
  const AuthConnecting(this.platform);
  final SocialPlatform platform;
  @override
  List<Object?> get props => [platform];
}

class AuthConnected extends AuthState {
  const AuthConnected(this.account, this.allAccounts);
  final ConnectedAccount account;
  final List<ConnectedAccount> allAccounts;
  @override
  List<Object?> get props => [account, allAccounts];
}

class AuthFailureState extends AuthState {
  const AuthFailureState(this.message, this.allAccounts);
  final String message;
  final List<ConnectedAccount> allAccounts;
  @override
  List<Object?> get props => [message, allAccounts];
}

class AuthError extends AuthState {
  const AuthError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repo) : super(const AuthInitial());

  final AuthRepository _repo;

  Future<void> load() async {
    emit(const AuthLoading());
    final r = await _repo.getConnectedAccounts();
    r.fold(
      (f) => emit(AuthError(f.message)),
      (list) => emit(AuthLoaded(list)),
    );
  }

  Future<bool> connect(
    SocialPlatform platform, {
    required String clientId,
    String? clientSecret,
  }) async {
    emit(AuthConnecting(platform));
    final r = await _repo.connect(
      platform,
      clientId: clientId,
      clientSecret: clientSecret,
    );
    return r.fold(
      (f) async {
        final accounts = await _accountsOrEmpty();
        emit(AuthFailureState(f.message, accounts));
        return false;
      },
      (account) async {
        final accounts = await _accountsOrEmpty();
        emit(AuthConnected(account, accounts));
        return true;
      },
    );
  }

  Future<bool> disconnect(SocialPlatform platform) async {
    final r = await _repo.disconnect(platform);
    await load();
    return r.isRight();
  }

  Future<bool> refresh(SocialPlatform platform) async {
    final r = await _repo.refresh(platform);
    await load();
    return r.isRight();
  }

  Future<String?> getClientId(SocialPlatform platform) =>
      _repo.getClientId(platform);

  Future<String?> getClientSecret(SocialPlatform platform) =>
      _repo.getClientSecret(platform);

  Future<bool> saveCredentials(
    SocialPlatform platform, {
    required String clientId,
    String? clientSecret,
  }) async {
    final r = await _repo.saveCredentials(
      platform,
      clientId: clientId,
      clientSecret: clientSecret,
    );
    return r.isRight();
  }

  Future<List<ConnectedAccount>> _accountsOrEmpty() async {
    final r = await _repo.getConnectedAccounts();
    return r.getOrElse((_) => const <ConnectedAccount>[]);
  }
}
