import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:tmdb/core/constants/routing_constants.dart';
import 'package:tmdb/features/movies/models/movie.dart';
import 'package:tmdb/features/movies/view/bookmarks_page.dart';
import 'package:tmdb/features/movies/view/home_page.dart';
import 'package:tmdb/features/movies/view/movie_details_page.dart';
import 'package:tmdb/features/movies/view/search_page.dart';
import 'package:tmdb/features/splash/view/splash_screen.dart';

part 'AppRouter.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: SplashRoute.page,
      path: RoutingConstants.splashPage,
      initial: true,
    ),
    AutoRoute(
      page: HomeRoute.page,
      path: RoutingConstants.homePage,
    ),
    AutoRoute(
      page: MovieDetailsRoute.page,
      path: RoutingConstants.movieDetailsPage,
    ),
    AutoRoute(
      page: SearchRoute.page,
      path: RoutingConstants.searchPage,
    ),
    AutoRoute(
      page: BookmarksRoute.page,
      path: RoutingConstants.bookmarksPage,
    ),
  ];
}
