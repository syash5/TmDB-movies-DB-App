import 'package:equatable/equatable.dart';

/// Base class for all API exceptions
abstract class ApiException extends Equatable implements Exception {
  const ApiException(this.message, [this.statusCode]);

  final String message;
  final int? statusCode;

  @override
  List<Object?> get props => [message, statusCode];
}

/// Exception for network/connection errors
class NetworkException extends ApiException {
  const NetworkException(String message) : super(message);
}

/// Exception for server errors (5xx)
class ServerException extends ApiException {
  const ServerException(String message, int statusCode)
    : super(message, statusCode);
}

/// Exception for client errors (4xx)
class ClientException extends ApiException {
  const ClientException(String message, int statusCode)
    : super(message, statusCode);
}

/// Exception for authentication errors (401)
class UnauthorizedException extends ClientException {
  const UnauthorizedException(String message) : super(message, 401);
}

/// Exception for forbidden errors (403)
class ForbiddenException extends ClientException {
  const ForbiddenException(String message) : super(message, 403);
}

/// Exception for not found errors (404)
class NotFoundException extends ClientException {
  const NotFoundException(String message) : super(message, 404);
}

/// Exception for validation errors (422)
class ValidationException extends ClientException {
  const ValidationException(String message) : super(message, 422);
}

/// Exception for timeout errors
class TimeoutException extends ApiException {
  const TimeoutException(String message) : super(message);
}

/// Exception for parsing/serialization errors
class ParseException extends ApiException {
  const ParseException(String message) : super(message);
}

/// Exception for unknown errors
class UnknownException extends ApiException {
  const UnknownException(String message) : super(message);
}
