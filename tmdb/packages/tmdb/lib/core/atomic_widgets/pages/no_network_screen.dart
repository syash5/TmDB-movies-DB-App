import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tmdb/core/network/bloc/network_bloc.dart';
import 'package:tmdb/core/theme/colors.dart';
import 'package:tmdb/core/theme/text_styles.dart';

class NoNetworkScreen extends StatelessWidget {
  const NoNetworkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Network icon
              Icon(Icons.wifi_off_rounded, size: 120.w, color: AppColors.grey),

              SizedBox(height: 32.h),

              // Title
              Text(
                'No Internet Connection',
                style: AppTextStyles.text24SemiBold.copyWith(
                  color: AppColors.black13,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 16.h),

              // Description
              Text(
                'Please check your internet connection and try again.',
                style: AppTextStyles.text16.copyWith(color: AppColors.grey),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 48.h),

              // Retry button
              BlocBuilder<NetworkBloc, NetworkState>(
                builder: (context, state) {
                  final isLoading = state is NetworkChecking || state is NetworkRetrying;

                  return SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              context.read<NetworkBloc>().add(
                                const NetworkRetryRequested(),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: isLoading
                          ? SizedBox(
                              height: 20.h,
                              width: 20.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              'Try Again',
                              style: AppTextStyles.text16SemiBold,
                            ),
                    ),
                  );
                },
              ),

              SizedBox(height: 16.h),

              // Settings button
              TextButton(
                onPressed: () {
                  // Open system settings - this is platform specific
                  // For now, just show a message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please check your device network settings',
                      ),
                    ),
                  );
                },
                child: Text(
                  'Network Settings',
                  style: AppTextStyles.text14.copyWith(
                    color: AppColors.primaryColor,
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
