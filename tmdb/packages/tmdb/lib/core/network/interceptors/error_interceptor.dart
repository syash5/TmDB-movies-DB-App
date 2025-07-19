import 'dart:io';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../api_exception.dart';
import '../api_error_response.dart';
import '../network_config.dart';
import '../../managers/network_manager.dart';

@injectable
class ErrorInterceptor extends Interceptor {
  final NetworkManager _networkManager;

  // Cache for error responses to avoid repeated parsing
  static final Map<String, ApiErrorResponse> _errorCache = {};

  ErrorInterceptor(this._networkManager);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    ApiException exception;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        exception = const TimeoutException('Request timeout');
        break;

      case DioExceptionType.connectionError:
        exception = _handleConnectionError();
        break;

      case DioExceptionType.badResponse:
        exception = _handleHttpError(err);
        break;

      case DioExceptionType.cancel:
        exception = const NetworkException('Request cancelled');
        break;

      case DioExceptionType.unknown:
        exception = _handleUnknownError(err);
        break;

      default:
        exception = UnknownException('Unexpected error: ${err.message}');
    }

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: exception,
        type: err.type,
        response: err.response,
      ),
    );
  }

  ApiException _handleConnectionError() {
    if (!_networkManager.isConnected) {
      return const NetworkException('No internet connection');
    }
    return const NetworkException('Connection error');
  }

  ApiException _handleUnknownError(DioException err) {
    if (err.error is SocketException) {
      return _handleConnectionError();
    }
    return UnknownException('Unknown error: ${err.message}');
  }

  ApiException _handleHttpError(DioException err) {
    final statusCode = err.response?.statusCode ?? 0;
    final data = err.response?.data;

    String message = 'An error occurred';

    // Try to parse error response with caching
    if (data != null && data is Map<String, dynamic>) {
      message = _parseErrorMessage(data);
    }

    return _createHttpException(statusCode, message);
  }

  String _parseErrorMessage(Map<String, dynamic> data) {
    try {
      // Create a cache key from the error data
      final cacheKey = data.toString();

      // Check cache first
      if (_errorCache.containsKey(cacheKey)) {
        return _errorCache[cacheKey]!.message;
      }

      // Parse and cache
      final errorResponse = ApiErrorResponse.fromJson(data);
      _errorCache[cacheKey] = errorResponse;

      // Limit cache size using config
      if (_errorCache.length > NetworkConfig.maxErrorCacheSize) {
        _errorCache.clear();
      }

      return errorResponse.message;
    } catch (e) {
      // Fallback to raw message extraction
      return data['message']?.toString() ??
          data['error']?.toString() ??
          'An error occurred';
    }
  }

  ApiException _createHttpException(int statusCode, String message) {
    switch (statusCode) {
      case 400:
        return ClientException(message, statusCode);
      case 401:
        return UnauthorizedException(message);
      case 403:
        return ForbiddenException(message);
      case 404:
        return NotFoundException(message);
      case 422:
        return ValidationException(message);
      case >= 500:
        return ServerException(message, statusCode);
      default:
        return ClientException(message, statusCode);
    }
  }
}
