import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tmdb/core/constants/constants.dart';
import 'package:tmdb/core/di/injection.dart';
import 'package:tmdb/core/l10n/gen/app_localizations.dart';

import '../core/router/AppRouter.dart';
import '../core/theme/app_theme.dart';
import '../features/movies/bloc/movies_bloc.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = AppRouter();

    return MultiBlocProvider(
      providers: [
        BlocProvider<MoviesBloc>(
          create: (context) => getIt<MoviesBloc>()
            ..add(const LoadTrendingMovies())
            ..add(const LoadNowPlayingMovies()),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        child: MaterialApp.router(
          title: AppConstants.appName,
          theme: AppTheme.lightTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: appRouter.config(),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
