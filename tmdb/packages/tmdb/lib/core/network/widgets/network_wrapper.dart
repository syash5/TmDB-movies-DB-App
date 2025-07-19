import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tmdb/core/atomic_widgets/pages/no_network_screen.dart';
import 'package:tmdb/core/l10n/l10n.dart';

import '../../di/injection.dart';
import '../bloc/network_bloc.dart';

class NetworkWrapper extends StatelessWidget {
  final Widget child;
  final bool showFullScreenError;

  const NetworkWrapper({
    Key? key,
    required this.child,
    this.showFullScreenError = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocProvider(
      create: (context) => getIt<NetworkBloc>()..add(const NetworkStarted()),
      child: BlocBuilder<NetworkBloc, NetworkState>(
        builder: (context, state) {
          // Show full-screen error when network is disconnected
          if (state is NetworkDisconnected && showFullScreenError) {
            return const NoNetworkScreen();
          }

          // Show loading when checking network
          if (state is NetworkChecking || state is NetworkRetrying) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      state is NetworkChecking
                          ? l10n.connectionChecking
                          : l10n.connectionRetrying,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            );
          }

          // Show error screen for network errors
          if (state is NetworkError) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.networkError,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        context.read<NetworkBloc>().add(
                          const NetworkRetryRequested(),
                        );
                      },
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            );
          }

          // Show normal app when connected
          return child;
        },
      ),
    );
  }
}

/// A simplified network status indicator that can be used in specific screens
class NetworkStatusIndicator extends StatelessWidget {
  final Widget child;
  final bool showSnackBar;

  const NetworkStatusIndicator({
    Key? key,
    required this.child,
    this.showSnackBar = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocListener<NetworkBloc, NetworkState>(
      listener: (context, state) {
        if (showSnackBar) {
          if (state is NetworkDisconnected) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.noInternetConnection),
                backgroundColor: Theme.of(context).colorScheme.error,
                duration: const Duration(seconds: 3),
                action: SnackBarAction(
                  label: l10n.retry,
                  onPressed: () {
                    context.read<NetworkBloc>().add(
                      const NetworkRetryRequested(),
                    );
                  },
                ),
              ),
            );
          } else if (state is NetworkConnected) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.connectedToInternet),
                backgroundColor: Theme.of(context).colorScheme.primary,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      },
      child: child,
    );
  }
}

/// A widget that shows network status in the app bar
class NetworkStatusAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final AppBar appBar;

  const NetworkStatusAppBar({Key? key, required this.appBar}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BlocBuilder<NetworkBloc, NetworkState>(
          builder: (context, state) {
            if (state is NetworkDisconnected) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 4),
                color: Theme.of(context).colorScheme.error,
                child: Text(
                  l10n.noInternetConnection,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onError,
                    fontSize: 12,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        appBar,
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
    appBar.preferredSize.height +
        ( /* Add height for network status bar when needed */ 0),
  );
}
