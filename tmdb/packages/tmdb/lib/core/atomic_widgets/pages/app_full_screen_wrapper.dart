import 'package:flutter/material.dart';
import 'package:tmdb/core/theme/colors.dart';

/// Full screen wrapper component for consistent full screen layouts
class AppFullScreenWrapper extends StatelessWidget {
  final Widget child;
  final bool showAppBar;
  final String? title;
  final Color? backgroundColor;
  final Color? appBarBackgroundColor;
  final bool safeArea;
  final EdgeInsetsGeometry? padding;
  final Widget? floatingActionButton;
  final Widget? drawer;
  final Widget? endDrawer;
  final Widget? bottomNavigationBar;
  final PreferredSizeWidget? appBar;

  const AppFullScreenWrapper({
    super.key,
    required this.child,
    this.showAppBar = false,
    this.title,
    this.backgroundColor,
    this.appBarBackgroundColor,
    this.safeArea = true,
    this.padding,
    this.floatingActionButton,
    this.drawer,
    this.endDrawer,
    this.bottomNavigationBar,
    this.appBar,
  });

  @override
  Widget build(BuildContext context) {
    Widget body = child;

    if (padding != null) {
      body = Padding(padding: padding!, child: body);
    }

    if (safeArea) {
      body = SafeArea(child: body);
    }

    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.backgroundColor,
      appBar: showAppBar && appBar == null
          ? AppBar(
              title: title != null ? Text(title!) : null,
              backgroundColor: appBarBackgroundColor ?? AppColors.primaryColor,
              elevation: 0,
            )
          : appBar,
      body: body,
      floatingActionButton: floatingActionButton,
      drawer: drawer,
      endDrawer: endDrawer,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

/// Centered full screen wrapper for content that needs to be centered
class AppCenteredFullScreenWrapper extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;

  const AppCenteredFullScreenWrapper({
    super.key,
    required this.child,
    this.backgroundColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return AppFullScreenWrapper(
      backgroundColor: backgroundColor,
      child: Center(
        child: Container(padding: padding, child: child),
      ),
    );
  }
}

/// Legacy FullScreenWidget component for backwards compatibility
/// @deprecated Use AppFullScreenWrapper instead
class FullScreenWidget extends StatelessWidget {
  final Widget child;

  const FullScreenWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return AppCenteredFullScreenWrapper(child: child);
  }
}
