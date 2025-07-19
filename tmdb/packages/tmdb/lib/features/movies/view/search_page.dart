import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tmdb/core/di/injection.dart';
import 'package:tmdb/core/l10n/l10n.dart';
import 'package:tmdb/features/movies/models/movie.dart';

import '../../../core/router/AppRouter.dart';
import '../../../core/theme/theme.dart';
import '../bloc/movies_bloc.dart';
import '../repository/movie_repository.dart';
import '../widgets/movie_card.dart';

@RoutePage()
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final MovieRepository _movieRepository = getIt<MovieRepository>();
  Timer? _debounceTimer;
  String currentQuery = '';
  List<Movie> searchResults = [];
  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasReachedMax = false;
  int currentPage = 1;
  int bookmarkUpdateKey = 0;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    currentQuery = query;
    _debounceTimer?.cancel();

    if (query.isEmpty) {
      setState(() {
        searchResults = [];
        isLoading = false;
        isLoadingMore = false;
        hasReachedMax = false;
        currentPage = 1;
      });
      return;
    }

    setState(() {
      isLoading = true;
      isLoadingMore = false;
      hasReachedMax = false;
      currentPage = 1;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted && currentQuery == query) {
        context.read<MoviesBloc>().add(SearchMovies(query: query, page: 1));
      }
    });
  }

  void _loadMore() {
    if (!hasReachedMax && !isLoadingMore && currentQuery.isNotEmpty) {
      setState(() {
        isLoadingMore = true;
      });
      context.read<MoviesBloc>().add(
        SearchMovies(query: currentQuery, page: currentPage + 1),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: BlocListener<MoviesBloc, MoviesState>(
          listener: (context, state) {
            if (state is SearchMoviesLoaded) {
              setState(() {
                if (state.currentPage == 1) {
                  searchResults = state.movies;
                  isLoading = false;
                } else {
                  searchResults = [...searchResults, ...state.movies];
                  isLoadingMore = false;
                }
                currentPage = state.currentPage;
                hasReachedMax = state.hasReachedMax;
              });
            } else if (state is BookmarkUpdated) {
              setState(() {
                bookmarkUpdateKey++;
              });
            } else if (state is MoviesError) {
              setState(() {
                isLoading = false;
                isLoadingMore = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                color: AppColors.primaryColor,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => context.router.pop(),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25.r),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          decoration: InputDecoration(
                            hintText: l10n.searchMovies,
                            hintStyle: AppTextStyles.text14.copyWith(
                              color: Colors.grey[600],
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.grey[600],
                              size: 20.w,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 12.h,
                            ),
                          ),
                          style: AppTextStyles.text14.copyWith(
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      ),
                  ],
                ),
              ),
              Expanded(
                child: _buildSearchResults(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    final l10n = context.l10n;

    if (_searchController.text.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 80.w,
              color: Colors.grey[600],
            ),
            SizedBox(height: 16.h),
            Text(
              l10n.searchForMovies,
              style: AppTextStyles.text18.copyWith(
                color: Colors.grey[400],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              l10n.searchForMoviesDescription,
              style: AppTextStyles.text14.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.white,
        ),
      );
    }

    if (searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80.w,
              color: Colors.grey[600],
            ),
            SizedBox(height: 16.h),
            Text(
              l10n.noResultsFound,
              style: AppTextStyles.text18.copyWith(
                color: Colors.grey[400],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              l10n.noResultsFoundDescription,
              style: AppTextStyles.text14.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          _loadMore();
        }
        return false;
      },
      child: GridView.builder(
        padding: EdgeInsets.all(16.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.55,
          crossAxisSpacing: 8.w,
          mainAxisSpacing: 8.h,
        ),
        itemCount: searchResults.length + (isLoadingMore ? 2 : 0),
        itemBuilder: (context, index) {
          if (index >= searchResults.length) {
            // Loading indicator at the end
            return Container(
              decoration: BoxDecoration(
                color: AppColors.grey,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.white,
                ),
              ),
            );
          }

          final movie = searchResults[index];
          return FutureBuilder<bool>(
            key: ValueKey('${movie.id}_$bookmarkUpdateKey'),
            future: _movieRepository.isMovieBookmarked(movie.id),
            builder: (context, snapshot) {
              final isBookmarked = snapshot.data ?? false;
              return MovieCard(
                movie: movie,
                isBookmarked: isBookmarked,
                onTap: () {
                  context.router.push(MovieDetailsRoute(movie: movie));
                },
                onBookmark: () async {
                  final isCurrentlyBookmarked = await _movieRepository.isMovieBookmarked(movie.id);
                  if (isCurrentlyBookmarked) {
                    context.read<MoviesBloc>().add(UnbookmarkMovie(movie.id));
                  } else {
                    context.read<MoviesBloc>().add(BookmarkMovie(movie));
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
