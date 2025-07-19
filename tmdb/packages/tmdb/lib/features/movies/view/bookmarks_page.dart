import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tmdb/core/l10n/l10n.dart';
import 'package:tmdb/core/router/AppRouter.dart';
import 'package:tmdb/core/theme/theme.dart';
import 'package:tmdb/features/movies/bloc/movies_bloc.dart';
import 'package:tmdb/features/movies/models/movie.dart';
import 'package:tmdb/features/movies/widgets/movie_card.dart';

@RoutePage()
class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  List<Movie> bookmarkedMovies = [];

  @override
  void initState() {
    super.initState();
    context.read<MoviesBloc>().add(const LoadBookmarkedMovies());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: BlocListener<MoviesBloc, MoviesState>(
          listener: (context, state) {
            if (state is BookmarkedMoviesLoaded) {
              setState(() {
                bookmarkedMovies = state.movies;
              });
            } else if (state is MoviesError) {
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
                      child: Text(
                        l10n.myBookmarks,
                        style: AppTextStyles.text18.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (bookmarkedMovies.isNotEmpty)
                      IconButton(
                        icon: const Icon(
                          Icons.delete_sweep,
                          color: Colors.white,
                        ),
                        onPressed: () => _showClearAllDialog(context),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: _buildBookmarksContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookmarksContent() {
    final l10n = context.l10n;

    if (bookmarkedMovies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 80.w,
              color: Colors.grey[600],
            ),
            SizedBox(height: 16.h),
            Text(
              l10n.noBookmarkedMovies,
              style: AppTextStyles.text18.copyWith(
                color: Colors.grey[400],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              l10n.noBookmarkedMoviesDescription,
              style: AppTextStyles.text14.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () => context.router.pop(),
              icon: const Icon(Icons.home),
              label: Text(l10n.goToHome),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: 12.h,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Text(
            l10n.bookmarkedMovies(bookmarkedMovies.length),
            style: AppTextStyles.text18.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.55,
              crossAxisSpacing: 8.w,
              mainAxisSpacing: 8.h,
            ),
            itemCount: bookmarkedMovies.length,
            itemBuilder: (context, index) {
              final movie = bookmarkedMovies[index];
              return MovieCard(
                movie: movie,
                isBookmarked: true,
                onTap: () {
                  context.router.push(MovieDetailsRoute(movie: movie));
                },
                onBookmark: () {
                  context.read<MoviesBloc>().add(UnbookmarkMovie(movie.id));
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showClearAllDialog(BuildContext context) {
    final l10n = context.l10n;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.grey53,
          title: Text(
            l10n.clearAllBookmarks,
            style: AppTextStyles.text18.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            l10n.clearAllBookmarksMessage,
            style: AppTextStyles.text14.copyWith(
              color: Colors.white,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                l10n.cancel,
                style: AppTextStyles.text14.copyWith(
                  color: Colors.grey[400],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearAllBookmarks();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.clearAllBookmarks),
            ),
          ],
        );
      },
    );
  }

  void _clearAllBookmarks() {
    context.read<MoviesBloc>().add(const ClearAllBookmarks());
  }
}
