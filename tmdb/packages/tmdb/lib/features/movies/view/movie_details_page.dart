import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tmdb/core/l10n/l10n.dart';
import 'package:tmdb/features/movies/models/movie.dart';
import 'package:tmdb/features/movies/models/movie_details.dart';

import '../../../core/atomic_widgets/molecules/molecules.dart';
import '../../../core/di/injection.dart';
import '../../../core/theme/theme.dart';
import '../bloc/movies_bloc.dart';
import '../repository/movie_repository.dart';

@RoutePage()
class MovieDetailsPage extends StatelessWidget {
  final Movie movie;

  const MovieDetailsPage({
    super.key,
    required this.movie,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<MoviesBloc>()..add(LoadMovieDetails(movie.id)),
        ),
      ],
      child: _MovieDetailsView(movie: movie),
    );
  }
}

class _MovieDetailsView extends StatefulWidget {
  final Movie movie;

  const _MovieDetailsView({required this.movie});

  @override
  State<_MovieDetailsView> createState() => _MovieDetailsViewState();
}

class _MovieDetailsViewState extends State<_MovieDetailsView> {
  MovieDetails? movieDetails;
  bool isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _checkBookmarkStatus();
  }

  Future<void> _checkBookmarkStatus() async {
    final repository = getIt<MovieRepository>();
    final bookmarked = await repository.isMovieBookmarked(widget.movie.id);
    setState(() {
      isBookmarked = bookmarked;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: Colors.black87,
      body: BlocListener<MoviesBloc, MoviesState>(
        listener: (context, state) {
          if (state is MovieDetailsLoaded) {
            setState(() {
              movieDetails = state.movieDetails;
            });
          } else if (state is BookmarkUpdated && state.movieId == widget.movie.id) {
            setState(() {
              isBookmarked = state.isBookmarked;
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
        child: CustomScrollView(
          slivers: [
            // Backdrop Image
            SliverAppBar(
              expandedHeight: 300.h,
              pinned: true,
              backgroundColor: AppColors.primaryColor,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (widget.movie.fullBackdropPath.isNotEmpty)
                      ImageIconView(
                        networkPath: widget.movie.fullBackdropPath,
                        width: double.infinity,
                        height: 300.h,
                        fit: BoxFit.cover,
                        errorWidget: Container(
                          color: AppColors.grey53,
                          child: Icon(
                            Icons.movie,
                            size: 80.w,
                            color: AppColors.grey4D,
                          ),
                        ),
                      )
                    else
                      Container(
                        color: AppColors.grey53,
                        child: Icon(
                          Icons.movie,
                          size: 80.w,
                          color: AppColors.grey4D,
                        ),
                      ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.router.pop(),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: isBookmarked ? AppColors.yellowE1 : Colors.white,
                  ),
                  onPressed: () {
                    if (isBookmarked) {
                      context.read<MoviesBloc>().add(
                        UnbookmarkMovie(widget.movie.id),
                      );
                    } else {
                      context.read<MoviesBloc>().add(
                        BookmarkMovie(widget.movie),
                      );
                    }
                  },
                ),
              ],
            ),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 120.w,
                          height: 180.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: widget.movie.fullPosterPath.isNotEmpty
                                ? ImageIconView(
                                    networkPath: widget.movie.fullPosterPath,
                                    width: 120.w,
                                    height: 180.h,
                                    fit: BoxFit.cover,
                                    borderRadius: 8.r,
                                    errorWidget: Container(
                                      color: AppColors.grey53,
                                      child: Icon(
                                        Icons.movie,
                                        size: 40.w,
                                        color: AppColors.grey4D,
                                      ),
                                    ),
                                  )
                                : Container(
                                    color: AppColors.grey53,
                                    child: Icon(
                                      Icons.movie,
                                      size: 40.w,
                                      color: AppColors.grey4D,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.movie.title,
                                style: AppTextStyles.text18.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              if (widget.movie.voteAverage > 0) ...[
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: AppColors.yellowE1,
                                      size: 16.w,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      widget.movie.formattedVoteAverage,
                                      style: AppTextStyles.text14.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8.h),
                              ],
                              if (widget.movie.releaseDate?.isNotEmpty == true) ...[
                                Text(
                                  widget.movie.formattedReleaseDate,
                                  style: AppTextStyles.text14.copyWith(
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    if (movieDetails != null && movieDetails!.genres.isNotEmpty) ...[
                      Text(
                        l10n.genres,
                        style: AppTextStyles.text18.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: movieDetails!.genres.map((genre) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Text(
                              genre.name,
                              style: AppTextStyles.text12.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
