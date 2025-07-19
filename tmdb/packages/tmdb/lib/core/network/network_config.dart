import 'package:flutter/foundation.dart';

/// Centralized configuration for network settings
class NetworkConfig {
  // Timeout configurations
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 15);

  // Retry configurations
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);
  static const Duration maxRetryDelay = Duration(seconds: 5);

  // Debounce configurations
  static const Duration networkStatusDebounce = Duration(milliseconds: 500);

  // Logging configurations
  static const bool enableVerboseLogging = kDebugMode;
  static const int maxLogDataLength = 1000;

  // Cache configurations
  static const int maxErrorCacheSize = 100;

  // Performance configurations
  static const int maxRedirects = 3;
  static const bool followRedirects = true;

  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Accept-Encoding': 'gzip, deflate',
    'Connection': 'keep-alive',
  };

  // Status validation
  static bool validateStatus(int? status) {
    return status != null && status < 500;
  }
}
