import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tmdb/core/l10n/l10n.dart';
import 'package:tmdb/features/movies/models/movie.dart';

import '../../../core/di/injection.dart';
import '../../../core/router/AppRouter.dart';
import '../../../core/theme/theme.dart';
import '../bloc/movies_bloc.dart';
import '../repository/movie_repository.dart';
import '../widgets/movie_list_section.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Movie> trendingMovies = [];
  List<Movie> nowPlayingMovies = [];
  int trendingCurrentPage = 1;
  int nowPlayingCurrentPage = 1;
  bool trendingHasReachedMax = false;
  bool nowPlayingHasReachedMax = false;
  bool isLoadingTrendingMore = false;
  bool isLoadingNowPlayingMore = false;
  int bookmarkUpdateKey = 0;

  final MovieRepository _movieRepository = getIt<MovieRepository>();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black87,
        body: SafeArea(
          child: BlocListener<MoviesBloc, MoviesState>(
            listener: (context, state) {
              if (state is TrendingMoviesLoaded) {
                setState(() {
                  trendingMovies = state.movies;
                  trendingCurrentPage = state.currentPage;
                  trendingHasReachedMax = state.hasReachedMax;
                  isLoadingTrendingMore = false;
                });
              } else if (state is NowPlayingMoviesLoaded) {
                setState(() {
                  nowPlayingMovies = state.movies;
                  nowPlayingCurrentPage = state.currentPage;
                  nowPlayingHasReachedMax = state.hasReachedMax;
                  isLoadingNowPlayingMore = false;
                });
              } else if (state is BookmarkUpdated) {
                setState(() {
                  bookmarkUpdateKey++;
                });
              } else if (state is MoviesError) {
                setState(() {
                  isLoadingTrendingMore = false;
                  isLoadingNowPlayingMore = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  trendingCurrentPage = 1;
                  nowPlayingCurrentPage = 1;
                  trendingHasReachedMax = false;
                  nowPlayingHasReachedMax = false;
                });
                context.read<MoviesBloc>()
                  ..add(const LoadTrendingMovies(refresh: true))
                  ..add(const LoadNowPlayingMovies(refresh: true));
              },
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    backgroundColor: AppColors.primaryColor,
                    elevation: 0,
                    pinned: true,
                    automaticallyImplyLeading: false,
                    title: Text(
                      l10n.tmdbMovies,
                      style: AppTextStyles.text18.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.search, color: AppColors.white),
                        onPressed: () {
                          context.router.push(const SearchRoute());
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.bookmark,
                          color: AppColors.white,
                        ),
                        onPressed: () {
                          context.router.push(const BookmarksRoute());
                        },
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        SizedBox(height: 24.h),
                        MovieListSection(
                          title: l10n.trendingMovies,
                          movies: trendingMovies,
                          bookmarkUpdateKey: bookmarkUpdateKey,
                          onMovieTap: (movie) {
                            context.router.push(
                              MovieDetailsRoute(movie: movie),
                            );
                          },
                          onBookmark: (movie) async {
                            final isCurrentlyBookmarked = await _movieRepository
                                .isMovieBookmarked(movie.id);
                            if (isCurrentlyBookmarked) {
                              context.read<MoviesBloc>().add(
                                UnbookmarkMovie(movie.id),
                              );
                            } else {
                              context.read<MoviesBloc>().add(
                                BookmarkMovie(movie),
                              );
                            }
                          },
                          getBookmarkStatus: (movie) async {
                            return await _movieRepository.isMovieBookmarked(
                              movie.id,
                            );
                          },
                          onLoadMore: () {
                            if (!trendingHasReachedMax &&
                                !isLoadingTrendingMore) {
                              setState(() {
                                isLoadingTrendingMore = true;
                              });
                              context.read<MoviesBloc>().add(
                                LoadTrendingMovies(
                                  page: trendingCurrentPage + 1,
                                ),
                              );
                            }
                          },
                          isLoadingMore: isLoadingTrendingMore,
                          hasReachedMax: trendingHasReachedMax,
                        ),
                        SizedBox(height: 24.h),
                        MovieListSection(
                          title: l10n.nowPlaying,
                          movies: nowPlayingMovies,
                          bookmarkUpdateKey: bookmarkUpdateKey,
                          onMovieTap: (movie) {
                            context.router.push(
                              MovieDetailsRoute(movie: movie),
                            );
                          },
                          onBookmark: (movie) async {
                            final isCurrentlyBookmarked = await _movieRepository
                                .isMovieBookmarked(movie.id);
                            if (isCurrentlyBookmarked) {
                              context.read<MoviesBloc>().add(
                                UnbookmarkMovie(movie.id),
                              );
                            } else {
                              context.read<MoviesBloc>().add(
                                BookmarkMovie(movie),
                              );
                            }
                          },
                          getBookmarkStatus: (movie) async {
                            return await _movieRepository.isMovieBookmarked(
                              movie.id,
                            );
                          },
                          onLoadMore: () {
                            if (!nowPlayingHasReachedMax &&
                                !isLoadingNowPlayingMore) {
                              setState(() {
                                isLoadingNowPlayingMore = true;
                              });
                              context.read<MoviesBloc>().add(
                                LoadNowPlayingMovies(
                                  page: nowPlayingCurrentPage + 1,
                                ),
                              );
                            }
                          },
                          isLoadingMore: isLoadingNowPlayingMore,
                          hasReachedMax: nowPlayingHasReachedMax,
                        ),
                        SizedBox(height: 48.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
