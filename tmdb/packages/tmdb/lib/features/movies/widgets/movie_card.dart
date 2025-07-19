import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tmdb/features/movies/models/movie.dart';

import '../../../core/atomic_widgets/molecules/molecules.dart';
import '../../../core/theme/theme.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback? onTap;
  final VoidCallback? onBookmark;
  final bool isBookmarked;

  const MovieCard({
    super.key,
    required this.movie,
    this.onTap,
    this.onBookmark,
    this.isBookmarked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(8.w),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          width: 150.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            color: AppColors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Movie Poster (Banner)
              Stack(
                children: [
                  Container(
                    height: 200.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(8.r),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(8.r),
                      ),
                      child: movie.fullPosterPath.isNotEmpty
                          ? ImageIconView(
                              networkPath: movie.fullPosterPath,
                              width: double.infinity,
                              height: 200.h,
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
                              color: AppColors.grey,
                              child: Icon(
                                Icons.movie,
                                size: 40.w,
                                color: AppColors.grey4D,
                              ),
                            ),
                    ),
                  ),

                  // Bookmark Button
                  if (onBookmark != null)
                    Positioned(
                      top: 8.h,
                      right: 8.w,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onBookmark,
                          borderRadius: BorderRadius.circular(16.r),
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: AppColors.black2C,
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Icon(
                              isBookmarked
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color: isBookmarked
                                  ? AppColors.yellowE1
                                  : AppColors.white,
                              size: 20.w,
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Rating Badge
                  Positioned(
                    bottom: 8.h,
                    left: 8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.black2C,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            color: AppColors.yellowE1,
                            size: 12.w,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            movie.formattedVoteAverage,
                            style: AppTextStyles.text12.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Movie Info
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(8.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Movie Name
                      Text(
                        movie.title,
                        style: AppTextStyles.text14.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: 4.h),

                      // Year
                      Text(
                        movie.formattedReleaseDate,
                        style: AppTextStyles.text12.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
