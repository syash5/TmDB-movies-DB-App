import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tmdb/features/movies/models/movie.dart';

import '../../../core/theme/theme.dart';
import 'movie_card.dart';

class MovieListSection extends StatelessWidget {
  final String title;
  final List<Movie> movies;
  final Function(Movie)? onMovieTap;
  final Function(Movie)? onBookmark;
  final Future<bool> Function(Movie)? getBookmarkStatus;
  final VoidCallback? onLoadMore;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final int bookmarkUpdateKey;

  const MovieListSection({
    super.key,
    required this.title,
    required this.movies,
    this.onMovieTap,
    this.onBookmark,
    this.getBookmarkStatus,
    this.onLoadMore,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.bookmarkUpdateKey = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyles.text18.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 12.h),

        if (movies.isEmpty)
          Container(
            height: 280.h,
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: AppColors.grey,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: AppColors.white,
              ),
            ),
          )
        else
          SizedBox(
            height: 320.h,
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo.metrics.pixels ==
                    scrollInfo.metrics.maxScrollExtent) {
                  if (!hasReachedMax && !isLoadingMore && onLoadMore != null) {
                    onLoadMore!();
                  }
                }
                return false;
              },
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                itemCount: movies.length + (isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == movies.length) {
                    // Loading indicator at the end
                    return Container(
                      width: 150.w,
                      margin: EdgeInsets.all(8.w),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.white,
                        ),
                      ),
                    );
                  }

                  final movie = movies[index];
                  return FutureBuilder<bool>(
                    key: ValueKey('${movie.id}_$bookmarkUpdateKey'),
                    future:
                        getBookmarkStatus?.call(movie) ?? Future.value(false),
                    builder: (context, snapshot) {
                      final isBookmarked = snapshot.data ?? false;
                      return MovieCard(
                        movie: movie,
                        isBookmarked: isBookmarked,
                        onTap: () => onMovieTap?.call(movie),
                        onBookmark: () => onBookmark?.call(movie),
                      );
                    },
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
