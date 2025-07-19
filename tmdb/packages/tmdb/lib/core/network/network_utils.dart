import 'dart:io';
import 'package:dio/dio.dart';

import 'api_exception.dart';

/// Utility class for common network operations
class NetworkUtils {
  /// Check if the error is a network connectivity issue
  static bool isNetworkError(dynamic error) {
    return error is SocketException ||
        error is NetworkException ||
        (error is DioException &&
            (error.type == DioExceptionType.connectionError ||
                error.type == DioExceptionType.connectionTimeout));
  }

  /// Check if the error is a timeout issue
  static bool isTimeoutError(dynamic error) {
    return error is TimeoutException ||
        (error is DioException &&
            (error.type == DioExceptionType.connectionTimeout ||
                error.type == DioExceptionType.sendTimeout ||
                error.type == DioExceptionType.receiveTimeout));
  }

  /// Check if the error is a server error (5xx)
  static bool isServerError(dynamic error) {
    if (error is ServerException) return true;
    if (error is DioException && error.response != null) {
      final statusCode = error.response!.statusCode;
      return statusCode != null && statusCode >= 500;
    }
    return false;
  }

  /// Check if the error is a client error (4xx)
  static bool isClientError(dynamic error) {
    if (error is ClientException) return true;
    if (error is DioException && error.response != null) {
      final statusCode = error.response!.statusCode;
      return statusCode != null && statusCode >= 400 && statusCode < 500;
    }
    return false;
  }

  /// Get a user-friendly error message
  static String getErrorMessage(dynamic error) {
    if (error is ApiException) {
      return error.message;
    }

    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Request timeout. Please try again.';
        case DioExceptionType.connectionError:
          return 'No internet connection. Please check your network.';
        case DioExceptionType.badResponse:
          return 'Server error. Please try again later.';
        case DioExceptionType.cancel:
          return 'Request was cancelled.';
        case DioExceptionType.badCertificate:
          return 'Certificate error. Please check your connection.';
        case DioExceptionType.unknown:
          return 'An unexpected error occurred.';
      }
    }

    return 'Something went wrong. Please try again.';
  }

  /// Check if retry is recommended for the given error
  static bool shouldRetry(dynamic error) {
    // Don't retry client errors (4xx) except 408, 429
    if (isClientError(error)) {
      if (error is DioException && error.response != null) {
        final statusCode = error.response!.statusCode;
        return statusCode == 408 || statusCode == 429;
      }
      return false;
    }

    // Retry network errors and server errors
    return isNetworkError(error) ||
        isServerError(error) ||
        isTimeoutError(error);
  }

  /// Calculate exponential backoff delay
  static Duration calculateBackoffDelay(
    int attempt, {
    Duration baseDelay = const Duration(seconds: 1),
  }) {
    final exponentialDelay = baseDelay.inMilliseconds * (1 << (attempt - 1));
    final jitter =
        (exponentialDelay *
            0.1 *
            (DateTime.now().millisecondsSinceEpoch % 100)) /
        100;
    final finalDelay = exponentialDelay + jitter.toInt();

    return Duration(
      milliseconds: finalDelay.clamp(100, 30000),
    ); // Min 100ms, Max 30s
  }
}
