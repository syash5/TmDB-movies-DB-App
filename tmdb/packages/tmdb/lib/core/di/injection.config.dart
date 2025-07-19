// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/movies/bloc/movies_bloc.dart' as _i685;
import '../../features/movies/repository/movie_repository.dart' as _i432;
import '../../features/splash/bloc/splash_bloc.dart' as _i480;
import '../managers/hive_manager.dart' as _i459;
import '../managers/managers.dart' as _i597;
import '../managers/network_manager.dart' as _i291;
import '../network/api_service.dart' as _i921;
import '../network/bloc/network_bloc.dart' as _i935;
import '../network/dio_module.dart' as _i614;
import '../network/interceptors/auth_interceptor.dart' as _i745;
import '../network/interceptors/error_interceptor.dart' as _i511;
import '../network/interceptors/logging_interceptor.dart' as _i344;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final dioModule = _$DioModule();
    gh.factory<_i745.AuthInterceptor>(() => _i745.AuthInterceptor());
    gh.factory<_i344.LoggingInterceptor>(() => _i344.LoggingInterceptor());
    gh.factory<_i480.SplashBloc>(() => _i480.SplashBloc());
    gh.lazySingleton<_i459.HiveManager>(() => _i459.HiveManager());
    gh.lazySingleton<_i291.NetworkManager>(() => _i291.NetworkManager());
    gh.lazySingleton<_i361.Dio>(() => dioModule.dio);
    gh.factory<_i935.NetworkBloc>(
      () => _i935.NetworkBloc(gh<_i291.NetworkManager>()),
    );
    gh.factory<_i511.ErrorInterceptor>(
      () => _i511.ErrorInterceptor(gh<_i291.NetworkManager>()),
    );
    gh.lazySingleton<_i921.ApiService>(
      () => dioModule.apiService(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i432.MovieRepository>(
      () => _i432.MovieRepository(
        gh<_i921.ApiService>(),
        gh<_i597.HiveManager>(),
      ),
    );
    gh.factory<_i685.MoviesBloc>(
      () => _i685.MoviesBloc(gh<_i432.MovieRepository>()),
    );
    return this;
  }
}

class _$DioModule extends _i614.DioModule {}
