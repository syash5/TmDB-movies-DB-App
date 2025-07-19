import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../managers/hive_manager.dart';
import '../managers/network_manager.dart';
import 'injection.config.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async {
  await getIt.init();

  await _initializeCoreManagers();
}

Future<void> _initializeCoreManagers() async {
  try {
    if (kDebugMode) {
      print('Initializing core managers...');
    }

    // Initialize HiveManager
    final hiveManager = getIt<HiveManager>();
    if (!hiveManager.isInitialized) {
      await hiveManager.initialize();
    }

    // Initialize NetworkManager
    final networkManager = getIt<NetworkManager>();
    if (!networkManager.isInitialized) {
      await networkManager.initialize();
    }

    // AuthInterceptor is automatically configured to use TMDB access token
  } catch (e) {
    if (kDebugMode) {
      print('Failed to initialize core managers: $e');
    }
    rethrow;
  }
}

Future<void> resetDependencies() async {
  await getIt.reset();
}
