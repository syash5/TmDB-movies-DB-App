import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../constants/constants.dart';
import '../di/injection.dart';
import 'api_service.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'network_config.dart';

@module
abstract class DioModule {
  @lazySingleton
  Dio get dio {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.tmdbBaseUrl,
        // Use centralized timeout settings
        connectTimeout: NetworkConfig.connectTimeout,
        receiveTimeout: NetworkConfig.receiveTimeout,
        sendTimeout: NetworkConfig.sendTimeout,
        // Use centralized headers
        headers: NetworkConfig.defaultHeaders,
        // Use centralized performance settings
        responseType: ResponseType.json,
        followRedirects: NetworkConfig.followRedirects,
        maxRedirects: NetworkConfig.maxRedirects,
        validateStatus: NetworkConfig.validateStatus,
      ),
    );

    // Add interceptors in optimal order
    dio.interceptors.addAll([
      getIt<LoggingInterceptor>(),
      getIt<AuthInterceptor>(),
      getIt<ErrorInterceptor>(),
    ]);

    return dio;
  }

  @lazySingleton
  ApiService apiService(Dio dio) => ApiService(dio);
}
