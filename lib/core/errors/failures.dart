import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  const Failure({required this.message});
  final String message;

  @override
  List<Object?> get props => [message];
}

final class DatabaseFailure extends Failure {
  const DatabaseFailure({required super.message});
}

final class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

final class AuthFailure extends Failure {
  const AuthFailure({required super.message});
}

final class ApiFailure extends Failure {
  const ApiFailure({required super.message, this.statusCode});
  final int? statusCode;

  @override
  List<Object?> get props => [message, statusCode];
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message});
}

final class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}

final class PredefinedItemFailure extends Failure {
  const PredefinedItemFailure({required super.message});
}

final class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}
