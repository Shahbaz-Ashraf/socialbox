class DatabaseException implements Exception {
  DatabaseException(this.message);
  final String message;
  @override
  String toString() => 'DatabaseException: $message';
}

class NetworkException implements Exception {
  NetworkException(this.message);
  final String message;
  @override
  String toString() => 'NetworkException: $message';
}

class AuthException implements Exception {
  AuthException(this.message);
  final String message;
  @override
  String toString() => 'AuthException: $message';
}

class CacheException implements Exception {
  CacheException(this.message);
  final String message;
  @override
  String toString() => 'CacheException: $message';
}

class ValidationException implements Exception {
  ValidationException(this.message);
  final String message;
  @override
  String toString() => 'ValidationException: $message';
}
