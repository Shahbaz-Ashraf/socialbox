import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/platform_utils.dart';
import '../../domain/entities/connected_account.dart';
import '../../domain/repositories/auth_repository.dart';

// ---------------------------------------------------------------------------
// Events
// ---------------------------------------------------------------------------

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

final class AuthLoadAccounts extends AuthEvent {
  const AuthLoadAccounts();
}

final class AuthConnect extends AuthEvent {
  const AuthConnect({
    required this.platform,
    required this.clientId,
    this.clientSecret,
  });

  final SocialPlatform platform;
  final String clientId;
  final String? clientSecret;

  @override
  List<Object?> get props => [platform, clientId, clientSecret];
}

final class AuthDisconnect extends AuthEvent {
  const AuthDisconnect(this.platform);

  final SocialPlatform platform;

  @override
  List<Object?> get props => [platform];
}

final class AuthRefresh extends AuthEvent {
  const AuthRefresh(this.platform);

  final SocialPlatform platform;

  @override
  List<Object?> get props => [platform];
}

// ---------------------------------------------------------------------------
// States
// ---------------------------------------------------------------------------

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthLoaded extends AuthState {
  const AuthLoaded(this.accounts);

  final List<ConnectedAccount> accounts;

  @override
  List<Object?> get props => [accounts];
}

final class AuthConnecting extends AuthState {
  const AuthConnecting(this.platform);

  final SocialPlatform platform;

  @override
  List<Object?> get props => [platform];
}

final class AuthConnected extends AuthState {
  const AuthConnected(this.account, this.allAccounts);

  final ConnectedAccount account;
  final List<ConnectedAccount> allAccounts;

  @override
  List<Object?> get props => [account, allAccounts];
}

final class AuthFailureState extends AuthState {
  const AuthFailureState(this.message, this.allAccounts);

  final String message;
  final List<ConnectedAccount> allAccounts;

  @override
  List<Object?> get props => [message, allAccounts];
}

final class AuthError extends AuthState {
  const AuthError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

// ---------------------------------------------------------------------------
// Bloc
// ---------------------------------------------------------------------------

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._repo) : super(const AuthInitial()) {
    on<AuthLoadAccounts>(_onLoadAccounts);
    on<AuthConnect>(_onConnect);
    on<AuthDisconnect>(_onDisconnect);
    on<AuthRefresh>(_onRefresh);
  }

  final AuthRepository _repo;

  Future<void> _onLoadAccounts(
    AuthLoadAccounts event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final r = await _repo.getConnectedAccounts();
    r.fold(
      (f) => emit(AuthError(f.message)),
      (list) => emit(AuthLoaded(list)),
    );
  }

  Future<void> _onConnect(AuthConnect event, Emitter<AuthState> emit) async {
    emit(AuthConnecting(event.platform));
    final r = await _repo.connect(
      event.platform,
      clientId: event.clientId,
      clientSecret: event.clientSecret,
    );
    r.fold(
      (f) async {
        final accounts = await _accountsOrEmpty();
        emit(AuthFailureState(f.message, accounts));
      },
      (account) async {
        final accounts = await _accountsOrEmpty();
        emit(AuthConnected(account, accounts));
      },
    );
  }

  Future<void> _onDisconnect(
    AuthDisconnect event,
    Emitter<AuthState> emit,
  ) async {
    await _repo.disconnect(event.platform);
    add(const AuthLoadAccounts());
  }

  Future<void> _onRefresh(AuthRefresh event, Emitter<AuthState> emit) async {
    await refresh(event.platform);
  }

  /// Returns whether the token refresh succeeded (used by the accounts page).
  Future<bool> refresh(SocialPlatform platform) async {
    final r = await _repo.refresh(platform);
    add(const AuthLoadAccounts());
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