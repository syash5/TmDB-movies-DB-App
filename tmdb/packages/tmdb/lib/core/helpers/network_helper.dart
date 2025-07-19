import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tmdb/core/atomic_widgets/pages/no_network_screen.dart';
import 'package:tmdb/core/l10n/l10n.dart';

import '../managers/network_manager.dart';

class NetworkHelper {
  NetworkHelper._();

  static void showNetworkErrorDialog(
    BuildContext context, {
    String? title,
    String? message,
    VoidCallback? onRetry,
  }) {
    final l10n = context.l10n;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title ?? l10n.networkErrorDialogTitle),
        content: Text(message ?? l10n.networkErrorDialogMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRetry?.call();
            },
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }

  static void showNetworkErrorBottomSheet(
    BuildContext context, {
    String? title,
    String? message,
    VoidCallback? onRetry,
  }) {
    final l10n = context.l10n;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => Container(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 48.w,
              color: Theme.of(context).colorScheme.error,
            ),
            SizedBox(height: 16.h),
            Text(
              title ?? l10n.networkErrorBottomSheetTitle,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              message ?? l10n.networkErrorBottomSheetMessage,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.cancel),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onRetry?.call();
                    },
                    child: Text(l10n.retry),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static void showNetworkErrorSnackBar(
    BuildContext context, {
    String? message,
    VoidCallback? onRetry,
  }) {
    final l10n = context.l10n;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? l10n.networkErrorSnackBarMessage),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        action: onRetry != null
            ? SnackBarAction(
                label: l10n.networkErrorSnackBarAction,
                onPressed: onRetry,
                textColor: Theme.of(context).colorScheme.onError,
              )
            : null,
      ),
    );
  }

  static void navigateToNetworkErrorScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NoNetworkScreen(),
        fullscreenDialog: true,
      ),
    );
  }

  static Future<bool> checkNetworkAndShowUI(
    BuildContext context,
    NetworkManager networkManager, {
    NetworkErrorType errorType = NetworkErrorType.dialog,
    String? title,
    String? message,
    VoidCallback? onRetry,
  }) async {
    final isConnected = networkManager.isConnected;

    if (!isConnected) {
      switch (errorType) {
        case NetworkErrorType.dialog:
          showNetworkErrorDialog(
            context,
            title: title,
            message: message,
            onRetry: onRetry,
          );
          break;
        case NetworkErrorType.bottomSheet:
          showNetworkErrorBottomSheet(
            context,
            title: title,
            message: message,
            onRetry: onRetry,
          );
          break;
        case NetworkErrorType.snackBar:
          showNetworkErrorSnackBar(context, message: message, onRetry: onRetry);
          break;
        case NetworkErrorType.fullScreen:
          navigateToNetworkErrorScreen(context);
          break;
      }
    }

    return isConnected;
  }
}

enum NetworkErrorType { dialog, bottomSheet, snackBar, fullScreen }

class NetworkStatusWidget extends StatelessWidget {
  final Widget child;
  final NetworkManager networkManager;
  final Widget Function(BuildContext context)? noNetworkBuilder;
  final bool showErrorAutomatically;

  const NetworkStatusWidget({
    super.key,
    required this.child,
    required this.networkManager,
    this.noNetworkBuilder,
    this.showErrorAutomatically = true,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: networkManager.networkStateStream,
      initialData: networkManager.isConnected,
      builder: (context, snapshot) {
        final isConnected = snapshot.data ?? false;

        if (!isConnected && showErrorAutomatically) {
          // Show error automatically when network is lost
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              NetworkHelper.showNetworkErrorSnackBar(context);
            }
          });
        }

        if (!isConnected && noNetworkBuilder != null) {
          return noNetworkBuilder!(context);
        }

        return child;
      },
    );
  }
}
