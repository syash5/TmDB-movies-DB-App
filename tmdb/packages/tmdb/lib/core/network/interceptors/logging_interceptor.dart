import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../network_config.dart';

@injectable
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!NetworkConfig.enableVerboseLogging) {
      handler.next(options);
      return;
    }

    log(
      '🚀 REQUEST: ${options.method} ${options.uri}\n'
      'Headers: ${_formatHeaders(options.headers)}\n'
      'Data: ${_formatData(options.data)}',
      name: 'API_REQUEST',
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (!NetworkConfig.enableVerboseLogging) {
      handler.next(response);
      return;
    }

    log(
      '✅ RESPONSE: ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.uri}\n'
      'Data: ${_formatData(response.data)}',
      name: 'API_RESPONSE',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Always log errors, even in release mode
    log(
      '❌ ERROR: ${err.response?.statusCode} ${err.requestOptions.method} ${err.requestOptions.uri}\n'
      'Message: ${err.message}\n'
      'Data: ${_formatData(err.response?.data)}',
      name: 'API_ERROR',
      error: err,
    );
    handler.next(err);
  }

  String _formatData(dynamic data) {
    if (data == null) return 'null';
    if (data is String) {
      return data.length > NetworkConfig.maxLogDataLength
          ? '${data.substring(0, NetworkConfig.maxLogDataLength)}...'
          : data;
    }

    try {
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);
      return jsonString.length > NetworkConfig.maxLogDataLength
          ? '${jsonString.substring(0, NetworkConfig.maxLogDataLength)}...'
          : jsonString;
    } catch (e) {
      final stringData = data.toString();
      return stringData.length > NetworkConfig.maxLogDataLength
          ? '${stringData.substring(0, NetworkConfig.maxLogDataLength)}...'
          : stringData;
    }
  }

  String _formatHeaders(Map<String, dynamic> headers) {
    if (!NetworkConfig.enableVerboseLogging) return '***';

    try {
      return const JsonEncoder.withIndent('  ').convert(headers);
    } catch (e) {
      return headers.toString();
    }
  }
}
