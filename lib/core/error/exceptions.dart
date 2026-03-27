// core/error/exceptions.dart

class ServerException implements Exception {
  final String message;
  final int? statusCode;
  final String? field;

  ServerException(this.message, {this.statusCode, this.field});
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException([
    this.message = 'Session expired. Please login again.',
  ]);
}

class ValidationException implements Exception {
  final String message;
  final String? field;
  ValidationException(this.message, {this.field});
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
}

class ConflictException implements Exception {
  final String message;
  ConflictException(this.message);
}
