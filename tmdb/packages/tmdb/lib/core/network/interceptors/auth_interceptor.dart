import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:tmdb/core/constants/constants.dart';

@injectable
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add TMDB API key to all requests as query parameter
    // This is the standard approach for TMDB public endpoints
    final queryParams = Map<String, dynamic>.from(options.queryParameters);
    queryParams['api_key'] = AppConstants.tmdbApiKey;
    options.queryParameters = queryParams;

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // If we get a 401, log the error
    if (err.response?.statusCode == 401) {
      print('Unauthorized access to TMDB API - check API key');
    }
    handler.next(err);
  }
}
